part of 'student_home_view.dart';

class _StudentResultsView extends StatefulWidget {
  const _StudentResultsView({
    required this.summary,
    required this.isLoading,
    required this.onRefresh,
  });

  final RobleStudentResultsSummary summary;
  final bool isLoading;
  final Future<void> Function() onRefresh;

  @override
  State<_StudentResultsView> createState() => _StudentResultsViewState();
}

class _StudentResultsViewState extends State<_StudentResultsView> {
  String? _selectedCourseId;

  @override
  void initState() {
    super.initState();
    _syncSelectedCourse();
  }

  @override
  void didUpdateWidget(covariant _StudentResultsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncSelectedCourse();
  }

  void _syncSelectedCourse() {
    final courseResults = widget.summary.courseResults;
    if (courseResults.isEmpty) {
      _selectedCourseId = null;
      return;
    }

    final hasSelected = courseResults.any(
      (course) => course.courseId == _selectedCourseId,
    );
    if (!hasSelected) {
      _selectedCourseId = courseResults.first.courseId;
    }
  }

  RobleStudentCourseResults? get _selectedCourseResults {
    final selectedCourseId = _selectedCourseId?.trim() ?? '';
    if (selectedCourseId.isEmpty) {
      return widget.summary.courseResults.isEmpty
          ? null
          : widget.summary.courseResults.first;
    }

    for (final course in widget.summary.courseResults) {
      if (course.courseId == selectedCourseId) {
        return course;
      }
    }

    return widget.summary.courseResults.isEmpty
        ? null
        : widget.summary.courseResults.first;
  }

