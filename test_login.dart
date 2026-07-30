import 'package:dio/dio.dart';
import 'lib/features/authentication/domain/user.dart';

void main() async {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://projectiqbackend-production.up.railway.app',
    contentType: 'application/json',
  ));
  
  try {
    print('Calling login...');
    final response = await dio.post('/api/auth/login', data: {
      'email': 'reeya_2002@gmail.com',
      'password': 'Paromita@2611',
    });
    print('Response: ${response.statusCode}');
    print('Data: ${response.data}');
    
    // Test parsing
    final user = User.fromJson(response.data);
    print('Parsed User: ${user.username}');
  } on DioException catch (e) {
    print('Dio Error: ${e.message}');
    print('Response status: ${e.response?.statusCode}');
    print('Response data: ${e.response?.data}');
  } catch (e) {
    print('Error: $e');
  }
}
