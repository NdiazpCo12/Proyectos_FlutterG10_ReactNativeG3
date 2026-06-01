import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:login/app/core/errors/auth_exception.dart';
import 'package:login/app/core/storage/session_storage_service.dart';
import 'package:login/app/modules/login/services/auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthService', () {
    late SessionStorageService storage;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      storage = SessionStorageService();
    });

    test('signIn stores session on success', () async {
      final service = AuthService(
        storage: storage,
        client: MockClient((request) async {
          expect(request.method, 'POST');
          expect(request.url.path.endsWith('/login'), isTrue);
          final payload = jsonDecode(request.body) as Map<String, dynamic>;
          expect(payload['email'], 'teacher@uninorte.edu.co');

          return http.Response(
            jsonEncode({
              'accessToken': 'access-token',
              'refreshToken': 'refresh-token',
              'user': {
                'id': 'teacher-1',
                'email': 'teacher@uninorte.edu.co',
                'name': 'Teacher Test',
                'role': 'teacher',
              },
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      );

      final session = await service.signIn(
        email: 'teacher@uninorte.edu.co',
        password: AuthService.defaultUserPassword,
      );

      expect(session.accessToken, 'access-token');
      expect(await storage.getAccessToken(), 'access-token');
      expect(await storage.getRefreshToken(), 'refresh-token');
      expect(
        await storage.getUser().then((value) => value?.email),
        'teacher@uninorte.edu.co',
      );
    });

    test('signIn throws AuthException when backend fails', () async {
      final service = AuthService(
        storage: storage,
        client: MockClient(
          (_) async => http.Response(
            jsonEncode({'message': 'Credenciales invalidas'}),
            401,
            headers: {'content-type': 'application/json'},
          ),
        ),
      );

      expect(
        () => service.signIn(
          email: 'teacher@uninorte.edu.co',
          password: AuthService.defaultUserPassword,
        ),
        throwsA(
          isA<AuthException>()
              .having((error) => error.message, 'message', 'Credenciales invalidas')
              .having((error) => error.statusCode, 'statusCode', 401),
        ),
      );
    });

    test('signIn throws when tokens are missing', () async {
      final service = AuthService(
        storage: storage,
        client: MockClient(
          (_) async => http.Response(
            jsonEncode({
              'accessToken': '',
              'refreshToken': '',
              'user': {
                'id': 'teacher-1',
                'email': 'teacher@uninorte.edu.co',
                'name': 'Teacher Test',
                'role': 'teacher',
              },
            }),
            200,
            headers: {'content-type': 'application/json'},
          ),
        ),
      );

      expect(
        () => service.signIn(
          email: 'teacher@uninorte.edu.co',
          password: AuthService.defaultUserPassword,
        ),
        throwsA(
          isA<AuthException>().having(
            (error) => error.message,
            'message',
            'No fue posible iniciar sesion en este momento.',
          ),
        ),
      );
    });

    test('verifyToken returns false when there is no access token', () async {
      final service = AuthService(
        storage: storage,
        client: MockClient((_) async => http.Response('', 500)),
      );

      expect(await service.verifyToken(), isFalse);
    });

    test('verifyToken returns true when backend returns 200', () async {
      await storage.saveAccessToken('access-token');
      final service = AuthService(
        storage: storage,
        client: MockClient((request) async {
          expect(request.headers['Authorization'], 'Bearer access-token');
          return http.Response('', 200);
        }),
      );

      expect(await service.verifyToken(), isTrue);
    });

    test('refreshToken stores renewed tokens', () async {
      await storage.saveTokens(
        accessToken: 'old-access-token',
        refreshToken: 'refresh-token',
      );
      final service = AuthService(
        storage: storage,
        client: MockClient(
          (_) async => http.Response(
            jsonEncode({
              'accessToken': 'new-access-token',
              'refreshToken': 'new-refresh-token',
            }),
            200,
            headers: {'content-type': 'application/json'},
          ),
        ),
      );

      final refreshed = await service.refreshToken();

      expect(refreshed, isTrue);
      expect(await storage.getAccessToken(), 'new-access-token');
      expect(await storage.getRefreshToken(), 'new-refresh-token');
    });

    test('logout clears session when backend succeeds', () async {
      await storage.saveTokens(
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
      );
      final service = AuthService(
        storage: storage,
        client: MockClient((request) async {
          expect(request.headers['Authorization'], 'Bearer access-token');
          return http.Response('', 204);
        }),
      );

      await service.logout();

      expect(await storage.getAccessToken(), isNull);
      expect(await storage.getRefreshToken(), isNull);
    });

    test('logout clears session immediately when no access token exists', () async {
      final service = AuthService(
        storage: storage,
        client: MockClient((_) async => http.Response('', 500)),
      );

      await service.logout();

      expect(await storage.getAccessToken(), isNull);
      expect(await storage.getRefreshToken(), isNull);
    });
  });
}
