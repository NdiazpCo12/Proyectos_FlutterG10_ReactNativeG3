import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:login/app/core/roble/roble.dart';
import 'package:login/app/modules/login/services/auth_service.dart';
import 'package:login/app/modules/teacher/controllers/create_course_controller.dart';
import 'package:login/app/modules/teacher/controllers/teacher_home_controller.dart';
import 'package:login/app/modules/teacher/views/teacher_home_view.dart';

import '../../helpers/fake_auth_service.dart';
import '../../helpers/test_app.dart';
import '../../helpers/test_bootstrap.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TeacherHomeView', () {
    Future<void> pumpTeacherHome(
      WidgetTester tester,
      _FakeTeacherHomeController controller,
    ) async {
      SharedPreferences.setMockInitialValues({});
      await bootstrapTestEnvironment(tester);
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      Get.put<AuthService>(FakeAuthService());
      Get.put<TeacherHomeController>(controller);
      Get.put<CreateCourseController>(CreateCourseController());

      await tester.pumpWidget(buildTestApp(const TeacherHomeView()));
      await tester.pump();
    }

    testWidgets('renders navigation tabs and empty courses state', (
      tester,
    ) async {
      final controller = _FakeTeacherHomeController()
        ..displayName.value = 'Teacher Test'
        ..isLoadingCourses.value = false
        ..isLoadingAssessments.value = false;
      await pumpTeacherHome(tester, controller);

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Assessments'), findsOneWidget);
      expect(find.text('Results'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('No hay cursos registrados'), findsOneWidget);
      expect(find.text('Crear'), findsOneWidget);
    });

    testWidgets('changes tabs correctly', (tester) async {
      final controller = _FakeTeacherHomeController()
        ..isLoadingCourses.value = false
        ..isLoadingAssessments.value = false;
      await pumpTeacherHome(tester, controller);

      await tester.tap(find.text('Assessments'));
      await tester.pumpAndSettle();
      expect(find.text('Manage peer assessments'), findsOneWidget);

      await tester.tap(find.text('Results'));
      await tester.pumpAndSettle();
      expect(find.text('Analytics Hub'), findsOneWidget);

      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(find.text('Manage your account settings'), findsWidgets);
      expect(find.text('Log Out'), findsOneWidget);
    });

    testWidgets('shows loading indicator while courses load', (tester) async {
      final controller = _FakeTeacherHomeController()
        ..isLoadingCourses.value = true
        ..isLoadingAssessments.value = false;
      await pumpTeacherHome(tester, controller);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}

class _FakeTeacherHomeController extends TeacherHomeController {
  _FakeTeacherHomeController()
    : super(apiService: _FakeRobleApiService(), authService: FakeAuthService());

  @override
  Future<void> fetchCourses() async {}
}

class _FakeRobleApiService extends RobleApiService {}
