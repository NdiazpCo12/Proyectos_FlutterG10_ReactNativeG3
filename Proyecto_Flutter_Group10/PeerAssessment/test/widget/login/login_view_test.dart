import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:login/app/core/storage/session_storage_service.dart';
import 'package:login/app/modules/login/controllers/login_controller.dart';
import 'package:login/app/modules/login/models/auth_session.dart';
import 'package:login/app/modules/login/models/auth_user.dart';
import 'package:login/app/modules/login/services/auth_service.dart';
import 'package:login/app/modules/login/views/login_view.dart';

import '../../helpers/test_app.dart';
import '../../helpers/test_bootstrap.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LoginView', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    Future<void> pumpLogin(
      WidgetTester tester,
      _FakeAuthService Function() authServiceBuilder,
    ) async {
      await bootstrapTestEnvironment(tester);
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });
      final authService = authServiceBuilder();
      Get.put<LoginController>(LoginController(authService: authService));
      await tester.pumpWidget(buildTestApp(const LoginView()));
      await tester.pump();
      await tester.ensureVisible(find.text('Sign In'));
    }

    testWidgets('renders the main login content', (tester) async {
      await pumpLogin(tester, () => _FakeAuthService());

      expect(find.text('Peer Assessment'), findsOneWidget);
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('shows loading indicator while sign in is in progress', (
      tester,
    ) async {
      final completer = Completer<AuthSession>();
      await pumpLogin(
        tester,
        () => _FakeAuthService(
          onSignIn: ({required email, required password}) => completer.future,
        ),
      );
      await tester.enterText(find.byType(TextField).first, 'teacher@test.edu');
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}

typedef _SignInHandler = Future<AuthSession> Function({
  required String email,
  required String password,
});

class _FakeAuthService extends AuthService {
  _FakeAuthService({
    _SignInHandler? onSignIn,
  }) : _onSignIn = onSignIn,
       super(
         storage: SessionStorageService(),
         client: MockClient((_) async => throw UnimplementedError()),
       );

  final _SignInHandler? _onSignIn;
  int signInCallCount = 0;

  @override
  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) {
    signInCallCount += 1;
    final handler = _onSignIn;
    if (handler != null) {
      return handler(email: email, password: password);
    }
    return Future<AuthSession>.value(_teacherSession);
  }

  @override
  Future<void> logout() async {}

  @override
  Future<AuthUser?> getStoredUser() async => _teacherSession.user;
}

const _teacherSession = AuthSession(
  accessToken: 'access-token',
  refreshToken: 'refresh-token',
  user: AuthUser(
    id: 'teacher-1',
    email: 'teacher@test.edu',
    name: 'Teacher Test',
    role: 'teacher',
  ),
);
