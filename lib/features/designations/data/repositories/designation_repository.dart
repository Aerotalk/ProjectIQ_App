import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/base_repository.dart';
import '../models/designation_model.dart';

final designationRepositoryProvider = Provider<DesignationRepository>((ref) {
  return DesignationRepository(ref.read(dioProvider));
});

class DesignationRepository extends BaseRepository {
  final Dio _dio;

  DesignationRepository(this._dio);

  Future<List<DesignationModel>> getDesignations({String? companyId}) async {
    return apiCall(() async {
      final response = await _dio.get(
        '/admin/designations',
        queryParameters: companyId != null ? {'companyId': companyId} : null,
      );
      final data = response.data as List;
      return data.map((e) => DesignationModel.fromJson(e)).toList();
    });
  }

  Future<DesignationModel> getDesignationById(String id) async {
    return apiCall(() async {
      final response = await _dio.get('/admin/designations/$id');
      return DesignationModel.fromJson(response.data);
    });
  }

  Future<DesignationModel> createDesignation({
    required String designationCode,
    required String designationName,
    String? roleId,
    String? description,
    String? companyId,
  }) async {
    return apiCall(() async {
      final response = await _dio.post('/admin/designations', data: {
        'designationCode': designationCode,
        'designationName': designationName,
        'roleId': ?roleId,
        'description': ?description,
        'companyId': ?companyId,
      });
      return DesignationModel.fromJson(response.data);
    });
  }

  Future<DesignationModel> updateDesignation(
    String id, {
    required String designationCode,
    required String designationName,
    String? roleId,
    String? description,
  }) async {
    return apiCall(() async {
      final response = await _dio.put('/admin/designations/$id', data: {
        'designationCode': designationCode,
        'designationName': designationName,
        'roleId': ?roleId,
        'description': ?description,
      });
      return DesignationModel.fromJson(response.data);
    });
  }

  Future<void> deleteDesignation(String id) async {
    return apiCall(() async {
      await _dio.delete('/admin/designations/$id');
    });
  }
}
