import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../pages/login/models/token_response.dart';
import '../../pages/login/services/auth_service.dart';

class TokenManager {
  static const _storage = FlutterSecureStorage();
  static final _authService = AuthService();

  /// Token'ı güvenli şekilde saklar
  static Future<void> saveToken(TokenResponse token) async {
    await _storage.write(key: 'access_token', value: token.accessToken);
    await _storage.write(key: 'refresh_token', value: token.refreshToken);
    await _storage.write(key: 'expires_in', value: token.expiresIn.toString());
    await _storage.write(key: 'refresh_expires_in', value: token.refreshExpiresIn.toString());
    await _storage.write(key: 'token_type', value: token.tokenType);
    await _storage.write(key: 'session_state', value: token.sessionState);
    await _storage.write(key: 'scope', value: token.scope.join(' '));
  }

  /// Token'ı siler
  static Future<void> clearToken() async {
    await _storage.deleteAll();
  }

  /// TokenResponse nesnesini getirir
  static Future<TokenResponse?> getAuth() async {
    final accessToken = await _storage.read(key: 'access_token');
    final refreshToken = await _storage.read(key: 'refresh_token');
    final expiresInStr = await _storage.read(key: 'expires_in');
    final refreshExpiresInStr = await _storage.read(key: 'refresh_expires_in');
    final tokenType = await _storage.read(key: 'token_type');
    final sessionState = await _storage.read(key: 'session_state');
    final scopeStr = await _storage.read(key: 'scope');

    if (accessToken == null || refreshToken == null || expiresInStr == null) {
      return null;
    }

    return TokenResponse(
      accessToken: accessToken,
      expiresIn: int.tryParse(expiresInStr) ?? 0,
      refreshToken: refreshToken,
      refreshExpiresIn: int.tryParse(refreshExpiresInStr ?? '0') ?? 0,
      tokenType: tokenType ?? '',
      sessionState: sessionState ?? '',
      scope: (scopeStr ?? '').split(' '),
    );
  }

  /// Access Token'ı verir, gerekiyorsa refresh eder, yoksa login'e yönlendirir
  static Future<String?> getAccessToken(BuildContext context) async {
    final token = await _authService.getToken();

    if (token != null) {
      return token;
    } else {
      // Refresh da başarısızsa login'e yönlendir
      final navigator = Navigator.of(context);
      navigator.pushNamedAndRemoveUntil('/login', (route) => false);
      return null;
    }
  }
}
