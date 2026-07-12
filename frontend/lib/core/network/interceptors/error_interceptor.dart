import 'package:dio/dio.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Teruskan error ke caller — jangan throw di sini supaya provider
    // bisa membaca response.data (misal pesan error dari server).
    handler.next(err);
  }
}
