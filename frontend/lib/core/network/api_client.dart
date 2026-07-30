import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';

/// Singleton HTTP client.
/// Panggil [initialize] sekali di awal atau setiap kali baseUrl berubah.
class ApiClient {
  ApiClient._();

  static final ApiClient _instance = ApiClient._();
  static ApiClient get instance => _instance;

  Dio? _dio;

  Dio get dio {
    // Auto-init jika belum ada
    if (_dio == null) initialize();
    return _dio!;
  }

  void initialize({String? token}) {
    final url = AppConstants.baseUrl;
    if (kDebugMode) debugPrint('ApiClient → baseUrl: $url');

    _dio = Dio(
      BaseOptions(
        baseUrl: url,
        connectTimeout: const Duration(
          milliseconds: AppConstants.connectTimeout,
        ),
        receiveTimeout: const Duration(
          milliseconds: AppConstants.receiveTimeout,
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio!.interceptors.addAll([
      AuthInterceptor(token: token),
      ErrorInterceptor(),
      LoggingInterceptor(),
    ]);
  }

  void updateToken(String? token) {
    _dio?.interceptors.removeWhere((i) => i is AuthInterceptor);
    _dio?.interceptors.add(AuthInterceptor(token: token));
  }
}
