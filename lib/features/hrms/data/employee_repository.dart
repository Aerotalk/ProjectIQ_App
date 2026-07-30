import 'package:dio/dio.dart';
import '../domain/employee.dart';

class EmployeeRepository {
  final Dio _dio;

  EmployeeRepository(this._dio);

  Future<List<Employee>> getEmployees({
    String? keyword,
    String? departmentId,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{};
    if (keyword != null && keyword.isNotEmpty) queryParams['keyword'] = keyword;
    if (departmentId != null && departmentId.isNotEmpty) queryParams['departmentId'] = departmentId;
    if (status != null && status.isNotEmpty) queryParams['status'] = status;

    try {
      final response = await _dio.get(
        '/admin/employees',
        queryParameters: queryParams,
      );

      final data = response.data as List;
      return data.map((json) => Employee.fromJson(json)).toList();
    } on DioException catch (e) {
      print('DioException in getEmployees: ${e.response?.statusCode} - ${e.response?.data}');
      rethrow;
    }
  }

  Future<Employee> getEmployeeById(String id) async {
    final response = await _dio.get('/admin/employees/$id');
    return Employee.fromJson(response.data);
  }

  Future<Employee> createEmployee(Map<String, dynamic> data) async {
    final response = await _dio.post('/admin/employees', data: data);
    return Employee.fromJson(response.data);
  }

  Future<Map<String, dynamic>> createUser(Map<String, dynamic> data) async {
    final response = await _dio.post('/admin/users', data: data);
    return response.data as Map<String, dynamic>;
  }
}
