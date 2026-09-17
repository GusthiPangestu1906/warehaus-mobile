import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthTokenStorage {
  final FlutterSecureStorage _secureStorage;

  static const _keyAccessToken = 'warehaus_access_token';
  static const _keyRefreshToken = 'warehaus_refresh_token';
  static const _keyUserProfile = 'warehaus_user_profile';

  AuthTokenStorage({FlutterSecureStorage? storage})
    : _secureStorage = storage ?? const FlutterSecureStorage();

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _secureStorage.write(key: _keyAccessToken, value: accessToken);
    await _secureStorage.write(key: _keyRefreshToken, value: refreshToken);
  }

  Future<void> saveUserProfile(Map<String, dynamic> userJson) async {
    await _secureStorage.write(
      key: _keyUserProfile,
      value: jsonEncode(userJson),
    );
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    final raw = await _secureStorage.read(key: _keyUserProfile);
    if (raw == null || raw.isEmpty) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _keyAccessToken);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _keyRefreshToken);
  }

  Future<void> clearTokens() async {
    await _secureStorage.delete(key: _keyAccessToken);
    await _secureStorage.delete(key: _keyRefreshToken);
    await _secureStorage.delete(key: _keyUserProfile);
  }

  Future<bool> hasToken() async {
    final accessToken = await getAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }
}
