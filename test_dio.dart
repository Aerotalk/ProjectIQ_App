import 'package:dio/dio.dart';

void main() async {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
  
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      print('Interceptor options.path: ${options.path}');
      print('Interceptor options.uri: ${options.uri}');
      
      if (options.path.startsWith('/')) {
         options.path = '/api${options.path}';
      } else if (!options.path.startsWith('http')) {
         options.path = '/api/${options.path}';
      }
      
      print('Interceptor modified options.path: ${options.path}');
      print('Interceptor modified options.uri: ${options.uri}');
      return handler.next(options);
    }
  ));
  
  try {
    await dio.post('/auth/login');
  } catch (e) {
    print('Error: $e');
  }
}
