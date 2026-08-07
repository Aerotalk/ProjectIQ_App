import 'package:dio/dio.dart';
void main() async {
  final dio = Dio();
  try {
    // Need to login first to get the token, otherwise we get 403 Forbidden!
    // But wait, SecurityConfig has permitAll() for /api/auth/**!
    final response = await dio.put('http://localhost:8080/api/auth/password', data: {
      'currentPassword': 'wrong',
      'newPassword': 'new'
    });
    print('Success: ${response.statusCode} ${response.data}');
  } on DioException catch (e) {
    print('Dio Error: ${e.response?.statusCode} ${e.response?.data}');
  } catch (e) {
    print('Other Error: $e');
  }
}
