import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/app_formatters.dart';
import 'models/performance_models.dart';

final performanceRepositoryProvider = Provider<PerformanceRepository>((ref) {
  final dio = ref.read(dioProvider);
  return PerformanceRepository(dio);
});

class PerformanceRepository {
  final Dio _dio;

  PerformanceRepository(this._dio);

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      if (data.containsKey('data') && data['data'] is List) return data['data'];
      if (data.containsKey('content') && data['content'] is List) return data['content'];
    }
    return [];
  }

  Future<List<AppraisalCycle>> getActiveCycles() async {
    try {
      final response = await _dio.get('/hrms/performance/cycles');
      final listData = _extractList(response.data);
      if (listData.isNotEmpty) {
        return listData.map((c) => AppraisalCycle(
          id: c['id'] ?? '',
          name: c['name'] ?? '',
          type: c['type'] ?? 'Annual',
          period: c['period'] ?? '',
          startDate: AppFormatters.formatDate(c['startDate']),
          endDate: AppFormatters.formatDate(c['endDate']),
          selfReviewDeadline: AppFormatters.formatDate(c['selfReviewDeadline']),
          managerReviewDeadline: AppFormatters.formatDate(c['managerReviewDeadline']),
          hrReviewDeadline: AppFormatters.formatDate(c['hrReviewDeadline']),
          departments: ['All'],
          locations: ['All'],
          grades: ['All'],
          eligibleCount: c['eligibleCount'] ?? 0,
          completionPercentage: c['completionPercentage'] ?? 0,
          status: c['status'] ?? 'Active',
          description: c['description'] ?? '',
        )).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Goal>> getGoals() async {
    try {
      final response = await _dio.get('/hrms/performance/goals');
      final listData = _extractList(response.data);
      if (listData.isNotEmpty) {
        return listData.map((g) => Goal(
          id: g['id'] ?? '',
          title: g['title'] ?? '',
          description: g['description'] ?? '',
          employee: EmployeeInfo(
            id: g['employee']?['id'] ?? '',
            name: '${g['employee']?['firstName'] ?? ''} ${g['employee']?['lastName'] ?? ''}'.trim(),
            designation: g['employee']?['designation']?['designationName'] ?? '',
            department: g['employee']?['department']?['departmentName'] ?? ''
          ),
          cycleId: g['cycle']?['id'] ?? g['cycleId'] ?? '',
          category: g['category'] ?? '',
          weightage: g['weightage'] ?? 0,
          kpi: g['kpi'] ?? '',
          targetValue: (g['targetValue'] ?? 0).toDouble(),
          currentValue: (g['currentValue'] ?? 0).toDouble(),
          unit: g['unit'] ?? '',
          dueDate: AppFormatters.formatDate(g['dueDate']),
          priority: g['priority'] ?? '',
          status: g['status'] ?? 'In Progress',
          progress: g['progress'] ?? 0,
          comments: g['comments'] ?? '',
          attachments: 0,
        )).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getSelfReviews() async {
    try {
      final response = await _dio.get('/hrms/performance/reviews/self');
      return _extractList(response.data);
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getManagerReviews() async {
    try {
      final response = await _dio.get('/hrms/performance/reviews/manager');
      return _extractList(response.data);
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getCalibrationRecords() async {
    try {
      final response = await _dio.get('/hrms/performance/calibration');
      return _extractList(response.data);
    } catch (e) {
      return [];
    }
  }
}
