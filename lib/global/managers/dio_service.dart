import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'token_manager.dart';

class DioService {
  static final Dio _dio = Dio(
    BaseOptions(baseUrl: 'http://192.168.1.57:5002/api', connectTimeout: const Duration(seconds: 10), receiveTimeout: const Duration(seconds: 10), contentType: 'application/json'),
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
        onError: (DioException e, handler) {
          handler.next(e);
        },
      ),
    );
  }

  static Dio get dio => _dio;
}
