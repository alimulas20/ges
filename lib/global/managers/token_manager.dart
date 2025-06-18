import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../pages/login/models/token_response.dart';
import '../../pages/login/services/auth_service.dart';
import '../../pages/profile/model/user_model.dart';
import '../../pages/profile/service/user_service.dart';

class TokenManager {
  static const _storage = FlutterSecureStorage();
  static final _authService = AuthService();

  /// Token'ı güvenli şekilde saklar
  static Future<void> saveToken(TokenResponse token) async {
    final accessToken = token.accessToken;

    // Token'ı decode et
    Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);

    // Kullanıcı ID'si
    String userId = decodedToken['sub'] ?? '';
    // Admin kontrolü: aud içinde realm-management varsa admin kabul et
    bool isAdmin = false;

    final aud = decodedToken['aud'];
    if (aud is String) {
      isAdmin = aud == 'realm-management';
    } else if (aud is List) {
      isAdmin = aud.contains('realm-management');
    }
    List<String> groups = [];
    if (decodedToken.containsKey('group')) {
      final groupValue = decodedToken['group'];
      if (groupValue is List) {
        groups = List<String>.from(groupValue.map((e) => e.toString()));
      } else if (groupValue is String) {
        groups = [groupValue];
      }
    }

    await _storage.write(key: 'user_groups', value: groups.join(','));
    await _storage.write(key: 'access_token', value: token.accessToken);
    await _storage.write(key: 'refresh_token', value: token.refreshToken);
    await _storage.write(key: 'expires_in', value: token.expiresIn.toString());
    await _storage.write(key: 'refresh_expires_in', value: token.refreshExpiresIn.toString());
    await _storage.write(key: 'token_type', value: token.tokenType);
    await _storage.write(key: 'session_state', value: token.sessionState);
    await _storage.write(key: 'scope', value: token.scope.join(' '));
    await _storage.write(key: 'expires_at', value: (DateTime.now().millisecondsSinceEpoch + token.expiresIn * 1000).toString());

    // Eklenenler
    await _storage.write(key: 'user_id', value: userId);
    await _storage.write(key: 'is_admin', value: isAdmin.toString());
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
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      return null;
    }
  }

  /// Admin olup olmadığını getirir
  static Future<bool> getIsAdmin() async {
    final isAdminStr = await _storage.read(key: 'is_admin');
    return isAdminStr == 'true';
  }

  /// User ID'yi getirir
  static Future<String?> getUserId() async {
    return await _storage.read(key: 'user_id');
  }

  static Future<List<String>> getGroups() async {
    final groupStr = await _storage.read(key: 'user_groups');
    if (groupStr == null || groupStr.isEmpty) return [];
    return groupStr.split(',').where((e) => e.isNotEmpty).toList();
  }

  // TokenManager sınıfına bu metodu ekleyin
  static Future<List<String>> getRoles() async {
    final accessToken = await _storage.read(key: 'access_token');
    if (accessToken == null) return [];

    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);
      if (decodedToken.containsKey('realm_access') && decodedToken['realm_access'] is Map) {
        final realmAccess = decodedToken['realm_access'] as Map;
        if (realmAccess.containsKey('roles') && realmAccess['roles'] is List) {
          return List<String>.from(realmAccess['roles']);
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error decoding roles: $e');
      return [];
    }
  }

  static Future<List<UserPlantDto>> getAdminPlants() async {
    final isAdmin = await getIsAdmin();
    if (!isAdmin) return [];

    try {
      final currentUser = await UserService().getCurrentUser();
      return currentUser.plants;
    } catch (e) {
      debugPrint('Error getting admin plants: $e');
      return [];
    }
  }
}
