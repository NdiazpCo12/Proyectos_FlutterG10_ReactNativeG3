part of 'teacher_home_view.dart';

class _TeacherEvaluations extends StatelessWidget {
  const _TeacherEvaluations({required this.controller});

  final TeacherHomeController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 120),
      children: [
        Container(
          width: double.infinity,
          color: AppTheme.primaryGreen,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Assessments',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Manage peer assessments',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFFDDE9DE),
                          ),
                        ),
                      ],
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () async {
                      await Get.to(() => const TeacherEvaluationBuilderView());
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryGreen,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Create'),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 20, 12, 0),
          child: Obx(() {
            if (controller.isLoadingAssessments.value) {
              return const Padding(
                padding: EdgeInsets.all(40),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryGreen,
                  ),
                ),
              );
            }

            if (controller.assessments.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(40),
                child: Center(
                  child: Text(
                    'No hay assessments registrados.',
                    style: TextStyle(color: AppTheme.textMuted),
                  ),
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 0, 6, 14),
                  child: Text(
                    '${controller.assessments.length} assessments',
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppTheme.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ...controller.assessments.map(
                  (assessment) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _AssessmentCard(
                      assessment: assessment,
                      onView: () {
                        final assessmentId = assessment.assessment.id ?? '';
                        if (assessmentId.isEmpty) {
                          Get.snackbar(
                            'Assessment',
                            'El assessment no tiene un identificador valido.',
                            snackPosition: SnackPosition.BOTTOM,
                            margin: const EdgeInsets.all(16),
                          );
                          return;
                        }

                        Get.to(
                          () => TeacherAssessmentDetailView(
                            assessmentId: assessmentId,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }
}

class _AssessmentCard extends StatelessWidget {
  const _AssessmentCard({required this.assessment, required this.onView});

  final RobleAssessmentOverview assessment;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    final isActive = assessment.statusLabel == 'Active';
    final progress = assessment.completionProgress.clamp(0.0, 1.0);

    return InkWell(
      onTap: onView,
      borderRadius: BorderRadius.circular(18),
      child: _SurfaceCard(
        borderRadius: 18,
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _PillTag(
                  label: assessment.statusLabel,
                  color: isActive
                      ? AppTheme.primaryGreen
                      : assessment.statusLabel == 'Closed'
                      ? AppTheme.secondarySlate
                      : const Color(0xFF73C79B),
                ),
                const Spacer(),
                Icon(
                  assessment.visibilityLabel == 'Public'
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 18,
                  color: AppTheme.textMuted,
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onView,
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                  label: const Text('View'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              assessment.assessment.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Text(
              '${assessment.course.code} - ${assessment.course.name}',
              style: const TextStyle(fontSize: 16, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: AppTheme.textMuted,
                ),
                const SizedBox(width: 10),
                Text(
                  _formatAssessmentWindow(assessment.assessment),
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(
                  Icons.people_outline,
                  size: 18,
                  color: AppTheme.textMuted,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    assessment.categoryName,
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Completion',
                    style: TextStyle(fontSize: 15, color: AppTheme.textMuted),
                  ),
                ),
                Text(
                  '${assessment.responsesSubmitted}/${assessment.totalReviewers}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 8,
                value: progress,
                backgroundColor: const Color(0xFFE0E0E0),
                color: AppTheme.primaryGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatAssessmentWindow(RobleAssessment assessment) {
  final start = _formatShortDate(assessment.startsAt);
  final end = _formatShortDate(assessment.endsAt);
  return '$start - $end';
}

String _formatShortDate(DateTime value) {
  const monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final month = monthNames[value.month - 1];
  final day = value.day.toString().padLeft(2, '0');
  return '$month $day';
}
