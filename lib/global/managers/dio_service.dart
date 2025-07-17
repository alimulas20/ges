import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../pages/login/services/auth_service.dart';
import 'token_manager.dart';

class DioService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://pms-demo.smartplant360.com/services/logger',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: 'application/json',
    ),
  );

  // Store a navigator key globally
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static void init() {
    _dio.interceptors.clear();
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenManager.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            final auth = await TokenManager.getAuth();

            if (auth?.refreshToken != null) {
              final newAccessToken = await AuthService().refreshAccessToken();

              if (newAccessToken != null) {
                final newRequest = e.requestOptions;
                newRequest.headers['Authorization'] = 'Bearer $newAccessToken';

                try {
                  final retryResponse = await _dio.fetch(newRequest);
                  return handler.resolve(retryResponse);
                } catch (err) {
                  await _handleTokenExpiration();
                  return;
                }
              }
            }

            await _handleTokenExpiration();
            return;
          }
          handler.next(e);
        },
      ),
    );
  }

  static Future<void> _handleTokenExpiration() async {
    await TokenManager.clearToken();
    navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
  }

  static Dio get dio => _dio;
}
