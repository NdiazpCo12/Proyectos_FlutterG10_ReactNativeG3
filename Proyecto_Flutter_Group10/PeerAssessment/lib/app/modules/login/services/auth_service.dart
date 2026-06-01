import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/roble/roble_config.dart';
import '../../../core/errors/auth_exception.dart';
import '../../../core/storage/session_storage_service.dart';
import '../models/auth_session.dart';
import '../models/auth_user.dart';

class AuthService {
  static const defaultUserPassword = 'ThePassword!1';

  AuthService({required SessionStorageService storage, http.Client? client})
    : _storage = storage,
      _client = client ?? http.Client();

  final SessionStorageService _storage;
  final http.Client _client;

  String get _baseUrl => RobleConfig.authBaseUrl;

  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/login'),
      headers: _jsonHeaders,
      body: jsonEncode({'email': email, 'password': password}),
    );

    final body = _decodeBody(response);

    if (_isSuccess(response.statusCode)) {
      final session = AuthSession.fromJson(body);
      if (session.accessToken.isEmpty || session.refreshToken.isEmpty) {
        throw AuthException('No fue posible iniciar sesion en este momento.');
      }
      await _storage.saveTokens(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
      );
      await _storage.saveUser(session.user);
      return session;
    }

    throw AuthException(
      _extractErrorMessage(body, fallback: 'No se pudo iniciar sesion.'),
      statusCode: response.statusCode,
    );
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    await _postWithoutAuth(
      endpoint: 'signup',
      payload: {'email': email, 'password': password, 'name': name},
      fallbackMessage: 'No se pudo completar el registro.',
    );
  }

  Future<void> signUpDirect({
    required String email,
    required String password,
    required String name,
  }) async {
    await _postWithoutAuth(
      endpoint: 'signup-direct',
      payload: {'email': email, 'password': password, 'name': name},
      fallbackMessage: 'No se pudo completar el registro.',
    );
  }

  Future<void> verifyEmail({
    required String email,
    required String code,
  }) async {
    await _postWithoutAuth(
      endpoint: 'verify-email',
      payload: {'email': email, 'code': code},
      fallbackMessage: 'No se pudo verificar el correo.',
    );
  }

  Future<void> forgotPassword(String email) async {
    await _postWithoutAuth(
      endpoint: 'forgot-password',
      payload: {'email': email},
      fallbackMessage: 'No se pudo procesar la solicitud.',
    );
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    await _postWithoutAuth(
      endpoint: 'reset-password',
      payload: {'token': token, 'newPassword': newPassword},
      fallbackMessage: 'No se pudo actualizar la contrasena.',
    );
  }

  Future<void> logout() async {
    final accessToken = await _storage.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      await _storage.clearSession();
      return;
    }

    final response = await _client.post(
      Uri.parse('$_baseUrl/logout'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (_isSuccess(response.statusCode)) {
      await _storage.clearSession();
      return;
    }

    final body = _decodeBody(response);
    throw AuthException(
      _extractErrorMessage(body, fallback: 'No se pudo cerrar la sesion.'),
      statusCode: response.statusCode,
    );
  }

  Future<bool> verifyToken() async {
    final accessToken = await _storage.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      return false;
    }

    final response = await _client.get(
      Uri.parse('$_baseUrl/verify-token'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    return response.statusCode == 200;
  }

  Future<bool> refreshToken() async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    final response = await _client.post(
      Uri.parse('$_baseUrl/refresh-token'),
      headers: _jsonHeaders,
      body: jsonEncode({'refreshToken': refreshToken}),
    );

    final body = _decodeBody(response);

    if (_isSuccess(response.statusCode)) {
      final newAccessToken = body['accessToken'] as String?;
      final newRefreshToken = body['refreshToken'] as String? ?? refreshToken;

      if (newAccessToken == null || newAccessToken.isEmpty) {
        throw AuthException('No fue posible renovar la sesion.');
      }

      await _storage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );
      return true;
    }

    throw AuthException(
      _extractErrorMessage(body, fallback: 'No fue posible renovar la sesion.'),
      statusCode: response.statusCode,
    );
  }

  Future<void> clearLocalSession() {
    return _storage.clearSession();
  }

  Future<AuthUser?> getStoredUser() {
    return _storage.getUser();
  }

  Future<void> _postWithoutAuth({
    required String endpoint,
    required Map<String, dynamic> payload,
    required String fallbackMessage,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: _jsonHeaders,
      body: jsonEncode(payload),
    );

    if (_isSuccess(response.statusCode)) {
      return;
    }

    final body = _decodeBody(response);
    throw AuthException(
      _extractErrorMessage(body, fallback: fallbackMessage),
      statusCode: response.statusCode,
    );
  }

  Map<String, String> get _jsonHeaders => const {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  bool _isSuccess(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }

  Map<String, dynamic> _decodeBody(http.Response response) {
    if (response.body.isEmpty) {
      return <String, dynamic>{};
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return <String, dynamic>{'data': decoded};
    } catch (_) {
      return <String, dynamic>{'message': response.body};
    }
  }

  String _extractErrorMessage(
    Map<String, dynamic> body, {
    required String fallback,
  }) {
    final message = body['message'];
    if (message is String && message.trim().isNotEmpty) {
      return message;
    }

    if (message is List && message.isNotEmpty) {
      return message.join(', ');
    }

    return fallback;
  }
}
