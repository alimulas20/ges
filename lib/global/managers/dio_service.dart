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
  static final Dio _keycloak = Dio(
    BaseOptions(baseUrl: 'https://pms-demo.smartplant360.com/keycloak', connectTimeout: const Duration(seconds: 10), receiveTimeout: const Duration(seconds: 10), contentType: 'application/json'),
  );
  static void init(BuildContext context) {
    _dio.interceptors.clear();
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenManager.getAccessToken(context);
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
                // Yeni token'ı ekle, isteği tekrar yap
                final newRequest = e.requestOptions;
                newRequest.headers['Authorization'] = 'Bearer $newAccessToken';

                try {
                  final retryResponse = await _dio.fetch(newRequest);
                  return handler.resolve(retryResponse); // Yeni yanıtı döndür
                } catch (err) {
                  // Tekrar deneme de başarısız oldu
                  await TokenManager.clearToken();
                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                  return;
                }
              }
            }

            // refresh token de yoksa veya işe yaramadıysa
            await TokenManager.clearToken();
            Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            return;
          }
          handler.next(e);
        },
      ),
    );
    _keycloak.interceptors.clear();
    _keycloak.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenManager.getAccessToken(context);
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
                // Yeni token'ı ekle, isteği tekrar yap
                final newRequest = e.requestOptions;
                newRequest.headers['Authorization'] = 'Bearer $newAccessToken';

                try {
                  final retryResponse = await _dio.fetch(newRequest);
                  return handler.resolve(retryResponse); // Yeni yanıtı döndür
                } catch (err) {
                  // Tekrar deneme de başarısız oldu
                  await TokenManager.clearToken();
                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                  return;
                }
              }
            }

            // refresh token de yoksa veya işe yaramadıysa
            await TokenManager.clearToken();
            Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            return;
          }

          handler.next(e); // Diğer hataları olduğu gibi geçir
        },
      ),
    );
  }

  static Dio get dio => _dio;
  static Dio get keyCloak => _keycloak;
}
