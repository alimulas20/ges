import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:solar/global/constant/url_constant.dart';
import '../../pages/login/services/auth_service.dart';
import 'token_manager.dart';

class DioService {
  static final Dio _dio = Dio(
    BaseOptions(baseUrl: UrlConstants.getApiUrl(), connectTimeout: const Duration(seconds: 10), receiveTimeout: const Duration(seconds: 10), contentType: 'application/json'),
  );

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Token refresh işleminin devam edip etmediğini takip etmek için
  static bool _isRefreshing = false;
  static final List<RequestOptions> _pendingRequests = [];

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
            // Eğer refresh işlemi zaten devam ediyorsa, isteği beklemeye al
            if (_isRefreshing) {
              _pendingRequests.add(e.requestOptions);
              return;
            }

            _isRefreshing = true;
            final originalRequest = e.requestOptions;

            try {
              final newToken = await AuthService().refreshAccessToken();

              if (newToken != null) {
                // Tüm bekleyen istekleri yeni token ile güncelle
                _isRefreshing = false;
                _retryAllPendingRequests(newToken);

                // Orijinal isteği tekrarla
                originalRequest.headers['Authorization'] = 'Bearer $newToken';
                final retryResponse = await _dio.fetch(originalRequest);
                return handler.resolve(retryResponse);
              } else {
                await _handleTokenExpiration();
                return handler.next(e);
              }
            } catch (refreshError) {
              debugPrint('Token refresh failed: $refreshError');
              _isRefreshing = false;
              _pendingRequests.clear();
              await _handleTokenExpiration();
              return handler.next(e);
            }
          }

          handler.next(e);
        },
      ),
    );
  }

  static void _retryAllPendingRequests(String newToken) {
    for (final requestOptions in _pendingRequests) {
      requestOptions.headers['Authorization'] = 'Bearer $newToken';
      _dio.fetch(requestOptions).catchError((error) {
        debugPrint('Retry request failed: $error');
      });
    }
    _pendingRequests.clear();
  }

  static Future<void> _handleTokenExpiration() async {
    await TokenManager.clearToken();
    if (navigatorKey.currentState != null) {
      navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  static Dio get dio => _dio;
}
