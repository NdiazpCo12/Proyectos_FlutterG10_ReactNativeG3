import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:login/app/core/storage/session_storage_service.dart';
import 'package:login/app/modules/login/controllers/login_controller.dart';
import 'package:login/app/modules/login/services/auth_service.dart';
import 'package:login/app/modules/login/views/login_view.dart';

import '../../helpers/test_app.dart';
import '../../helpers/test_bootstrap.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('completes login flow with real controller and service', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await bootstrapTestEnvironment(tester);
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    final storage = SessionStorageService();
    var openedTeacherHome = false;
    final authService = AuthService(
      storage: storage,
      client: MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path.endsWith('/login'), isTrue);

        final payload = jsonDecode(request.body) as Map<String, dynamic>;
        expect(payload['email'], 'teacher@test.edu');
        expect(payload['password'], AuthService.defaultUserPassword);

        return http.Response(
          jsonEncode({
            'accessToken': 'access-token',
            'refreshToken': 'refresh-token',
            'user': {
              'id': 'teacher-1',
              'email': 'teacher@test.edu',
              'name': 'Teacher Test',
              'role': 'teacher',
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    Get.put<LoginController>(
      LoginController(
        authService: authService,
        onOpenTeacherHome: () {
          openedTeacherHome = true;
        },
      ),
    );

    await tester.pumpWidget(buildTestApp(const LoginView()));
    await tester.pump();
    await tester.ensureVisible(find.text('Sign In'));

    await tester.enterText(find.byType(TextField).first, 'teacher@test.edu');
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(openedTeacherHome, isTrue);
    expect(await storage.getAccessToken(), 'access-token');
    expect(await storage.getRefreshToken(), 'refresh-token');
    expect(await storage.getUser().then((value) => value?.role), 'teacher');
  });
}
