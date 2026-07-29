import 'package:dio/dio.dart';
import '../errors/error_handler.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Translate Dio exceptions to AppErrors before passing them up
    final appError = ErrorHandler.handle(err);
    // Since Dio requires DioException, we wrap it or handle it at the repo level
    // We can attach the AppError to the DioException's error property
    final wrappedError = err.copyWith(error: appError);
    super.onError(wrappedError, handler);
  }
}
