import 'package:dio/dio.dart';
import '../../exceptions/app_exception.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw AppException.timeout();
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        final message = err.response?.data?['message'] as String?;
        if (statusCode == 401) {
          throw AppException.unauthorized(message ?? 'Unauthorized');
        } else if (statusCode == 404) {
          throw AppException.notFound(message ?? 'Not found');
        } else if (statusCode != null && statusCode >= 500) {
          throw AppException.serverError(message ?? 'Server error');
        }
        throw AppException.unknown(message ?? 'Something went wrong');
      case DioExceptionType.connectionError:
        throw AppException.noInternet();
      default:
        throw AppException.unknown(err.message ?? 'Unknown error');
    }
  }
}
