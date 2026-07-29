import 'package:dio/dio.dart';

class RetryPolicy {
  final int maxRetries;
  final Duration delay;

  const RetryPolicy({
    this.maxRetries = 3,
    this.delay = const Duration(seconds: 2),
  });

  bool shouldRetry(DioException err, int currentAttempt) {
    if (currentAttempt >= maxRetries) {
      return false;
    }
    
    // Only retry on network issues or 5xx server errors
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      return true;
    }

    if (err.response != null) {
      final statusCode = err.response!.statusCode;
      if (statusCode != null && statusCode >= 500) {
        return true;
      }
    }

    return false;
  }
}
