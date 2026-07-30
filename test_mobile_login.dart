import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

void main() async {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://projectiqbackend-production.up.railway.app',
    contentType: 'application/json',
  ));
  
  // Mimic mobile cookie handling
  final cookieJar = CookieJar();
  dio.interceptors.add(CookieManager(cookieJar));
  
  try {
    print('Calling login...');
    final loginRes = await dio.post('/api/auth/login', data: {
      'email': 'reeya_2002@gmail.com',
      'password': 'Paromita@2611',
    });
    print('Login Response: ${loginRes.statusCode}');
    
    // Check if cookies were stored
    final cookies = await cookieJar.loadForRequest(Uri.parse('https://projectiqbackend-production.up.railway.app/api/auth/login'));
    print('Stored Cookies: ${cookies.map((c) => c.name).toList()}');
    
    print('Calling /api/auth/me to verify session...');
    final meRes = await dio.get('/api/auth/me');
    print('Me Response: ${meRes.statusCode}');
    print('Me Data: ${meRes.data}');
    
    print('Mobile flow works perfectly!');
  } on DioException catch (e) {
    print('Dio Error: ${e.message}');
    print('Response status: ${e.response?.statusCode}');
    print('Response data: ${e.response?.data}');
  } catch (e) {
    print('Error: $e');
  }
}
