// auth_service.dart
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:solar/main.dart';
import '../../../global/managers/token_manager.dart';
import '../models/token_response.dart';
import '../models/login_model.dart';

class AuthService {
  final String _baseUrl = 'https://pms-demo.smartplant360.com';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<TokenResponse> login(LoginModel model) async {
    final body = Uri(queryParameters: model.toJson()).query;

    final response = await http.post(Uri.parse('$_baseUrl/auth/login'), body: body, headers: {'Content-Type': 'application/x-www-form-urlencoded'});

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final token = TokenResponse.fromJson(jsonData);
      await TokenManager.saveToken(token);
      await MyApp().setupFirebaseToken();
      await MyApp().setupFirebaseMessaging();
      return token;
    } else {
      throw Exception('Login failed: ${response.statusCode}');
    }
  }

  Future<void> logout() async {
    await TokenManager.clearToken();
  }

  Future<String?> getToken() async {
    // Check if refresh token is expired
    final refreshExpiresAtStr = await _storage.read(key: 'refresh_expires_at');
    if (refreshExpiresAtStr == null) return null;

    final refreshExpiresAt = int.tryParse(refreshExpiresAtStr) ?? 0;
    if (DateTime.now().millisecondsSinceEpoch > refreshExpiresAt) {
      await logout();
      return null;
    }

    // Check if access token is expired
    final expiresAtStr = await _storage.read(key: 'expires_at');
    if (expiresAtStr == null) return null;

    final expiresAt = int.tryParse(expiresAtStr) ?? 0;
    if (DateTime.now().millisecondsSinceEpoch > expiresAt) {
      return await refreshAccessToken();
    }
    return await _storage.read(key: 'access_token');
  }

  Future<String?> refreshAccessToken() async {
    final refreshToken = await _storage.read(key: 'refresh_token');

    if (refreshToken == null) return null;

    final response = await http.post(
      Uri.parse('$_baseUrl/auth/refresh'),
      body: {'refresh_token': refreshToken}, // http package will encode this properly
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final token = TokenResponse.fromJson(jsonData);
      await TokenManager.saveToken(token);
      return token.accessToken;
    } else {
      await logout();
      return null;
    }
  }
}
