import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/base_repository.dart';
import '../models/department_model.dart';

final departmentRepositoryProvider = Provider<DepartmentRepository>((ref) {
  return DepartmentRepository(ref.read(dioProvider));
});

class DepartmentRepository extends BaseRepository {
  final Dio _dio;

  DepartmentRepository(this._dio);

  Future<List<DepartmentModel>> getDepartments({String? companyId}) async {
    return apiCall(() async {
      final response = await _dio.get(
        '/admin/departments',
        queryParameters: companyId != null ? {'companyId': companyId} : null,
      );
      final data = response.data as List;
      return data.map((e) => DepartmentModel.fromJson(e)).toList();
    });
  }

  Future<DepartmentModel> getDepartmentById(String id) async {
    return apiCall(() async {
      final response = await _dio.get('/admin/departments/$id');
      return DepartmentModel.fromJson(response.data);
    });
  }

  Future<DepartmentModel> createDepartment({
    required String departmentCode,
    required String departmentName,
    String? description,
    String? companyId,
  }) async {
    return apiCall(() async {
      final response = await _dio.post('/admin/departments', data: {
        'departmentCode': departmentCode,
        'departmentName': departmentName,
        'description': description,
        'companyId': ?companyId,
      });
      return DepartmentModel.fromJson(response.data);
    });
  }

  Future<DepartmentModel> updateDepartment(
    String id, {
    required String departmentCode,
    required String departmentName,
    String? description,
  }) async {
    return apiCall(() async {
      final response = await _dio.put('/admin/departments/$id', data: {
        'departmentCode': departmentCode,
        'departmentName': departmentName,
        'description': description,
      });
      return DepartmentModel.fromJson(response.data);
    });
  }

  Future<void> deleteDepartment(String id) async {
    return apiCall(() async {
      await _dio.delete('/admin/departments/$id');
    });
  }
}
