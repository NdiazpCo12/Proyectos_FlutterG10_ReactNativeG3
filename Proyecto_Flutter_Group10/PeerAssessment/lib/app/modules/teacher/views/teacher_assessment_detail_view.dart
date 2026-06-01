part of 'teacher_home_view.dart';

class TeacherAssessmentDetailView extends StatefulWidget {
  const TeacherAssessmentDetailView({super.key, required this.assessmentId});

  final String assessmentId;

  @override
  State<TeacherAssessmentDetailView> createState() =>
      _TeacherAssessmentDetailViewState();
}

class _TeacherAssessmentDetailViewState
    extends State<TeacherAssessmentDetailView> {
  late Future<RobleAssessmentDetailData?> _detailFuture;

  TeacherHomeController get _controller => Get.find<TeacherHomeController>();

  @override
  void initState() {
    super.initState();
    _detailFuture = _controller.loadAssessmentDetail(widget.assessmentId);
  }

  Future<void> _reload() async {
    setState(() {
      _detailFuture = _controller.loadAssessmentDetail(widget.assessmentId);
    });
    await _detailFuture;
    await _controller.fetchAssessments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.themeData.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Assessment'),
        actions: [
          IconButton(
            tooltip: 'Recargar',
            onPressed: _reload,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<RobleAssessmentDetailData?>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryGreen),
            );
          }

          if (snapshot.hasError) {
            return RefreshIndicator(
              onRefresh: _reload,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _SurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'No se pudo cargar el assessment',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          formatUserErrorMessage(
                            snapshot.error!,
                            fallback:
                                'No se pudo cargar la informacion de esta evaluacion.',
                          ),
                          style: const TextStyle(color: AppTheme.textMuted),
                        ),
                        const SizedBox(height: 18),
                        FilledButton.icon(
                          onPressed: _reload,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Intentar de nuevo'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data;
          if (data == null) {
            return RefreshIndicator(
              onRefresh: _reload,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: const [
                  _SurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Assessment no encontrado',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Esta evaluacion ya no esta disponible.',
                          style: TextStyle(color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          final overview = data.overview;
          final assessment = overview.assessment;
          final completion = overview.completionProgress.clamp(0.0, 1.0);
          final visibilityTone = overview.visibilityLabel == 'Public'
              ? AppTheme.primaryGreen
              : AppTheme.secondarySlate;
          final statusTone = switch (overview.statusLabel) {
            'Closed' => AppTheme.secondarySlate,
            'Draft' => const Color(0xFF73C79B),
            'Scheduled' => const Color(0xFF2E7D32),
            _ => AppTheme.primaryGreen,
          };

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              children: [
                _SurfaceCard(
                  borderRadius: 26,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        overview.course.code,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textMuted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        assessment.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _PillTag(
                            label: overview.statusLabel,
                            color: statusTone,
                          ),
                          _PillTag(
                            label: overview.visibilityLabel,
                            color: visibilityTone,
                          ),
                          _StatusChip(
                            label: data.category?.name ?? overview.categoryName,
                            tone: AppTheme.primaryGreen,
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _TeacherInfoRow(
                        icon: Icons.menu_book_outlined,
                        text: overview.course.name,
                      ),
                      const SizedBox(height: 10),
                      _TeacherInfoRow(
                        icon: Icons.calendar_month_outlined,
                        text:
                            '${_formatAssessmentDateTime(assessment.startsAt)} - ${_formatAssessmentDateTime(assessment.endsAt)}',
                      ),
                      const SizedBox(height: 10),
                      _TeacherInfoRow(
                        icon: Icons.alternate_email_rounded,
                        text: assessment.createdByEmail.isEmpty
                            ? 'Sin correo del docente'
                            : assessment.createdByEmail,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _SurfaceCard(
                  borderRadius: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Assessment Overview',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: _MiniInfo(
                              label: 'Responses',
                              value: overview.responsesSubmitted.toString(),
                            ),
                          ),
                          Expanded(
                            child: _MiniInfo(
                              label: 'Reviewers',
                              value: overview.totalReviewers.toString(),
                            ),
                          ),
                          Expanded(
                            child: _MiniInfo(
                              label: 'Criteria',
                              value: data.criteria.length.toString(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Submission progress',
                              style: TextStyle(
                                fontSize: 15,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ),
                          Text(
                            '${overview.responsesSubmitted}/${overview.totalReviewers}',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          minHeight: 8,
                          value: completion,
                          backgroundColor: const Color(0xFFE0E0E0),
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _SurfaceCard(
                  borderRadius: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rubric',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Aqui puedes ver los criterios y niveles configurados para esta evaluacion.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textMuted,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (data.criteria.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'Este assessment aun no tiene criterios registrados.',
                            style: TextStyle(color: AppTheme.textMuted),
                          ),
                        )
                      else
                        ...data.criteria.map(
                          (criterionDetail) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _AssessmentCriterionCard(
                              criterionDetail: criterionDetail,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AssessmentCriterionCard extends StatelessWidget {
  const _AssessmentCriterionCard({required this.criterionDetail});

  final RobleAssessmentCriterionDetail criterionDetail;

  @override
  Widget build(BuildContext context) {
    final criterion = criterionDetail.criterion;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9F8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8E5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      criterion.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (criterion.description.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        criterion.description,
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _StatusChip(
                label: '${criterion.weight}%',
                tone: AppTheme.primaryGreen,
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (criterionDetail.levels.isEmpty)
            const Text(
              'No hay niveles definidos para este criterio.',
              style: TextStyle(color: AppTheme.textMuted),
            )
          else
            ...criterionDetail.levels.map(
              (level) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _AssessmentLevelTile(level: level),
              ),
            ),
        ],
      ),
    );
  }
}

class _AssessmentLevelTile extends StatelessWidget {
  const _AssessmentLevelTile({required this.level});

  final RobleAssessmentCriterionLevel level;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8E5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _PillTag(
                label: level.scoreValue.toString(),
                color: AppTheme.primaryGreen,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  level.label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (level.descriptionEn.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(level.descriptionEn, style: const TextStyle(height: 1.35)),
          ],
          if (level.descriptionEs.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              level.descriptionEs,
              style: const TextStyle(color: AppTheme.textMuted, height: 1.35),
            ),
          ],
        ],
      ),
    );
  }
}

String _formatAssessmentDateTime(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  final year = value.year.toString();
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$day/$month/$year $hour:$minute';
}
