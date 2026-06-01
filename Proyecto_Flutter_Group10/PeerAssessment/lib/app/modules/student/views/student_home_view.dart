import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/errors/error_message_formatter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/roble/roble.dart';
import '../../login/bindings/login_binding.dart';
import '../../login/models/auth_user.dart';
import '../../login/services/auth_service.dart';
import '../../login/views/login_view.dart';

part 'student_dashboard_view.dart';
part 'student_shared_widgets.dart';
part 'student_assessments_view.dart';
part 'student_results_view.dart';
part 'student_profile_view.dart';

class StudentHomeView extends StatefulWidget {
  const StudentHomeView({
    super.key,
    RobleApiService? apiService,
    AuthService? authService,
  }) : _apiService = apiService,
       _authService = authService;

  final RobleApiService? _apiService;
  final AuthService? _authService;

  @override
  State<StudentHomeView> createState() => _StudentHomeViewState();
}

class _StudentHomeViewState extends State<StudentHomeView> {
  int _selectedIndex = 0;
  bool _isSyncing = false;
  bool _emailNotifications = true;
  bool _assessmentReminders = true;
  bool _newResults = true;
  String _displayName = 'Student';
  bool _isLoadingCourses = true;
  bool _isLoadingAssessments = true;
  bool _isLoadingResults = true;
  List<StudentCourseEnrollment> _courses = [];
  List<RobleStudentAssessmentAssignment> _assessments = [];
  RobleStudentResultsSummary _resultsSummary = RobleStudentResultsSummary.empty;
  late final RobleApiService _api =
      widget._apiService ?? RobleApiService();

  AuthService get _authService => widget._authService ?? Get.find<AuthService>();

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _refreshStudentData();
  }

  Future<void> _refreshStudentData() async {
    await Future.wait<void>([
      _fetchCourses(),
      _fetchAssessments(),
      _fetchResults(),
    ]);
  }

  Future<void> _fetchCourses() async {
    setState(() => _isLoadingCourses = true);
    try {
      final user = await _authService.getStoredUser();
      final email = user?.email ?? '';
      final fetched = await _api.getStudentEnrollments(email);
      if (!mounted) return;
      setState(() {
        _courses = fetched;
        _isLoadingCourses = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingCourses = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            formatUserErrorMessage(
              e,
              fallback: 'No se pudo cargar la informacion del curso.',
            ),
          ),
        ),
      );
    }
  }

  Future<void> _fetchAssessments() async {
    setState(() => _isLoadingAssessments = true);
    try {
      final user = await _authService.getStoredUser();
      final email = user?.email ?? '';
      final fetched = await _api.getStudentAssessments(email);
      if (!mounted) return;
      setState(() {
        _assessments = fetched;
        _isLoadingAssessments = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingAssessments = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            formatUserErrorMessage(
              e,
              fallback: 'No se pudieron cargar las evaluaciones.',
            ),
          ),
        ),
      );
    }
  }

  Future<void> _fetchResults() async {
    setState(() => _isLoadingResults = true);
    try {
      final user = await _authService.getStoredUser();
      final email = user?.email ?? '';
      final fetched = await _api.getStudentResults(email);
      if (!mounted) return;
      setState(() {
        _resultsSummary = fetched;
        _isLoadingResults = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _resultsSummary = RobleStudentResultsSummary.empty;
        _isLoadingResults = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            formatUserErrorMessage(
              e,
              fallback: 'No se pudieron cargar tus resultados.',
            ),
          ),
        ),
      );
    }
  }

  Future<void> _submitAssessment(
    RobleStudentAssessmentAssignment assessment,
    Map<String, Map<String, int>> scoresByReviewee,
  ) async {
    await _api.submitStudentAssessment(
      assignment: assessment,
      scoresByReviewee: scoresByReviewee,
    );
    await _fetchAssessments();
  }

  Future<void> _loadCurrentUser() async {
    final user = await _authService.getStoredUser();
    final name = user?.name.trim();

    if (!mounted || name == null || name.isEmpty) {
      return;
    }

    setState(() {
      _displayName = name;
    });
  }

  Future<void> _sync() async {
    if (_isSyncing) {
      return;
    }

    setState(() => _isSyncing = true);
    await _refreshStudentData();
    if (!mounted) return;

    setState(() => _isSyncing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Courses synced successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _StudentDashboard(
            isSyncing: _isSyncing,
            isLoadingCourses: _isLoadingCourses,
            onSync: _sync,
            courses: _courses,
            displayName: _displayName,
          ),
          _StudentAssessmentsView(
            assessments: _assessments,
            isLoading: _isLoadingAssessments,
            onRefresh: _fetchAssessments,
            onSubmitAssessment: _submitAssessment,
          ),
          _StudentResultsView(
            summary: _resultsSummary,
            isLoading: _isLoadingResults,
            onRefresh: _fetchResults,
          ),
          _StudentProfile(
            emailNotifications: _emailNotifications,
            assessmentReminders: _assessmentReminders,
            newResults: _newResults,
            onEmailNotificationsChanged: (value) {
              setState(() => _emailNotifications = value);
            },
            onAssessmentRemindersChanged: (value) {
              setState(() => _assessmentReminders = value);
            },
            onNewResultsChanged: (value) {
              setState(() => _newResults = value);
            },
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Assessments',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Results',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
