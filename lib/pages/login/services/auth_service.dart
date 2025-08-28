// auth_service.dart
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:solar/global/constant/url_constant.dart';
import 'package:solar/main.dart';
import '../../../global/managers/token_manager.dart';
import '../models/token_response.dart';
import '../models/login_model.dart';

class AuthService {
  final String _baseUrl = UrlConstants.baseUrl;
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
