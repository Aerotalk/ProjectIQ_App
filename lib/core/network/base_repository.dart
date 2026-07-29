import 'package:dio/dio.dart';
import '../errors/app_error.dart';

abstract class BaseRepository {
  Future<T> apiCall<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      if (e.error is AppError) {
        throw e.error as AppError;
      }
      throw AppError(
        type: AppErrorType.unknown,
        message: e.message ?? 'Unknown network error',
      );
    } catch (e) {
      throw AppError(
        type: AppErrorType.unknown,
        message: e.toString(),
      );
    }
  }
}
