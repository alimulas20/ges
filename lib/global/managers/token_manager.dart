import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../pages/login/models/token_response.dart';
import '../../pages/login/services/auth_service.dart';
import '../../pages/profile/model/user_model.dart';
import '../../pages/profile/service/user_service.dart';
import 'dio_service.dart';

class TokenManager {
  static const _storage = FlutterSecureStorage();
  static final _authService = AuthService();

  static GlobalKey<NavigatorState> get navigatorKey => DioService.navigatorKey;

  /// Saves tokens and user data securely
  static Future<void> saveToken(TokenResponse token) async {
    final accessToken = token.accessToken;
    Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);

    // Extract user data from token
    String userId = decodedToken['sub'] ?? '';
    bool isAdmin = false;

    final aud = decodedToken['aud'];
    if (aud is String) {
      isAdmin = aud == 'realm-management';
    } else if (aud is List) {
      isAdmin = aud.contains('realm-management');
    }

    // Extract groups
    List<String> groups = [];
    if (decodedToken.containsKey('group')) {
      final groupValue = decodedToken['group'];
      if (groupValue is List) {
        groups = List<String>.from(groupValue.map((e) => e.toString()));
      } else if (groupValue is String) {
        groups = [groupValue];
      }
    }

    // Calculate expiration times (convert seconds to milliseconds)
    final expiresAt = DateTime.now().add(Duration(seconds: token.expiresIn)).millisecondsSinceEpoch;
    final refreshExpiresAt = DateTime.now().add(Duration(seconds: token.refreshExpiresIn)).millisecondsSinceEpoch;

    // Save all data
    await Future.wait([
      _storage.write(key: 'user_groups', value: groups.join(',')),
      _storage.write(key: 'access_token', value: token.accessToken),
      _storage.write(key: 'refresh_token', value: token.refreshToken),
      _storage.write(key: 'expires_in', value: token.expiresIn.toString()),
      _storage.write(key: 'refresh_expires_in', value: token.refreshExpiresIn.toString()),
      _storage.write(key: 'token_type', value: token.tokenType),
      _storage.write(key: 'session_state', value: token.sessionState),
      _storage.write(key: 'scope', value: token.scope.join(' ')),
      _storage.write(key: 'expires_at', value: expiresAt.toString()),
      _storage.write(key: 'refresh_expires_at', value: refreshExpiresAt.toString()),
      _storage.write(key: 'user_id', value: userId),
      _storage.write(key: 'is_admin', value: isAdmin.toString()),
    ]);
  }

  /// Clears all stored tokens and user data
  static Future<void> clearToken() async {
    await _storage.deleteAll();
  }

  /// Retrieves authentication data
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

  /// Gets access token, handles refresh if needed, or redirects to login
  static Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  /// Checks if user is admin
  static Future<bool> getIsAdmin() async {
    final isAdminStr = await _storage.read(key: 'is_admin');
    return isAdminStr == 'true';
  }

  /// Gets user ID
  static Future<String?> getUserId() async {
    return await _storage.read(key: 'user_id');
  }

  /// Gets user groups
  static Future<List<String>> getGroups() async {
    final groupStr = await _storage.read(key: 'user_groups');
    return groupStr?.split(',').where((e) => e.isNotEmpty).toList() ?? [];
  }

  /// Gets user roles from token
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

  /// Gets admin plants if user is admin
  static Future<List<UserPlantDto>> getAdminPlants() async {
    if (!(await getIsAdmin())) return [];

    try {
      final currentUser = await UserService().getCurrentUser();
      return currentUser.plants;
    } catch (e) {
      debugPrint('Error getting admin plants: $e');
      return [];
    }
  }

  /// Helper method to redirect to login page
  static void _redirectToLogin() {
    navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
  }
}
