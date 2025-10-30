import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:solar/global/constant/url_constant.dart';

import '../../pages/login/services/auth_service.dart';
import 'token_manager.dart';

class DioService {
  static final Dio _dio = Dio(
    BaseOptions(baseUrl: UrlConstants.getApiUrl(), connectTimeout: const Duration(seconds: 10), receiveTimeout: const Duration(seconds: 20), contentType: 'application/json'),
  );

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static bool _isRefreshing = false;
  static final List<({RequestOptions options, ErrorInterceptorHandler handler})> _pendingRequests = [];

  static void init() {
    _dio.interceptors.clear();
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          debugPrint('Request: ${options.method} ${options.path}');
          final token = await TokenManager.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (DioException e, handler) async {
          debugPrint('Error: ${e.response?.statusCode} ${e.requestOptions.path}');

          // Refresh endpoint'ine istek yapıyorsak veya 401 değilse direkt geç
          if (e.response?.statusCode != 401 || e.requestOptions.path.contains('refresh')) {
            return handler.next(e);
          }

          // Eğer refresh işlemi zaten devam ediyorsa, isteği beklemeye al
          if (_isRefreshing) {
            debugPrint('Refresh already in progress, adding to pending requests');
            _pendingRequests.add((options: e.requestOptions, handler: handler));
            return;
          }

          _isRefreshing = true;
          debugPrint('Starting token refresh...');

          try {
            final newToken = await AuthService().refreshAccessToken();

            if (newToken != null) {
              debugPrint('Token refresh successful');
              _isRefreshing = false;

              // Önce orijinal isteği tekrarla
              e.requestOptions.headers['Authorization'] = 'Bearer $newToken';
              final retryResponse = await _dio.fetch(e.requestOptions);

              // Sonra bekleyen tüm istekleri işle
              await _retryAllPendingRequests(newToken);

              return handler.resolve(retryResponse);
            } else {
              debugPrint('Token refresh returned null');
              await _handleTokenExpiration();
              return handler.next(e);
            }
          } catch (refreshError) {
            debugPrint('Token refresh failed: $refreshError');
            _isRefreshing = false;
            await _handleTokenExpiration();

            // Tüm bekleyen isteklere hata dön
            _rejectAllPendingRequests(refreshError);

            return handler.next(e);
          }
        },
      ),
    );
  }

  static Future<void> _retryAllPendingRequests(String newToken) async {
    debugPrint('Retrying ${_pendingRequests.length} pending requests');

    for (final pending in _pendingRequests) {
      try {
        pending.options.headers['Authorization'] = 'Bearer $newToken';
        final response = await _dio.fetch(pending.options);
        pending.handler.resolve(response);
      } catch (error) {
        pending.handler.next(DioException(requestOptions: pending.options, error: error));
      }
    }
    _pendingRequests.clear();
  }

  static void _rejectAllPendingRequests(dynamic error) {
    debugPrint('Rejecting ${_pendingRequests.length} pending requests');

    for (final pending in _pendingRequests) {
      pending.handler.next(DioException(requestOptions: pending.options, error: error));
    }
    _pendingRequests.clear();
  }

  static Future<void> _handleTokenExpiration() async {
    debugPrint('Handling token expiration - logging out');
    await TokenManager.clearToken();

    // Navigator'ı kullanmadan önce kontroller yap
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (navigatorKey.currentState != null && navigatorKey.currentState!.mounted) {
        navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
      }
    });
  }

  static Dio get dio => _dio;

  // Debug için pending requests sayısını göster
  static int get pendingRequestsCount => _pendingRequests.length;
  static bool get isRefreshing => _isRefreshing;
}
