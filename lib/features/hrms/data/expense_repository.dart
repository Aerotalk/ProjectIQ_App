import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  final dio = ref.read(dioProvider);
  return ExpenseRepository(dio);
});

class ExpenseRepository {
  final Dio _dio;

  ExpenseRepository(this._dio);

  Future<List<dynamic>> getCategories() async {
    try {
      final response = await _dio.get('/hrms/expense-claims/categories');
      if (response.data is List) {
        return (response.data as List).map((c) => {
          'id': c['id'] ?? '',
          'category': c['name'] ?? '',
          'glCode': c['glCode'] ?? '',
          'active': c['active'] ?? true,
        }).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getClaims() async {
    try {
      final response = await _dio.get('/hrms/expense-claims/claims');
      if (response.data is List) {
        return (response.data as List).map((c) => {
          'id': c['id'] ?? '',
          'claimNo': c['claimNo'] ?? '',
          'title': c['title'] ?? '',
          'totalClaimed': (c['totalClaimed'] ?? 0).toDouble(),
          'status': c['status'] ?? 'Draft',
          'submittedOn': c['submittedOn']?.toString() ?? c['createdAt']?.toString() ?? '',
        }).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getApprovals() async {
    try {
      final response = await _dio.get('/hrms/expense-claims/approvals');
      if (response.data is List) {
        return (response.data as List).map((c) => {
          'id': c['id'] ?? '',
          'claimNo': c['claimNo'] ?? '',
          'title': c['title'] ?? '',
          'totalClaimed': (c['totalClaimed'] ?? 0).toDouble(),
          'status': c['status'] ?? 'Pending Approval',
          'submittedOn': c['submittedOn']?.toString() ?? c['createdAt']?.toString() ?? '',
        }).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getBatches() async {
    try {
      final response = await _dio.get('/hrms/expense-claims/batches');
      if (response.data is List) {
        return (response.data as List).map((b) => {
          'id': b['id'] ?? '',
          'batchNo': b['batchNo'] ?? '',
          'totalAmount': (b['totalAmount'] ?? 0).toDouble(),
          'status': b['status'] ?? 'Draft',
          'createdAt': b['createdAt']?.toString() ?? '',
        }).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getAdvances() async {
    try {
      final response = await _dio.get('/hrms/expense-claims/advances');
      if (response.data is List) {
        return (response.data as List).map((a) => {
          'id': a['id'] ?? '',
          'advanceNo': a['advanceNo'] ?? '',
          'amount': (a['amount'] ?? 0).toDouble(),
          'reason': a['reason'] ?? '',
          'status': a['status'] ?? 'Pending',
        }).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<dynamic> createClaim(Map<String, dynamic> payload) async {
    final response = await _dio.post('/hrms/expense-claims/claims', data: payload);
    return response.data;
  }

  Future<dynamic> createClaimItem(String claimId, Map<String, dynamic> itemPayload) async {
    final response = await _dio.post('/hrms/expense-claims/claims/$claimId/items', data: itemPayload);
    return response.data;
  }

  Future<dynamic> uploadReceipt(dynamic file, String fileName) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(file, filename: fileName),
      'module': 'expense_claims',
    });
    final response = await _dio.post('/admin/files/upload', data: formData);
    return response.data;
  }
}
