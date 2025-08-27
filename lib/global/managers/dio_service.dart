import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:solar/global/constant/url_constant.dart';
import '../../pages/login/services/auth_service.dart';
import 'token_manager.dart';

class DioService {
  static final Dio _dio = Dio(
    BaseOptions(baseUrl: UrlConstants.getApiUrl(), connectTimeout: const Duration(seconds: 10), receiveTimeout: const Duration(seconds: 10), contentType: 'application/json'),
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
          // 401 Unauthorized hatası ve refresh denemesi yapılmamışsa
          if (e.response?.statusCode == 401 && !e.requestOptions.path.contains('refresh')) {
            // Orijinal isteği sakla
            final originalRequest = e.requestOptions;
            try {
              final newToken = await AuthService().refreshAccessToken();

              if (newToken != null) {
                // Yeni token ile orijinal isteği tekrarla
                originalRequest.headers['Authorization'] = 'Bearer $newToken';
                final retryResponse = await _dio.fetch(originalRequest);
                return handler.resolve(retryResponse);
              }
            } catch (refreshError) {
              debugPrint('Token refresh failed: $refreshError');
            }

            // Refresh başarısız olduysa logout yap
            await _handleTokenExpiration();
          }

          // Diğer hataları veya başarısız refresh durumunu ileri taşı
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
