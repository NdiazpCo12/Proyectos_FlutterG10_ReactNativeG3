import 'package:http/testing.dart';

import 'package:login/app/core/storage/session_storage_service.dart';
import 'package:login/app/modules/login/models/auth_session.dart';
import 'package:login/app/modules/login/models/auth_user.dart';
import 'package:login/app/modules/login/services/auth_service.dart';

class FakeAuthService extends AuthService {
  FakeAuthService({
    AuthUser? storedUser,
    AuthSession? signInSession,
  }) : _storedUser =
           storedUser ??
           const AuthUser(
             id: 'user-1',
             email: 'teacher@test.edu',
             name: 'Test User',
             role: 'teacher',
           ),
       _signInSession =
           signInSession ??
           AuthSession(
             accessToken: 'access-token',
             refreshToken: 'refresh-token',
             user:
                 storedUser ??
                 const AuthUser(
                   id: 'user-1',
                   email: 'teacher@test.edu',
                   name: 'Test User',
                   role: 'teacher',
                 ),
           ),
       super(
         storage: SessionStorageService(),
         client: MockClient((_) async => throw UnimplementedError()),
       );

  final AuthUser _storedUser;
  final AuthSession _signInSession;

  @override
  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async {
    return _signInSession;
  }

  @override
  Future<void> logout() async {}

  @override
  Future<AuthUser?> getStoredUser() async => _storedUser;
}
