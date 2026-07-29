import 'package:dio/dio.dart';
import 'app_error.dart';

class ErrorHandler {
  static AppError handle(dynamic error) {
    if (error is AppError) {
      return error;
    }

    if (error is DioException) {
      return _handleDioError(error);
    }

    return AppError(
      type: AppErrorType.unknown,
      message: 'An unexpected error occurred.',
      details: error.toString(),
    );
  }

  static AppError _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return AppError(
          type: AppErrorType.network,
          message: 'Network connection failed. Please check your internet.',
        );
      case DioExceptionType.badResponse:
        return _handleResponseError(error.response);
      case DioExceptionType.cancel:
        return AppError(
          type: AppErrorType.unknown,
          message: 'Request was cancelled.',
        );
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
      default:
        return AppError(
          type: AppErrorType.unknown,
          message: 'An unknown network error occurred.',
          details: error.message,
        );
    }
  }

  static AppError _handleResponseError(Response? response) {
    if (response == null) {
      return AppError(
        type: AppErrorType.server,
        message: 'Server did not respond.',
      );
    }

    final statusCode = response.statusCode;
    final message = _extractMessage(response.data) ?? 'Server error occurred.';

    if (statusCode == 401) {
      return AppError(
        type: AppErrorType.unauthorized,
        message: 'Unauthorized access. Please login again.',
        statusCode: statusCode,
      );
    } else if (statusCode == 403) {
      return AppError(
        type: AppErrorType.forbidden,
        message: 'You do not have permission to access this resource.',
        statusCode: statusCode,
      );
    } else if (statusCode == 404) {
      return AppError(
        type: AppErrorType.notFound,
        message: 'The requested resource was not found.',
        statusCode: statusCode,
      );
    } else if (statusCode == 422) {
      return AppError(
        type: AppErrorType.validation,
        message: message,
        statusCode: statusCode,
        details: response.data,
      );
    } else if (statusCode != null && statusCode >= 500) {
      return AppError(
        type: AppErrorType.server,
        message: 'Server error. Please try again later.',
        statusCode: statusCode,
      );
    }

    return AppError(
      type: AppErrorType.unknown,
      message: message,
      statusCode: statusCode,
    );
  }

  static String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('message')) {
      return data['message'].toString();
    }
    return null;
  }
}
