import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import '../environment/app_config.dart';

final secureStorageProvider = Provider((ref) => const FlutterSecureStorage());

// Create a singleton cookie jar for persistence on mobile
final cookieJarProvider = Provider<CookieJar>((ref) {
  // We don't initialize the directory here because it's async, we will do it in main or lazily
  return CookieJar();
});

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.instance.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: 'application/json',
      // Required for web to send cookies
      extra: const {'withCredentials': true},
    ),
  );

  // Add CookieManager only on non-web platforms because the browser handles cookies automatically on web
  if (!kIsWeb) {
    dio.interceptors.add(CookieManager(ref.read(cookieJarProvider)));
  }

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Dio overrides the baseUrl path if the request path starts with a slash.
        // To fix this, we ensure the path always starts with /api if it doesn't already.
        if (options.path.startsWith('/')) {
           options.path = '/api${options.path}';
        } else if (!options.path.startsWith('http')) {
           options.path = '/api/${options.path}';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          // Token expired or invalid
          // Typically we would trigger logout here, which we can do by listening to a stream or notifying a service.
        }
        return handler.next(e);
      },
    ),
  );

  return dio;
});
