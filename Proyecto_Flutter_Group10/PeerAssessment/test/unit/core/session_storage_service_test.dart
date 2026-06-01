import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:login/app/core/storage/session_storage_service.dart';
import 'package:login/app/modules/login/models/auth_user.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SessionStorageService', () {
    late SessionStorageService service;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      service = SessionStorageService();
    });

    test('stores and reads tokens', () async {
      await service.saveTokens(
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
      );

      expect(await service.getAccessToken(), 'access-token');
      expect(await service.getRefreshToken(), 'refresh-token');
    });

    test('stores and reads user', () async {
      const user = AuthUser(
        id: 'user-1',
        email: 'student@uninorte.edu.co',
        name: 'Student Test',
        role: 'student',
      );

      await service.saveUser(user);

      final storedUser = await service.getUser();

      expect(storedUser?.id, 'user-1');
      expect(storedUser?.email, 'student@uninorte.edu.co');
    });

    test('returns null when no user is stored', () async {
      expect(await service.getUser(), isNull);
    });

    test('clears the stored session', () async {
      await service.saveTokens(
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
      );
      await service.saveUser(
        const AuthUser(
          id: 'user-1',
          email: 'student@uninorte.edu.co',
          name: 'Student Test',
          role: 'student',
        ),
      );

      await service.clearSession();

      expect(await service.getAccessToken(), isNull);
      expect(await service.getRefreshToken(), isNull);
      expect(await service.getUser(), isNull);
    });
  });
}
