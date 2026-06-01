part of 'student_home_view.dart';

class _StudentAssessmentsView extends StatefulWidget {
  const _StudentAssessmentsView({
    required this.assessments,
    required this.isLoading,
    required this.onRefresh,
    required this.onSubmitAssessment,
  });

  final List<RobleStudentAssessmentAssignment> assessments;
  final bool isLoading;
  final Future<void> Function() onRefresh;
  final Future<void> Function(
    RobleStudentAssessmentAssignment assessment,
    Map<String, Map<String, int>> scoresByReviewee,
  )
  onSubmitAssessment;

  @override
  State<_StudentAssessmentsView> createState() =>
      _StudentAssessmentsViewState();
}

class _StudentAssessmentsViewState extends State<_StudentAssessmentsView> {
  RobleStudentAssessmentAssignment? _selectedAssessment;
  int _currentTeammateIndex = 0;
  bool _isSubmitting = false;
  Map<String, Map<String, int>> _draftRatings = {};

  void _openAssessment(RobleStudentAssessmentAssignment assessment) {
    if (!assessment.canSubmit) {
      return;
    }

    final savedScores = <String, Map<String, int>>{
      for (final teammate in assessment.teammates)
        teammate.studentId: Map<String, int>.from(
          assessment.savedScoresByReviewee[teammate.studentId] ?? const {},
        ),
    };

    setState(() {
      _selectedAssessment = assessment;
      _currentTeammateIndex = 0;
      _draftRatings = savedScores;
    });
  }

  void _closeAssessment() {
    if (_isSubmitting) {
      return;
    }

    setState(() {
      _selectedAssessment = null;
      _currentTeammateIndex = 0;
      _draftRatings = {};
    });
  }

  void _setRating(
    RobleAssessmentCriterionDetail criterion,
    RobleStudentAssessmentTeammate teammate,
    int value,
  ) {
    final criterionId = criterion.criterion.id?.trim() ?? '';
    if (criterionId.isEmpty || _selectedAssessment == null || _isSubmitting) {
      return;
    }

    setState(() {
      _draftRatings.putIfAbsent(
        teammate.studentId,
        () => <String, int>{},
      )[criterionId] = value;
    });
  }

  bool _validateTeammate(
    RobleStudentAssessmentAssignment assessment,
    RobleStudentAssessmentTeammate teammate,
  ) {
    final teammateRatings = _draftRatings[teammate.studentId] ?? const {};
    for (final criterion in assessment.criteria) {
      final criterionId = criterion.criterion.id?.trim() ?? '';
      if (criterionId.isEmpty) {
        continue;
      }
      if (!teammateRatings.containsKey(criterionId)) {
        return false;
      }
    }
    return true;
  }

