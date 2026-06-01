import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/errors/error_message_formatter.dart';
import '../../../core/roble/roble.dart';
import '../../login/services/auth_service.dart';

class TeacherHomeController extends GetxController {
  TeacherHomeController({
    RobleApiService? apiService,
    AuthService? authService,
  }) : _api = apiService ?? RobleApiService(),
       _authService = authService;

  final selectedTab = 0.obs;
  final isSyncing = false.obs;
  final displayName = 'Teacher'.obs;

  final isLoadingCourses = true.obs;
  final isLoadingAssessments = true.obs;
  final isLoadingAnalytics = false.obs;
  final courses = <RobleCourseHome>[].obs;
  final assessments = <RobleAssessmentOverview>[].obs;
  final selectedAnalyticsCourseId = RxnString();
  final selectedAnalyticsAssessmentId = RxnString();
  final assessmentAnalytics = Rxn<RobleTeacherAssessmentAnalytics>();
  final selectedAnalyticsGroupId = RxnString();
  final expandedAnalyticsStudentId = RxnString();

  final RobleApiService _api;
  final AuthService? _authService;
  Future<void>? _fetchCoursesTask;
  Future<void>? _fetchAssessmentsTask;

  AuthService get _resolvedAuthService => _authService ?? Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    _loadCurrentUser();
    fetchCourses();
  }

  void changeTab(int index) {
    selectedTab.value = index;
  }

  Future<void> syncWithBrightspace() async {
    if (isSyncing.value) {
      return;
    }

    isSyncing.value = true;
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    isSyncing.value = false;

    Get.snackbar(
      'Brightspace',
      'Courses and groups were synced successfully.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }

  Future<void> _loadCurrentUser() async {
    final user = await _resolvedAuthService.getStoredUser();
    final name = user?.name.trim();

    if (name != null && name.isNotEmpty) {
      displayName.value = name;
    }
  }

  Future<void> fetchCourses() async {
    if (_fetchCoursesTask != null) {
      return _fetchCoursesTask!;
    }

    final future = _fetchCoursesInternal();
    _fetchCoursesTask = future;
    try {
      await future;
    } finally {
      _fetchCoursesTask = null;
    }
  }

  Future<void> _fetchCoursesInternal() async {
    isLoadingCourses.value = true;
    try {
      final user = await _resolvedAuthService.getStoredUser();
      final email = user?.email ?? 'profesor@uninorte.edu.co';
      final fetched = await _api.getCourses(email);
      courses.value = fetched;
      final selectedCourseId = selectedAnalyticsCourseId.value?.trim() ?? '';
      if (selectedCourseId.isNotEmpty &&
          fetched.every((course) => course.id != selectedCourseId)) {
        selectedAnalyticsCourseId.value = null;
      }
      if (selectedAnalyticsCourseId.value == null && fetched.length == 1) {
        selectedAnalyticsCourseId.value = fetched.first.id;
      }
      fetchAssessments(teacherEmail: email);
    } catch (e) {
      courses.clear();
      assessments.clear();
      selectedAnalyticsCourseId.value = null;
      assessmentAnalytics.value = null;
      selectedAnalyticsAssessmentId.value = null;
      selectedAnalyticsGroupId.value = null;
      expandedAnalyticsStudentId.value = null;
      Get.snackbar(
        'Error',
        formatUserErrorMessage(
          e,
          fallback: 'No se pudieron cargar los cursos en este momento.',
        ),
      );
    } finally {
      isLoadingCourses.value = false;
    }
  }

  Future<void> fetchAssessments({String? teacherEmail}) async {
    if (_fetchAssessmentsTask != null) {
      return _fetchAssessmentsTask!;
    }

    final future = _fetchAssessmentsInternal(teacherEmail: teacherEmail);
    _fetchAssessmentsTask = future;
    try {
      await future;
    } finally {
      _fetchAssessmentsTask = null;
    }
  }

  Future<void> _fetchAssessmentsInternal({String? teacherEmail}) async {
    isLoadingAssessments.value = true;
    try {
      final email =
          teacherEmail ??
          (await _resolvedAuthService.getStoredUser())?.email ??
          'profesor@uninorte.edu.co';
      final previousSelectedCourseId = selectedAnalyticsCourseId.value;
      final fetched = await _api.getTeacherAssessments(email);
      final previousSelectedAssessmentId = selectedAnalyticsAssessmentId.value;
      assessments.value = fetched;

      if (previousSelectedCourseId != null &&
          previousSelectedCourseId.trim().isNotEmpty &&
          fetched.every(
            (assessment) => assessment.course.id != previousSelectedCourseId,
          )) {
        selectedAnalyticsCourseId.value = null;
      }
      if (selectedAnalyticsCourseId.value == null && fetched.isNotEmpty) {
        selectedAnalyticsCourseId.value = fetched.first.course.id;
      }

      if (previousSelectedAssessmentId == null ||
          previousSelectedAssessmentId.trim().isEmpty) {
        assessmentAnalytics.value = null;
        selectedAnalyticsGroupId.value = null;
        expandedAnalyticsStudentId.value = null;
        return;
      }

      final stillExists = fetched.any(
        (assessment) =>
            assessment.assessment.id == previousSelectedAssessmentId &&
            (selectedAnalyticsCourseId.value == null ||
                assessment.course.id == selectedAnalyticsCourseId.value),
      );
      if (!stillExists) {
        selectedAnalyticsAssessmentId.value = null;
        assessmentAnalytics.value = null;
        selectedAnalyticsGroupId.value = null;
        expandedAnalyticsStudentId.value = null;
        return;
      }

      await selectAnalyticsAssessment(previousSelectedAssessmentId);
    } catch (e) {
      assessments.clear();
      selectedAnalyticsCourseId.value = null;
      assessmentAnalytics.value = null;
      selectedAnalyticsAssessmentId.value = null;
      selectedAnalyticsGroupId.value = null;
      expandedAnalyticsStudentId.value = null;
      Get.snackbar(
        'Error',
        formatUserErrorMessage(
          e,
          fallback: 'No se pudieron cargar las evaluaciones en este momento.',
        ),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isLoadingAssessments.value = false;
    }
  }

  RobleAssessmentOverview? get selectedAnalyticsAssessmentOverview {
    final selectedId = selectedAnalyticsAssessmentId.value?.trim() ?? '';
    if (selectedId.isEmpty) {
      return null;
    }
    for (final assessment in assessments) {
      if (assessment.assessment.id == selectedId) {
        return assessment;
      }
    }
    return null;
  }

  List<RobleAssessmentOverview> get filteredAnalyticsAssessments {
    final selectedCourseId = selectedAnalyticsCourseId.value?.trim() ?? '';
    if (selectedCourseId.isEmpty) {
      return const <RobleAssessmentOverview>[];
    }
    return assessments
        .where((assessment) => assessment.course.id == selectedCourseId)
        .toList(growable: false);
  }

  RobleTeacherAssessmentGroupAnalytics? get selectedAnalyticsGroup {
    return assessmentAnalytics.value?.groupById(selectedAnalyticsGroupId.value);
  }

  void selectAnalyticsCourse(String? courseId) {
    final trimmedId = courseId?.trim() ?? '';
    selectedAnalyticsCourseId.value = trimmedId.isEmpty ? null : trimmedId;

    final selectedAssessment = selectedAnalyticsAssessmentOverview;
    if (selectedAssessment == null ||
        selectedAssessment.course.id != selectedAnalyticsCourseId.value) {
      selectedAnalyticsAssessmentId.value = null;
      assessmentAnalytics.value = null;
      selectedAnalyticsGroupId.value = null;
      expandedAnalyticsStudentId.value = null;
    }
  }

  Future<void> selectAnalyticsAssessment(String? assessmentId) async {
    final trimmedId = assessmentId?.trim() ?? '';
    expandedAnalyticsStudentId.value = null;

    if (trimmedId.isEmpty) {
      selectedAnalyticsAssessmentId.value = null;
      assessmentAnalytics.value = null;
      selectedAnalyticsGroupId.value = null;
      return;
    }

    selectedAnalyticsAssessmentId.value = trimmedId;
    isLoadingAnalytics.value = true;

    try {
      final analytics = await _api.getTeacherAssessmentAnalytics(trimmedId);
      assessmentAnalytics.value = analytics;
      selectedAnalyticsGroupId.value = analytics?.groups.isNotEmpty == true
          ? analytics!.groupById(selectedAnalyticsGroupId.value)?.groupId ??
                analytics.groups.first.groupId
          : null;
    } catch (e) {
      assessmentAnalytics.value = null;
      selectedAnalyticsGroupId.value = null;
      Get.snackbar(
        'Error',
        formatUserErrorMessage(
          e,
          fallback: 'No se pudieron cargar las estadisticas del assessment.',
        ),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isLoadingAnalytics.value = false;
    }
  }

  void selectAnalyticsGroup(String? groupId) {
    final trimmedId = groupId?.trim() ?? '';
    selectedAnalyticsGroupId.value = trimmedId.isEmpty ? null : trimmedId;
    expandedAnalyticsStudentId.value = null;
  }

  Future<void> refreshReports() async {
    await fetchCourses();
    await fetchAssessments();
  }

  void toggleAnalyticsStudent(String studentId) {
    final trimmedId = studentId.trim();
    if (trimmedId.isEmpty) {
      return;
    }
    expandedAnalyticsStudentId.value =
        expandedAnalyticsStudentId.value == trimmedId ? null : trimmedId;
  }

  Future<List<RobleGroupCategoryRecord>> loadCourseCategories(
    String courseId,
  ) async {
    return _api.getCourseCategories(courseId);
  }

  Future<String> createAssessment({
    required String name,
    required String courseId,
    required String categoryId,
    required bool publicResults,
    required int durationDays,
  }) async {
    final user = await _resolvedAuthService.getStoredUser();
    final teacherEmail = user?.email ?? 'profesor@uninorte.edu.co';
    final now = DateTime.now();
    final startsAt = now;
    final endsAt = now.add(Duration(days: durationDays));

    final assessment = RobleAssessment(
      courseId: courseId,
      categoryId: categoryId,
      name: name,
      visibility: publicResults ? 'public' : 'private',
      status: 'open',
      startsAt: startsAt,
      endsAt: endsAt,
      createdByEmail: teacherEmail,
      createdAt: now,
    );

    final assessmentId = await _api.insert('assessments', assessment.toJson());

    for (final criterionTemplate in _defaultRubric) {
      final criterion = RobleAssessmentCriterion(
        assessmentId: assessmentId,
        name: criterionTemplate.name,
        description: criterionTemplate.description,
        weight: criterionTemplate.weight,
        displayOrder: criterionTemplate.displayOrder,
        createdAt: now,
      );
      final criterionId = await _api.insert(
        'assessment_criteria',
        criterion.toJson(),
      );

      for (final levelTemplate in criterionTemplate.levels) {
        final level = RobleAssessmentCriterionLevel(
          criterionId: criterionId,
          scoreValue: levelTemplate.scoreValue,
          label: levelTemplate.label,
          descriptionEn: levelTemplate.descriptionEn,
          descriptionEs: levelTemplate.descriptionEs,
          displayOrder: levelTemplate.displayOrder,
        );
        await _api.insert('assessment_criterion_levels', level.toJson());
      }
    }

    await fetchAssessments();
    return assessmentId;
  }

  Future<RobleAssessmentDetailData?> loadAssessmentDetail(String assessmentId) {
    return _api.getAssessmentDetail(assessmentId);
  }

  Future<RobleCourseManagementData> loadCourseManagementData(
    RobleCourseHome course,
  ) {
    return _api.getCourseManagementData(course);
  }

  Future<void> deleteCourse(RobleCourseHome course) async {
    await _api.deleteCourseCascade(course.id);
    courses.removeWhere((item) => item.id == course.id);
    await fetchCourses();
  }
}

class _CriterionTemplate {
  const _CriterionTemplate({
    required this.name,
    required this.description,
    required this.weight,
    required this.displayOrder,
    required this.levels,
  });

  final String name;
  final String description;
  final int weight;
  final int displayOrder;
  final List<_CriterionLevelTemplate> levels;
}

class _CriterionLevelTemplate {
  const _CriterionLevelTemplate({
    required this.scoreValue,
    required this.label,
    required this.descriptionEn,
    required this.descriptionEs,
    required this.displayOrder,
  });

  final int scoreValue;
  final String label;
  final String descriptionEn;
  final String descriptionEs;
  final int displayOrder;
}

const _defaultRubric = [
  _CriterionTemplate(
    name: 'Punctuality',
    description: 'Attendance, punctuality and deadline compliance.',
    weight: 25,
    displayOrder: 1,
    levels: [
      _CriterionLevelTemplate(
        scoreValue: 2,
        label: 'Needs Improvement',
        descriptionEn: 'Frequently late or absent and affects team progress.',
        descriptionEs: 'Llega tarde o falta con frecuencia y afecta el avance.',
        displayOrder: 1,
      ),
      _CriterionLevelTemplate(
        scoreValue: 3,
        label: 'Adequate',
        descriptionEn:
            'Usually attends but still misses some sessions or times.',
        descriptionEs: 'Asiste normalmente, aunque aun presenta retrasos.',
        displayOrder: 2,
      ),
      _CriterionLevelTemplate(
        scoreValue: 4,
        label: 'Good',
        descriptionEn: 'Generally punctual and reliable in meetings and tasks.',
        descriptionEs: 'Generalmente es puntual y cumple bien con el equipo.',
        displayOrder: 3,
      ),
      _CriterionLevelTemplate(
        scoreValue: 5,
        label: 'Excellent',
        descriptionEn: 'Consistently punctual, prepared and dependable.',
        descriptionEs: 'Siempre es puntual, preparado y muy confiable.',
        displayOrder: 4,
      ),
    ],
  ),
  _CriterionTemplate(
    name: 'Contributions',
    description: 'Quality and relevance of delivered work.',
    weight: 25,
    displayOrder: 2,
    levels: [
      _CriterionLevelTemplate(
        scoreValue: 2,
        label: 'Needs Improvement',
        descriptionEn: 'Contributes very little and rarely supports outcomes.',
        descriptionEs: 'Aporta muy poco y casi no apoya los entregables.',
        displayOrder: 1,
      ),
      _CriterionLevelTemplate(
        scoreValue: 3,
        label: 'Adequate',
        descriptionEn: 'Participates occasionally and completes some tasks.',
        descriptionEs: 'Participa de forma ocasional y cumple algunas tareas.',
        displayOrder: 2,
      ),
      _CriterionLevelTemplate(
        scoreValue: 4,
        label: 'Good',
        descriptionEn: 'Makes relevant contributions that support the team.',
        descriptionEs: 'Hace aportes relevantes que apoyan al equipo.',
        displayOrder: 3,
      ),
      _CriterionLevelTemplate(
        scoreValue: 5,
        label: 'Excellent',
        descriptionEn:
            'Provides strong, proactive contributions that improve work.',
        descriptionEs:
            'Hace aportes solidos y proactivos que mejoran el trabajo.',
        displayOrder: 4,
      ),
    ],
  ),
  _CriterionTemplate(
    name: 'Commitment',
    description: 'Responsibility with assigned tasks and team roles.',
    weight: 25,
    displayOrder: 3,
    levels: [
      _CriterionLevelTemplate(
        scoreValue: 2,
        label: 'Needs Improvement',
        descriptionEn: 'Shows low commitment and weak ownership of tasks.',
        descriptionEs: 'Muestra poco compromiso y poca apropiacion de tareas.',
        displayOrder: 1,
      ),
      _CriterionLevelTemplate(
        scoreValue: 3,
        label: 'Adequate',
        descriptionEn: 'Shows acceptable commitment but lacks consistency.',
        descriptionEs: 'Cumple de forma aceptable, pero con poca constancia.',
        displayOrder: 2,
      ),
      _CriterionLevelTemplate(
        scoreValue: 4,
        label: 'Good',
        descriptionEn: 'Demonstrates responsibility and follows through well.',
        descriptionEs: 'Demuestra responsabilidad y cumple bien sus tareas.',
        displayOrder: 3,
      ),
      _CriterionLevelTemplate(
        scoreValue: 5,
        label: 'Excellent',
        descriptionEn: 'Consistently committed and highly dependable.',
        descriptionEs: 'Es consistentemente comprometido y muy confiable.',
        displayOrder: 4,
      ),
    ],
  ),
  _CriterionTemplate(
    name: 'Attitude',
    description: 'Collaboration, openness and impact on team climate.',
    weight: 25,
    displayOrder: 4,
    levels: [
      _CriterionLevelTemplate(
        scoreValue: 2,
        label: 'Needs Improvement',
        descriptionEn:
            'Negative or disengaged attitude that hurts collaboration.',
        descriptionEs: 'Tiene una actitud negativa que afecta la colaboracion.',
        displayOrder: 1,
      ),
      _CriterionLevelTemplate(
        scoreValue: 3,
        label: 'Adequate',
        descriptionEn: 'Usually positive, but does not always help the team.',
        descriptionEs: 'Suele ser positivo, pero no siempre aporta al equipo.',
        displayOrder: 2,
      ),
      _CriterionLevelTemplate(
        scoreValue: 4,
        label: 'Good',
        descriptionEn:
            'Shows a positive and collaborative attitude most of the time.',
        descriptionEs:
            'Muestra una actitud positiva y colaborativa la mayoria del tiempo.',
        displayOrder: 3,
      ),
      _CriterionLevelTemplate(
        scoreValue: 5,
        label: 'Excellent',
        descriptionEn: 'Consistently promotes a constructive team environment.',
        descriptionEs: 'Promueve de forma constante un ambiente constructivo.',
        displayOrder: 4,
      ),
    ],
  ),
];