  @override
  Widget build(BuildContext context) {
    final selectedCourse = _selectedCourseResults;

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 120),
        children: [
          Container(
            color: AppTheme.primaryGreen,
            child: SafeArea(
              bottom: false,
              child: const Padding(
                padding: EdgeInsets.fromLTRB(22, 22, 22, 26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Results',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'View your peer assessment feedback by course',
                      style: TextStyle(fontSize: 16, color: Color(0xFFDDE9DE)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
            child: widget.isLoading
                ? const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  )
                : Column(
                    children: [
                      _StudentSurfaceCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Select Course',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Choose the course whose public results you want to review.',
                              style: TextStyle(
                                fontSize: 15,
                                color: AppTheme.secondarySlate,
                              ),
                            ),
                            const SizedBox(height: 18),
                            DropdownButtonFormField<String>(
                              key: ValueKey(
                                'student-results-course-${_selectedCourseId ?? 'none'}',
                              ),
                              initialValue:
                                  _selectedCourseId != null &&
                                      _selectedCourseId!.trim().isNotEmpty
                                  ? _selectedCourseId
                                  : null,
                              isExpanded: true,
                              hint: const Text('Choose a course'),
                              icon: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                              ),
                              decoration: const InputDecoration(),
                              items: widget.summary.courseResults
                                  .map(
                                    (course) => DropdownMenuItem<String>(
                                      value: course.courseId,
                                      child: Text(
                                        course.displayLabel,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setState(() => _selectedCourseId = value);
                              },
                            ),
                            if (widget.summary.courseResults.isEmpty) ...[
                              const SizedBox(height: 14),
                              const Text(
                                'No public course results available yet.',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: AppTheme.secondarySlate,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _StudentSurfaceCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Overall Performance',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              selectedCourse?.hasResults == true
                                  ? 'Your average score across public assessments in this course'
                                  : 'Only public assessments with published feedback appear here',
                              style: const TextStyle(
                                fontSize: 15,
                                color: AppTheme.secondarySlate,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (selectedCourse != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F7F0),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  selectedCourse.displayLabel,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primaryGreen,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 28),
                            Center(
                              child: Column(
                                children: [
                                  Text(
                                    (selectedCourse?.overallScore ?? 0)
                                        .toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontSize: 46,
                                      height: 1,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.primaryGreen,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Out of 5.0',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: AppTheme.secondarySlate,
                                    ),
                                  ),
                                  const SizedBox(height: 26),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _ResultsStat(
                                        value:
                                            '${selectedCourse?.assessmentCount ?? 0}',
                                        label: 'Assessments',
                                      ),
                                      const SizedBox(width: 30),
                                      _ResultsStat(
                                        value:
                                            '${selectedCourse?.reviewCount ?? 0}',
                                        label: 'Reviews',
                                      ),
                                    ],
                                  ),
                                  if (selectedCourse?.hasResults != true) ...[
                                    const SizedBox(height: 18),
                                    const Text(
                                      'No public results available yet for this course.',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: AppTheme.secondarySlate,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _StudentSurfaceCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Criteria Breakdown',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Your scores by evaluation criteria in the selected course',
                              style: TextStyle(
                                fontSize: 15,
                                color: AppTheme.secondarySlate,
                              ),
                            ),
                            const SizedBox(height: 22),
                            if (selectedCourse == null ||
                                selectedCourse.criteria.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 24),
                                child: Center(
                                  child: Text(
                                    'No criteria data available for this course yet.',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: AppTheme.secondarySlate,
                                    ),
                                  ),
                                ),
                              )
                            else
                              Center(
                                child: SizedBox(
                                  width: 380,
                                  height: 380,
                                  child: _RadarChart(
                                    scores: selectedCourse.criteria,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _StudentSurfaceCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Detailed Scores',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Breakdown by criteria for the selected course',
                              style: TextStyle(
                                fontSize: 15,
                                color: AppTheme.secondarySlate,
                              ),
                            ),
                            const SizedBox(height: 18),
                            if (selectedCourse == null ||
                                selectedCourse.criteria.isEmpty)
                              const Text(
                                'No detailed scores available yet.',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: AppTheme.secondarySlate,
                                ),
                              )
                            else
                              ...selectedCourse.criteria.map(
                                (criterion) => Padding(
                                  padding: const EdgeInsets.only(bottom: 18),
                                  child: _DetailedScoreRow(score: criterion),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _StudentSurfaceCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Assessment History',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Your past public peer assessments in the selected course',
                              style: TextStyle(
                                fontSize: 15,
                                color: AppTheme.secondarySlate,
                              ),
                            ),
                            const SizedBox(height: 18),
                            if (selectedCourse == null ||
                                selectedCourse.history.isEmpty)
                              const Text(
                                'No published assessment history available yet for this course.',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: AppTheme.secondarySlate,
                                ),
                              )
                            else
                              ...selectedCourse.history.map(
                                (item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _AssessmentHistoryCard(item: item),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _ResultsStat extends StatelessWidget {
  const _ResultsStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 15, color: AppTheme.secondarySlate),
        ),
      ],
    );
  }
}

class _DetailedScoreRow extends StatelessWidget {
  const _DetailedScoreRow({required this.score});

  final RobleStudentResultCriterionScore score;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 520;
        final bar = Expanded(
          child: Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: score.score / 5,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFD9D9D9),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryGreen,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 42,
                child: Text(
                  score.score.toStringAsFixed(1),
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                score.label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Row(children: [bar]),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: Text(
                score.label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(child: bar),
          ],
        );
      },
    );
  }
}

class _AssessmentHistoryCard extends StatelessWidget {
  const _AssessmentHistoryCard({required this.item});

  final RobleStudentAssessmentHistoryItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F7F0),
        borderRadius: BorderRadius.circular(22),
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
                      item.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatStudentDate(item.date),
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppTheme.secondarySlate,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                item.score.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
          if (item.criteria.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: item.criteria
                  .map(
                    (criterion) =>
                        _AssessmentHistoryCriterionChip(score: criterion),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _AssessmentHistoryCriterionChip extends StatelessWidget {
  const _AssessmentHistoryCriterionChip({required this.score});

  final RobleStudentResultCriterionScore score;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDDE6DA)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            score.label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.secondarySlate,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            score.score.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}

class _RadarChart extends StatefulWidget {
  const _RadarChart({required this.scores});

  final List<RobleStudentResultCriterionScore> scores;

  @override
  State<_RadarChart> createState() => _RadarChartState();
}

class _RadarChartState extends State<_RadarChart> {
  int? _activeIndex;

  void _updateActiveIndex(Offset localPosition, Size size) {
    final index = _RadarChartPainter.hitTestIndex(
      localPosition: localPosition,
      size: size,
      scores: widget.scores,
    );
    setState(() => _activeIndex = index);
  }

  void _clearActiveIndex() {
    if (_activeIndex != null) {
      setState(() => _activeIndex = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final tooltipPosition = _activeIndex == null
            ? null
            : _RadarChartPainter.tooltipPositionForIndex(
                index: _activeIndex!,
                size: size,
                scores: widget.scores,
              );

        return MouseRegion(
          onHover: (event) => _updateActiveIndex(event.localPosition, size),
          onExit: (_) => _clearActiveIndex(),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) =>
                _updateActiveIndex(details.localPosition, size),
            onPanDown: (details) =>
                _updateActiveIndex(details.localPosition, size),
            onPanUpdate: (details) =>
                _updateActiveIndex(details.localPosition, size),
            onTap: () {},
            child: Stack(
              children: [
                CustomPaint(
                  painter: _RadarChartPainter(
                    scores: widget.scores,
                    activeIndex: _activeIndex,
                  ),
                  child: const SizedBox.expand(),
                ),
                if (_activeIndex != null && tooltipPosition != null)
                  Positioned(
                    left: tooltipPosition.dx,
                    top: tooltipPosition.dy,
                    child: IgnorePointer(
                      child: Container(
                        width: 94,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFFD3D3D3)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x16000000),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.scores[_activeIndex!].label,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Score : ${widget.scores[_activeIndex!].score.toStringAsFixed(1)}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RadarChartPainter extends CustomPainter {
  _RadarChartPainter({required this.scores, this.activeIndex});

  static const double _maxScore = 5;
  static const List<int> _scaleMarks = [2, 3, 4, 5];

  final List<RobleStudentResultCriterionScore> scores;
  final int? activeIndex;

  @override
  void paint(Canvas canvas, Size size) {
    if (scores.isEmpty) {
      return;
    }

    final center = _chartCenter(size);
    final radius = _chartRadius(size);
    final axisPaint = Paint()
      ..color = const Color(0xFF6F796D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final guidePaint = Paint()
      ..color = const Color(0xFFB7C3B5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final fillPaint = Paint()
      ..color = AppTheme.primaryGreen.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    final outlinePaint = Paint()
      ..color = AppTheme.primaryGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (final mark in _scaleMarks) {
      final ringPath = Path();
      for (var i = 0; i < scores.length; i++) {
        final point = pointForIndex(
          index: i,
          count: scores.length,
          center: center,
          radius: radius * (mark / _maxScore),
        );
        if (i == 0) {
          ringPath.moveTo(point.dx, point.dy);
        } else {
          ringPath.lineTo(point.dx, point.dy);
        }
      }
      ringPath.close();
      canvas.drawPath(ringPath, mark == _maxScore ? axisPaint : guidePaint);
    }

    for (var i = 0; i < scores.length; i++) {
      final point = pointForIndex(
        index: i,
        count: scores.length,
        center: center,
        radius: radius,
      );
      canvas.drawLine(center, point, axisPaint);
    }

    final scorePath = Path();
    for (var i = 0; i < scores.length; i++) {
      final point = pointForIndex(
        index: i,
        count: scores.length,
        center: center,
        radius: radius * (scores[i].score / _maxScore),
      );
      if (i == 0) {
        scorePath.moveTo(point.dx, point.dy);
      } else {
        scorePath.lineTo(point.dx, point.dy);
      }
    }
    scorePath.close();
    canvas.drawPath(scorePath, fillPaint);
    canvas.drawPath(scorePath, outlinePaint);

    final pointPaint = Paint()..color = AppTheme.primaryGreen;
    for (var i = 0; i < scores.length; i++) {
      final point = pointForIndex(
        index: i,
        count: scores.length,
        center: center,
        radius: radius * (scores[i].score / _maxScore),
      );
      canvas.drawCircle(point, activeIndex == i ? 4.5 : 3.5, pointPaint);
    }

    final labelStyle = const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppTheme.secondarySlate,
    );
    final tickStyle = const TextStyle(
      fontSize: 12,
      color: AppTheme.secondarySlate,
    );

    for (var i = 0; i < scores.length; i++) {
      _paintAxisLabel(
        canvas: canvas,
        size: size,
        center: center,
        radius: radius,
        index: i,
        count: scores.length,
        label: scores[i].label,
        style: labelStyle,
      );
    }

    _paintScaleLabel(
      canvas: canvas,
      center: center,
      radius: radius,
      mark: 0,
      style: tickStyle,
    );
    for (final mark in _scaleMarks) {
      _paintScaleLabel(
        canvas: canvas,
        center: center,
        radius: radius,
        mark: mark,
        style: tickStyle,
      );
    }
  }

  static int? hitTestIndex({
    required Offset localPosition,
    required Size size,
    required List<RobleStudentResultCriterionScore> scores,
  }) {
    if (scores.isEmpty) {
      return null;
    }

    final center = _chartCenter(size);
    final radius = _chartRadius(size);
    for (var i = 0; i < scores.length; i++) {
      final point = pointForIndex(
        index: i,
        count: scores.length,
        center: center,
        radius: radius * (scores[i].score / _maxScore),
      );
      if ((localPosition - point).distance <= 28) {
        return i;
      }
    }

    return null;
  }

  static Offset tooltipPositionForIndex({
    required int index,
    required Size size,
    required List<RobleStudentResultCriterionScore> scores,
  }) {
    final center = _chartCenter(size);
    final radius = _chartRadius(size);
    final point = pointForIndex(
      index: index,
      count: scores.length,
      center: center,
      radius: radius * (scores[index].score / _maxScore),
    );

    final left = max(10.0, min(size.width - 104, point.dx + 10));
    final top = max(10.0, min(size.height - 74, point.dy - 18));
    return Offset(left, top);
  }

  static Offset pointForIndex({
    required int index,
    required int count,
    required Offset center,
    required double radius,
  }) {
    final angle = (-90 + (360 / count) * index) * 3.141592653589793 / 180;
    return Offset(
      center.dx + radius * cos(angle),
      center.dy + radius * sin(angle),
    );
  }

  static double _chartRadius(Size size) {
    return size.shortestSide * 0.26;
  }

  static Offset _chartCenter(Size size) {
    return Offset(size.width / 2, size.height / 2 + 8);
  }

  void _paintAxisLabel({
    required Canvas canvas,
    required Size size,
    required Offset center,
    required double radius,
    required int index,
    required int count,
    required String label,
    required TextStyle style,
  }) {
    final direction = _axisDirection(index: index, count: count);
    final labelPoint = pointForIndex(
      index: index,
      count: count,
      center: center,
      radius: radius + 26,
    );
    final painter = TextPainter(
      text: TextSpan(text: label, style: style),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      maxLines: 2,
    )..layout(maxWidth: 110);

    double dx = labelPoint.dx - painter.width / 2;
    if (direction.dx > 0.45) {
      dx = labelPoint.dx + 8;
    } else if (direction.dx < -0.45) {
      dx = labelPoint.dx - painter.width - 8;
    }

    double dy = labelPoint.dy - painter.height / 2;
    if (direction.dy < -0.45) {
      dy = labelPoint.dy - painter.height - 10;
    } else if (direction.dy > 0.45) {
      dy = labelPoint.dy + 10;
    } else {
      dy = labelPoint.dy - painter.height / 2;
    }

    dx = dx.clamp(8.0, size.width - painter.width - 8.0);
    dy = dy.clamp(8.0, size.height - painter.height - 8.0);

    painter.paint(canvas, Offset(dx, dy));
  }

  void _paintScaleLabel({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required int mark,
    required TextStyle style,
  }) {
    final axisPoint = pointForIndex(
      index: 0,
      count: scores.length,
      center: center,
      radius: mark == 0 ? 0 : radius * (mark / _maxScore),
    );
    final painter = TextPainter(
      text: TextSpan(text: '$mark', style: style),
      textDirection: TextDirection.ltr,
    )..layout();

    final tickPaint = Paint()
      ..color = const Color(0xFF7B8977)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(axisPoint.dx - 6, axisPoint.dy),
      Offset(axisPoint.dx + 6, axisPoint.dy),
      tickPaint,
    );

    final dx = axisPoint.dx - painter.width - 12;
    final dy = axisPoint.dy - painter.height / 2;
    painter.paint(canvas, Offset(dx, dy));
  }

  Offset _axisDirection({required int index, required int count}) {
    final angle = (-90 + (360 / count) * index) * 3.141592653589793 / 180;
    return Offset(cos(angle), sin(angle));
  }

  @override
  bool shouldRepaint(covariant _RadarChartPainter oldDelegate) {
    return oldDelegate.scores != scores ||
        oldDelegate.activeIndex != activeIndex;
  }
}
