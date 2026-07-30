import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../domain/employee_profile.dart';
import 'package:dio/dio.dart';

final employeeProfileProvider = FutureProvider.autoDispose<EmployeeProfile?>((ref) async {
  final dio = ref.watch(dioProvider);
  try {
    final response = await dio.get('/admin/employees/me');
    return EmployeeProfile.fromJson(response.data);
  } on DioException catch (e) {
    if (e.response?.statusCode == 403 || e.response?.statusCode == 404) {
      // User might not have an employee profile or permission to view it
      return null;
    }
    rethrow;
  }
});
