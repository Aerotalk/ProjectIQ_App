import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import 'models/performance_models.dart';

final performanceRepositoryProvider = Provider<PerformanceRepository>((ref) {
  final dio = ref.read(dioProvider);
  return PerformanceRepository(dio);
});

class PerformanceRepository {
  final Dio _dio;

  PerformanceRepository(this._dio);

  Future<List<AppraisalCycle>> getActiveCycles() async {
    try {
      final response = await _dio.get('/hrms/performance/cycles');
      if (response.data is List) {
        return (response.data as List).map((c) => AppraisalCycle(
          id: c['id'] ?? '',
          name: c['name'] ?? '',
          type: c['type'] ?? 'Annual',
          period: c['period'] ?? '',
          startDate: c['startDate']?.toString().split('T')[0] ?? '',
          endDate: c['endDate']?.toString().split('T')[0] ?? '',
          selfReviewDeadline: c['selfReviewDeadline']?.toString().split('T')[0] ?? '',
          managerReviewDeadline: c['managerReviewDeadline']?.toString().split('T')[0] ?? '',
          hrReviewDeadline: c['hrReviewDeadline']?.toString().split('T')[0] ?? '',
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
      if (response.data is List) {
        return (response.data as List).map((g) => Goal(
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
          dueDate: g['dueDate']?.toString().split('T')[0] ?? '',
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
      if (response.data is List) return response.data;
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getManagerReviews() async {
    try {
      final response = await _dio.get('/hrms/performance/reviews/manager');
      if (response.data is List) return response.data;
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getCalibrationRecords() async {
    try {
      final response = await _dio.get('/hrms/performance/calibration');
      if (response.data is List) return response.data;
      return [];
    } catch (e) {
      return [];
    }
  }
}
