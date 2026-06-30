class AppException implements Exception {
  final String message;
  final String? code;

  const AppException({required this.message, this.code});

  factory AppException.timeout() => const AppException(
    message: 'Connection timed out. Please try again.',
    code: 'TIMEOUT',
  );

  factory AppException.noInternet() => const AppException(
    message: 'No internet connection. Please check your network.',
    code: 'NO_INTERNET',
  );

  factory AppException.unauthorized(String message) =>
      AppException(message: message, code: 'UNAUTHORIZED');

  factory AppException.notFound(String message) =>
      AppException(message: message, code: 'NOT_FOUND');

  factory AppException.serverError(String message) =>
      AppException(message: message, code: 'SERVER_ERROR');

  factory AppException.unknown(String message) =>
      AppException(message: message, code: 'UNKNOWN');

  @override
  String toString() => 'AppException($code): $message';
}
