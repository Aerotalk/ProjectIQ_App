import 'package:dio/dio.dart';

void main() async {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://projectiqbackend-production.up.railway.app',
    contentType: 'application/json',
  ));
  
  try {
    print('Calling setup-super-admin...');
    final response = await dio.post('/api/auth/setup-super-admin', data: {
      'username': 'super_admin',
      'email': 'admin@bumbleerp.com',
      'password': 'password',
    });
    print('Response: ${response.statusCode}');
    print('Data: ${response.data}');
  } on DioException catch (e) {
    print('Dio Error: ${e.message}');
    print('Response status: ${e.response?.statusCode}');
    print('Response data: ${e.response?.data}');
  } catch (e) {
    print('Error: $e');
  }
}
