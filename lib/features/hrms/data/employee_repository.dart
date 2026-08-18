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

  Future<void> deleteEmployee(String id) async {
    await _dio.delete('/admin/employees/$id');
  }

  Future<void> saveAddress(String employeeId, Map<String, dynamic> data) async {
    await _dio.post('/admin/employees/$employeeId/address', data: data);
  }

  Future<void> saveEmergencyContact(String employeeId, Map<String, dynamic> data) async {
    await _dio.post('/admin/employees/$employeeId/emergency-contact', data: data);
  }

  Future<void> saveStatutory(String employeeId, Map<String, dynamic> data) async {
    await _dio.post('/admin/employees/$employeeId/statutory', data: data);
  }

  Future<void> saveBankAccount(String employeeId, Map<String, dynamic> data) async {
    await _dio.post('/admin/employees/$employeeId/bank-account', data: data);
  }

  Future<void> saveSalaryRevision(String employeeId, Map<String, dynamic> data) async {
    await _dio.post('/admin/employees/$employeeId/salary-revision', data: data);
  }

  Future<void> saveEducation(String employeeId, Map<String, dynamic> data) async {
    await _dio.post('/admin/employees/$employeeId/educations', data: data);
  }

  Future<void> saveFamily(String employeeId, Map<String, dynamic> data) async {
    await _dio.post('/admin/employees/$employeeId/families', data: data);
  }

  Future<void> saveContract(String employeeId, Map<String, dynamic> data) async {
    await _dio.post('/admin/employees/$employeeId/contract', data: data);
  }

  Future<void> savePositionChange(String employeeId, Map<String, dynamic> data) async {
    await _dio.put('/admin/employees/$employeeId/position-change', data: data);
  }

  Future<void> saveSeparation(String employeeId, Map<String, dynamic> data) async {
    await _dio.put('/admin/employees/$employeeId/separation', data: data);
  }
}
