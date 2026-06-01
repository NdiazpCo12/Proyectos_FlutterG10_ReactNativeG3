import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../modules/login/models/auth_user.dart';

class SessionStorageService {
  SessionStorageService() : _preferences = SharedPreferences.getInstance();

  static const _accessTokenKey = 'accessToken';
  static const _refreshTokenKey = 'refreshToken';
  static const _userKey = 'user';

  final Future<SharedPreferences> _preferences;

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final preferences = await _preferences;
    await preferences.setString(_accessTokenKey, accessToken);
    await preferences.setString(_refreshTokenKey, refreshToken);
  }

  Future<void> saveAccessToken(String accessToken) async {
    final preferences = await _preferences;
    await preferences.setString(_accessTokenKey, accessToken);
  }

  Future<String?> getAccessToken() async {
    final preferences = await _preferences;
    return preferences.getString(_accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    final preferences = await _preferences;
    return preferences.getString(_refreshTokenKey);
  }

  Future<void> saveUser(AuthUser user) async {
    final preferences = await _preferences;
    await preferences.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<AuthUser?> getUser() async {
    final preferences = await _preferences;
    final rawUser = preferences.getString(_userKey);
    if (rawUser == null || rawUser.isEmpty) {
      return null;
    }

    final decoded = jsonDecode(rawUser);
    if (decoded is! Map<String, dynamic>) {
      return null;
    }

    return AuthUser.fromJson(decoded);
  }

  Future<void> clearSession() async {
    final preferences = await _preferences;
    await preferences.remove(_accessTokenKey);
    await preferences.remove(_refreshTokenKey);
    await preferences.remove(_userKey);
  }
}
