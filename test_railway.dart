import 'package:dio/dio.dart';
void main() async {
  final dio = Dio();
  try {
    final response = await dio.put('https://projectiqbackend-production.up.railway.app/api/auth/password', data: {
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
