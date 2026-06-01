import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:login/app/core/roble/roble.dart';
import 'package:login/app/modules/login/models/auth_user.dart';
import 'package:login/app/modules/login/services/auth_service.dart';
import 'package:login/app/modules/student/views/student_home_view.dart';

import '../../helpers/fake_auth_service.dart';
import '../../helpers/test_app.dart';
import '../../helpers/test_bootstrap.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StudentHomeView', () {
    Future<void> pumpStudentHome(
      WidgetTester tester, {
      required RobleApiService api,
    }) async {
      SharedPreferences.setMockInitialValues({});
      await bootstrapTestEnvironment(tester);
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      final authService = FakeAuthService(
        storedUser: const AuthUser(
          id: 'student-1',
          email: 'student@test.edu',
          name: 'Student Test',
          role: 'student',
        ),
      );
      Get.put<AuthService>(authService);

      await tester.pumpWidget(
        buildTestApp(StudentHomeView(apiService: api, authService: authService)),
      );
      await tester.pump();
      await tester.pump();
    }

    testWidgets('renders tabs and empty dashboard state', (tester) async {
      await pumpStudentHome(tester, api: _FakeStudentRobleApiService());

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Assessments'), findsOneWidget);
      expect(find.text('Results'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('No hay cursos registrados'), findsOneWidget);
    });

    testWidgets('changes tabs and shows empty states', (tester) async {
      await pumpStudentHome(tester, api: _FakeStudentRobleApiService());

      await tester.tap(find.text('Assessments'));
      await tester.pumpAndSettle();
      expect(
        find.text('No tienes evaluaciones disponibles por ahora.'),
        findsOneWidget,
      );

      await tester.tap(find.text('Results'));
      await tester.pumpAndSettle();
      expect(
        find.text('No public results available yet for this course.'),
        findsOneWidget,
      );

      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(find.text('Manage your account settings'), findsWidgets);
      expect(find.text('Log Out'), findsOneWidget);
    });
  });
}

class _FakeStudentRobleApiService extends RobleApiService {
  @override
  Future<List<StudentCourseEnrollment>> getStudentEnrollments(
    String studentEmail,
  ) async {
    return const [];
  }

  @override
  Future<List<RobleStudentAssessmentAssignment>> getStudentAssessments(
    String studentEmail,
  ) async {
    return const [];
  }

  @override
  Future<RobleStudentResultsSummary> getStudentResults(String studentEmail) async {
    return RobleStudentResultsSummary.empty;
  }
}
