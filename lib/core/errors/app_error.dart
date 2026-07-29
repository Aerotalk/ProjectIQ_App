enum AppErrorType {
  network,
  server,
  unauthorized,
  forbidden,
  notFound,
  validation,
  unknown,
}

class AppError implements Exception {
  final AppErrorType type;
  final String message;
  final int? statusCode;
  final dynamic details;

  AppError({
    required this.type,
    required this.message,
    this.statusCode,
    this.details,
  });

  @override
  String toString() {
    return 'AppError: [$type] $message';
  }
}
