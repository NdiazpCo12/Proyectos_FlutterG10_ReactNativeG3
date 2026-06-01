part of 'teacher_home_view.dart';

class _TeacherReports extends StatelessWidget {
  const _TeacherReports({required this.controller});

  final TeacherHomeController controller;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.refreshReports,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 120),
        children: [
          Container(
            color: AppTheme.primaryGreen,
            child: SafeArea(
              bottom: false,
              child: const Padding(
                padding: EdgeInsets.fromLTRB(22, 24, 22, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Analytics Hub',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'View assessment insights and trends',
                      style: TextStyle(fontSize: 16, color: Color(0xFFDDE9DE)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
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
                return _SurfaceCard(
                  borderRadius: 20,
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No assessments available',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Create an assessment first to start viewing analytics and results here.',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final selectedCourseId =
                  controller.selectedAnalyticsCourseId.value;
              final selectedAssessmentId =
                  controller.selectedAnalyticsAssessmentId.value;
              final selectedOverview =
                  controller.selectedAnalyticsAssessmentOverview;
              final analytics = controller.assessmentAnalytics.value;
              final selectedGroup = controller.selectedAnalyticsGroup;
              final filteredAssessments =
                  controller.filteredAnalyticsAssessments;

              return Column(
                children: [
                  _SurfaceCard(
                    borderRadius: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Course',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Choose the course you want to analyze before selecting a specific assessment.',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.textMuted,
                          ),
                        ),
                        const SizedBox(height: 18),
                        DropdownButtonFormField<String>(
                          key: ValueKey(
                            'course-picker-${selectedCourseId ?? 'none'}',
                          ),
                          initialValue:
                              selectedCourseId != null &&
                                  selectedCourseId.trim().isNotEmpty
                              ? selectedCourseId
                              : null,
                          isExpanded: true,
                          hint: const Text('Choose a course'),
                          icon: const Icon(Icons.keyboard_arrow_down_rounded),
                          decoration: const InputDecoration(),
                          items: controller.courses
                              .map(
                                (course) => DropdownMenuItem<String>(
                                  value: course.id,
                                  child: Text(
                                    '${course.code} - ${course.name}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: controller.selectAnalyticsCourse,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _SurfaceCard(
                    borderRadius: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Assessment',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          selectedCourseId == null ||
                                  selectedCourseId.trim().isEmpty
                              ? 'Pick a course first to see only the assessments that belong to it.'
                              : 'Choose which assessment you want to review inside the selected course.',
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppTheme.textMuted,
                          ),
                        ),
                        const SizedBox(height: 18),
                        DropdownButtonFormField<String>(
                          key: ValueKey(
                            'assessment-picker-${selectedCourseId ?? 'none'}-${selectedAssessmentId ?? 'none'}',
                          ),
                          initialValue:
                              selectedAssessmentId != null &&
                                  selectedAssessmentId.trim().isNotEmpty
                              ? selectedAssessmentId
                              : null,
                          isExpanded: true,
                          hint: const Text('Choose an assessment'),
                          icon: const Icon(Icons.keyboard_arrow_down_rounded),
                          decoration: const InputDecoration(),
                          items: filteredAssessments
                              .map(
                                (assessment) => DropdownMenuItem<String>(
                                  value: assessment.assessment.id ?? '',
                                  child: Text(
                                    assessment.assessment.name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: filteredAssessments.isEmpty
                              ? null
                              : controller.selectAnalyticsAssessment,
                        ),
                        if (selectedOverview != null) ...[
                          const SizedBox(height: 18),
                          _TeacherInfoRow(
                            icon: Icons.school_outlined,
                            text:
                                '${selectedOverview.course.code} - ${selectedOverview.course.name}',
                          ),
                          const SizedBox(height: 12),
                          _TeacherInfoRow(
                            icon: Icons.groups_outlined,
                            text: selectedOverview.categoryName,
                          ),
                          const SizedBox(height: 12),
                          _TeacherInfoRow(
                            icon: Icons.fact_check_outlined,
                            text:
                                '${selectedOverview.statusLabel} - ${selectedOverview.responsesSubmitted}/${selectedOverview.totalReviewers} responses',
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (selectedCourseId == null ||
                      selectedCourseId.trim().isEmpty)
                    _SurfaceCard(
                      borderRadius: 20,
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ready to explore results',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Choose a course first and then an assessment to open the analytics.',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (filteredAssessments.isEmpty)
                    _SurfaceCard(
                      borderRadius: 20,
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'No assessments in this course',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Create an assessment for this course to start viewing analytics here.',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (selectedAssessmentId == null ||
                      selectedAssessmentId.trim().isEmpty)
                    _SurfaceCard(
                      borderRadius: 20,
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Assessment pending selection',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Choose an assessment from the selected course to view engagement, averages, team performance and detailed breakdowns.',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (controller.isLoadingAnalytics.value)
                    const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    )
                  else if (analytics == null)
                    _SurfaceCard(
                      borderRadius: 20,
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'No analytics available',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'We could not load the results for this assessment right now.',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    _TeacherAssessmentAnalyticsContent(
                      analytics: analytics,
                      selectedGroup: selectedGroup,
                      onGroupChanged: controller.selectAnalyticsGroup,
                      expandedStudentId:
                          controller.expandedAnalyticsStudentId.value,
                      onStudentToggle: controller.toggleAnalyticsStudent,
                    ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _TeacherAssessmentAnalyticsContent extends StatelessWidget {
  const _TeacherAssessmentAnalyticsContent({
    required this.analytics,
    required this.selectedGroup,
    required this.onGroupChanged,
    required this.expandedStudentId,
    required this.onStudentToggle,
  });

  final RobleTeacherAssessmentAnalytics analytics;
  final RobleTeacherAssessmentGroupAnalytics? selectedGroup;
  final ValueChanged<String?> onGroupChanged;
  final String? expandedStudentId;
  final ValueChanged<String> onStudentToggle;

  @override
  Widget build(BuildContext context) {
    final criterionBars = _buildCriterionBars(analytics);
    final teamBars = _buildTeamBars(analytics);
    final overview = analytics.detail.overview;
    final students = selectedGroup?.students ?? const [];

    return Column(
      children: [
        _MetricSummaryCard(
          icon: Icons.trending_up,
          title: 'Overall Engagement',
          value: '${(analytics.engagementRate * 100).round()}%',
          subtitle:
              '${overview.responsesSubmitted}/${overview.totalReviewers} students submitted',
        ),
        const SizedBox(height: 14),
        _MetricSummaryCard(
          icon: Icons.people_outline,
          title: 'Average Score',
          value: analytics.averageScore.toStringAsFixed(1),
          subtitle: analytics.averageScore > 0 ? 'Out of 5.0' : 'No scores yet',
        ),
        const SizedBox(height: 14),
        _ChartCard(
          title: 'Activity Average',
          subtitle: 'Average scores by criterion',
          bars: criterionBars,
          tooltipLabel: criterionBars.isNotEmpty
              ? criterionBars.first.label
              : '',
          tooltipValue: criterionBars.isNotEmpty
              ? 'average : ${criterionBars.first.value.toStringAsFixed(1)}'
              : '',
        ),
        const SizedBox(height: 14),
        _ChartCard(
          title: 'Team Performance',
          subtitle: 'Average scores by team',
          bars: teamBars,
          tooltipLabel: teamBars.isNotEmpty ? teamBars.first.label : '',
          tooltipValue: teamBars.isNotEmpty
              ? 'average : ${teamBars.first.value.toStringAsFixed(1)}'
              : '',
        ),
        const SizedBox(height: 14),
        _SurfaceCard(
          borderRadius: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Detailed Breakdown',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'View individual student scores',
                style: TextStyle(fontSize: 16, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 18),
              if (analytics.groups.isEmpty)
                const Text(
                  'No groups available for this assessment yet.',
                  style: TextStyle(fontSize: 15, color: AppTheme.textMuted),
                )
              else ...[
                DropdownButtonFormField<String>(
                  key: ValueKey(
                    'group-picker-${analytics.detail.overview.assessment.id ?? 'none'}-${selectedGroup?.groupId ?? 'none'}',
                  ),
                  initialValue: selectedGroup?.groupId,
                  isExpanded: true,
                  decoration: const InputDecoration(),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  items: analytics.groups
                      .map(
                        (group) => DropdownMenuItem<String>(
                          value: group.groupId,
                          child: Text(group.groupName),
                        ),
                      )
                      .toList(),
                  onChanged: onGroupChanged,
                ),
                const SizedBox(height: 16),
                if (students.isEmpty)
                  const Text(
                    'No students found in this team.',
                    style: TextStyle(fontSize: 15, color: AppTheme.textMuted),
                  )
                else
                  ...students.map(
                    (student) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _StudentBreakdownCard(
                        student: _BreakdownStudent(
                          id: student.studentId,
                          initials: student.initials,
                          name: student.name,
                          average: student.averageScore,
                          details: student.criteriaScores,
                        ),
                        expanded: expandedStudentId == student.studentId,
                        onToggle: () => onStudentToggle(student.studentId),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

List<_ChartBar> _buildCriterionBars(RobleTeacherAssessmentAnalytics analytics) {
  var highlightedIndex = -1;
  var highlightedValue = -1.0;

  for (var i = 0; i < analytics.criteriaAverages.length; i++) {
    final value = analytics.criteriaAverages[i].averageScore;
    if (value > highlightedValue) {
      highlightedValue = value;
      highlightedIndex = i;
    }
  }

  return List<_ChartBar>.generate(analytics.criteriaAverages.length, (index) {
    final criterion = analytics.criteriaAverages[index];
    return _ChartBar(
      label: criterion.label,
      value: criterion.averageScore,
      color: AppTheme.primaryGreen,
      highlighted: index == highlightedIndex,
    );
  });
}

List<_ChartBar> _buildTeamBars(RobleTeacherAssessmentAnalytics analytics) {
  var highlightedIndex = -1;
  var highlightedValue = -1.0;

  for (var i = 0; i < analytics.groups.length; i++) {
    final value = analytics.groups[i].averageScore;
    if (value > highlightedValue) {
      highlightedValue = value;
      highlightedIndex = i;
    }
  }

  return List<_ChartBar>.generate(analytics.groups.length, (index) {
    final group = analytics.groups[index];
    return _ChartBar(
      label: group.groupName,
      value: group.averageScore,
      color: AppTheme.secondarySlate,
      highlighted: index == highlightedIndex,
    );
  });
}