  void _showIncompleteMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Completa todos los criterios antes de continuar.'),
      ),
    );
  }

  Future<void> _goNext() async {
    final assessment = _selectedAssessment;
    if (assessment == null || _isSubmitting) {
      return;
    }

    final teammate = assessment.teammates[_currentTeammateIndex];
    if (!_validateTeammate(assessment, teammate)) {
      _showIncompleteMessage();
      return;
    }

    if (_currentTeammateIndex < assessment.teammates.length - 1) {
      setState(() => _currentTeammateIndex += 1);
      return;
    }

    final shouldSubmit = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Enviar evaluacion',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          content: Text(
            'Se enviaran las calificaciones de ${assessment.teammates.length} companeros. Esta accion no se puede deshacer.',
            style: const TextStyle(color: AppTheme.textMuted, height: 1.5),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: const Text(
                'Enviar',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );

    if (shouldSubmit != true || !mounted) {
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await widget.onSubmitAssessment(assessment, _draftRatings);
      if (!mounted) {
        return;
      }

      setState(() {
        _selectedAssessment = null;
        _currentTeammateIndex = 0;
        _draftRatings = {};
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${assessment.assessment.name} enviada correctamente.'),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            formatUserErrorMessage(
              error,
              fallback: 'No se pudo enviar la evaluacion.',
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final assessment = _selectedAssessment;
    if (assessment == null) {
      return _StudentAssessmentList(
        assessments: widget.assessments,
        isLoading: widget.isLoading,
        onOpenAssessment: _openAssessment,
        onRefresh: widget.onRefresh,
      );
    }

    return _StudentAssessmentDetail(
      assessment: assessment,
      teammate: assessment.teammates[_currentTeammateIndex],
      teammateIndex: _currentTeammateIndex,
      totalTeammates: assessment.teammates.length,
      draftRatings: _draftRatings,
      isSubmitting: _isSubmitting,
      onBack: _closeAssessment,
      onPrevious: _currentTeammateIndex == 0 || _isSubmitting
          ? null
          : () => setState(() => _currentTeammateIndex -= 1),
      onNext: _goNext,
      onRateCriterion: _setRating,
    );
  }
}

class _StudentAssessmentList extends StatelessWidget {
  const _StudentAssessmentList({
    required this.assessments,
    required this.isLoading,
    required this.onOpenAssessment,
    required this.onRefresh,
  });

  final List<RobleStudentAssessmentAssignment> assessments;
  final bool isLoading;
  final ValueChanged<RobleStudentAssessmentAssignment> onOpenAssessment;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 120),
        children: [
          Container(
            color: AppTheme.primaryGreen,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Assessments',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Califica a tus companeros cuando la actividad este activa.',
                      style: TextStyle(fontSize: 16, color: Color(0xFFDDE9DE)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
            child: isLoading
                ? const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  )
                : assessments.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: Text(
                        'No tienes evaluaciones disponibles por ahora.',
                        style: TextStyle(color: AppTheme.textMuted),
                      ),
                    ),
                  )
                : Column(
                    children: assessments
                        .map(
                          (assessment) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _StudentAssessmentCard(
                              assessment: assessment,
                              onTap: assessment.canSubmit
                                  ? () => onOpenAssessment(assessment)
                                  : null,
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _StudentAssessmentCard extends StatelessWidget {
  const _StudentAssessmentCard({required this.assessment, required this.onTap});

  final RobleStudentAssessmentAssignment assessment;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isCompleted = assessment.isSubmitted;
    final chipColor = switch (assessment.statusLabel) {
      'Completed' => const Color(0xFFE6F4EA),
      'Active' => AppTheme.primaryGreen,
      'Scheduled' => const Color(0xFF4F8B5B),
      'Closed' => AppTheme.secondarySlate,
      _ => const Color(0xFFECEFF3),
    };
    final chipTextColor =
        isCompleted || assessment.statusLabel == 'No teammates'
        ? AppTheme.primaryGreen
        : Colors.white;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: chipColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  assessment.statusLabel,
                  style: TextStyle(
                    color: chipTextColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                Icons.chevron_right_rounded,
                color: onTap == null
                    ? const Color(0xFFB8C0CC)
                    : AppTheme.secondarySlate,
                size: 28,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            assessment.assessment.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Text(
            '${assessment.course.code} - ${assessment.course.name}',
            style: const TextStyle(fontSize: 15, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 28),
          _AssessmentMetaRow(
            icon: Icons.calendar_today_outlined,
            text:
                'Disponible hasta ${_formatStudentDate(assessment.assessment.endsAt)}',
          ),
          const SizedBox(height: 12),
          _AssessmentMetaRow(
            icon: Icons.category_outlined,
            text: assessment.categoryName,
          ),
          const SizedBox(height: 12),
          _AssessmentMetaRow(
            icon: Icons.group_outlined,
            text: assessment.group.groupName,
          ),
          const SizedBox(height: 18),
          Text(
            'Debes evaluar a ${assessment.teammates.length} companeros',
            style: const TextStyle(
              fontSize: 15,
              color: AppTheme.secondarySlate,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                backgroundColor: onTap == null
                    ? const Color(0xFF95B79A)
                    : AppTheme.primaryGreen,
                minimumSize: const Size.fromHeight(36),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: Text(
                _assessmentActionLabel(assessment),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _assessmentActionLabel(RobleStudentAssessmentAssignment assessment) {
    switch (assessment.statusLabel) {
      case 'Completed':
        return 'Evaluacion enviada';
      case 'Scheduled':
        return 'Disponible pronto';
      case 'Closed':
        return 'Actividad cerrada';
      case 'No teammates':
        return 'Sin companeros para evaluar';
      default:
        return 'Iniciar evaluacion';
    }
  }
}

class _StudentAssessmentDetail extends StatelessWidget {
  const _StudentAssessmentDetail({
    required this.assessment,
    required this.teammate,
    required this.teammateIndex,
    required this.totalTeammates,
    required this.draftRatings,
    required this.isSubmitting,
    required this.onBack,
    required this.onPrevious,
    required this.onNext,
    required this.onRateCriterion,
  });

  final RobleStudentAssessmentAssignment assessment;
  final RobleStudentAssessmentTeammate teammate;
  final int teammateIndex;
  final int totalTeammates;
  final Map<String, Map<String, int>> draftRatings;
  final bool isSubmitting;
  final VoidCallback onBack;
  final VoidCallback? onPrevious;
  final VoidCallback onNext;
  final void Function(
    RobleAssessmentCriterionDetail criterion,
    RobleStudentAssessmentTeammate teammate,
    int value,
  )
  onRateCriterion;

  @override
  Widget build(BuildContext context) {
    final progress = totalTeammates == 0
        ? 0.0
        : (teammateIndex + 1) / totalTeammates;
    final isLastTeammate = teammateIndex == totalTeammates - 1;

    return Column(
      children: [
        Container(
          color: AppTheme.primaryGreen,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton.icon(
                    onPressed: isSubmitting ? null : onBack,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: const Icon(Icons.arrow_back, size: 20),
                    label: const Text('Back', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    assessment.assessment.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${assessment.course.code} - ${assessment.course.name}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFFDDE9DE),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${assessment.categoryName} • ${assessment.group.groupName}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFFDDE9DE),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 14),
                decoration: const BoxDecoration(
                  color: Color(0xFFF7F7F7),
                  border: Border(bottom: BorderSide(color: Color(0xFFE2E5E8))),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          'Companero ${teammateIndex + 1} de $totalTeammates',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const Spacer(),
                        Text(
                          _formatStudentDate(assessment.assessment.endsAt),
                          style: const TextStyle(color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: const Color(0xFFDADDE1),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 18,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              teammate.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              teammate.email,
                              style: const TextStyle(
                                fontSize: 15,
                                color: AppTheme.textMuted,
                              ),
                            ),
                            const SizedBox(height: 18),
                            ...List.generate(assessment.criteria.length, (
                              index,
                            ) {
                              final criterion = assessment.criteria[index];
                              final criterionId =
                                  criterion.criterion.id?.trim() ?? '';
                              final rating =
                                  draftRatings[teammate
                                      .studentId]?[criterionId];
                              return _CriterionRatingRow(
                                criterion: criterion,
                                rating: rating,
                                isLast: index == assessment.criteria.length - 1,
                                isEnabled: !isSubmitting,
                                onChanged: (value) =>
                                    onRateCriterion(criterion, teammate, value),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(22, 12, 22, 12),
                  decoration: const BoxDecoration(
                    color: AppTheme.backgroundColor,
                    border: Border(top: BorderSide(color: Color(0xFFE2E5E8))),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onPrevious,
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            backgroundColor: Colors.white,
                            foregroundColor: onPrevious == null
                                ? const Color(0xFF9DA6B2)
                                : AppTheme.secondarySlate,
                            side: BorderSide(
                              color: onPrevious == null
                                  ? const Color(0xFFE1E4E8)
                                  : const Color(0xFFD2D9DE),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'Previous',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: isSubmitting ? null : onNext,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            isSubmitting
                                ? 'Enviando...'
                                : isLastTeammate
                                ? 'Enviar evaluacion'
                                : 'Siguiente companero',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CriterionRatingRow extends StatelessWidget {
  const _CriterionRatingRow({
    required this.criterion,
    required this.rating,
    required this.isLast,
    required this.isEnabled,
    required this.onChanged,
  });

  final RobleAssessmentCriterionDetail criterion;
  final int? rating;
  final bool isLast;
  final bool isEnabled;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    RobleAssessmentCriterionLevel? selectedLevel;
    for (final level in criterion.levels) {
      if (level.scoreValue == rating) {
        selectedLevel = level;
        break;
      }
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 700;

              if (isCompact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CriterionDescription(
                      criterion: criterion,
                      selectedLevel: selectedLevel,
                    ),
                    const SizedBox(height: 20),
                    _CriterionScaleSelector(
                      levels: criterion.levels,
                      selectedValue: rating,
                      isEnabled: isEnabled,
                      onChanged: onChanged,
                    ),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: _CriterionDescription(
                      criterion: criterion,
                      selectedLevel: selectedLevel,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 4,
                    child: _CriterionScaleSelector(
                      levels: criterion.levels,
                      selectedValue: rating,
                      isEnabled: isEnabled,
                      onChanged: onChanged,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        if (!isLast) const Divider(height: 1, color: Color(0xFFE2E5E8)),
      ],
    );
  }
}

class _CriterionDescription extends StatelessWidget {
  const _CriterionDescription({
    required this.criterion,
    required this.selectedLevel,
  });

  final RobleAssessmentCriterionDetail criterion;
  final RobleAssessmentCriterionLevel? selectedLevel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          criterion.criterion.name,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        if (criterion.criterion.description.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            criterion.criterion.description,
            style: const TextStyle(
              fontSize: 15,
              color: AppTheme.secondarySlate,
              height: 1.35,
            ),
          ),
        ],
        const SizedBox(height: 10),
        Text(
          selectedLevel == null
              ? 'Selecciona un puntaje'
              : '${selectedLevel!.label}: ${selectedLevel!.descriptionEs.isNotEmpty ? selectedLevel!.descriptionEs : selectedLevel!.descriptionEn}',
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textMuted,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _CriterionScaleSelector extends StatelessWidget {
  const _CriterionScaleSelector({
    required this.levels,
    required this.selectedValue,
    required this.isEnabled,
    required this.onChanged,
  });

  final List<RobleAssessmentCriterionLevel> levels;
  final int? selectedValue;
  final bool isEnabled;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: levels
              .map(
                (level) => ChoiceChip(
                  label: Text('${level.scoreValue}'),
                  selected: selectedValue == level.scoreValue,
                  onSelected: isEnabled
                      ? (_) => onChanged(level.scoreValue)
                      : null,
                  selectedColor: AppTheme.primaryGreen,
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: selectedValue == level.scoreValue
                        ? Colors.white
                        : AppTheme.secondarySlate,
                  ),
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFFD2D9DE)),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 10),
        Text(
          selectedValue == null ? 'Sin seleccionar' : 'Puntaje: $selectedValue',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.secondarySlate,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

class _AssessmentMetaRow extends StatelessWidget {
  const _AssessmentMetaRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.textMuted),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              color: AppTheme.secondarySlate,
            ),
          ),
        ),
      ],
    );
  }
}

String _formatStudentDate(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  final year = value.year.toString();
  return '$day/$month/$year';
}
