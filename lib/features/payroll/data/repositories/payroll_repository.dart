import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/payroll_models.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/app_formatters.dart';

final payrollRepositoryProvider = Provider<PayrollRepository>((ref) {
  final dio = ref.read(dioProvider);
  return PayrollRepository(dio);
});

class PayrollRepository {
  final Dio _dio;

  PayrollRepository(this._dio);

  Future<PayrollDashboardKPIs> getDashboardKPIs() async {
    try {
      final response = await _dio.get('/hrms/payroll/dashboard');
      final data = response.data;
      return PayrollDashboardKPIs(
        currentPeriod: data['currentPeriod'] ?? 'Current',
        pendingPayrollCount: data['pendingPayrollCount'] ?? 0,
        processedCount: data['processedCount'] ?? 0,
        pendingVerificationCount: data['pendingVerificationCount'] ?? 0,
        pendingPayoutCount: data['pendingPayoutCount'] ?? 0,
      );
    } catch (e) {
      return const PayrollDashboardKPIs(
        currentPeriod: 'Current',
        pendingPayrollCount: 0,
        processedCount: 0,
        pendingVerificationCount: 0,
        pendingPayoutCount: 0,
      );
    }
  }

  Future<List<PayrollRunModel>> getPayrollRuns() async {
    try {
      final response = await _dio.get('/hrms/payroll/runs');
      if (response.data is List) {
        return (response.data as List).map((r) => PayrollRunModel(
          id: r['id'] ?? '',
          period: r['payrollPeriod'] ?? '',
          status: r['status'] ?? 'Draft',
          employeeCount: r['employeeCount'] ?? 0,
          grossAmount: AppFormatters.formatCurrency(r['totalGross']),
          netAmount: AppFormatters.formatCurrency(r['totalNet']),
          createdDate: AppFormatters.formatDate(r['createdAt']),
          processedDate: AppFormatters.formatDate(r['processedAt']),
        )).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<PayslipModel>> getPayslips() async {
    try {
      final runsResponse = await _dio.get('/hrms/payroll/runs');
      List<PayslipModel> payslips = [];
      
      if (runsResponse.data is List) {
        for (var run in runsResponse.data) {
          try {
            final detailResp = await _dio.get('/hrms/payroll/runs/${run['id']}/details');
            if (detailResp.data is List) {
              payslips.addAll((detailResp.data as List).map((d) {
                final emp = d['employee'] ?? {};
                return PayslipModel(
                  id: d['id'] ?? '',
                  employeeName: '${emp['firstName'] ?? ''} ${emp['lastName'] ?? ''}'.trim(),
                  employeeCode: emp['employeeCode'] ?? '',
                  department: emp['department']?['departmentName'] ?? '',
                  period: run['payrollPeriod'] ?? '',
                  netSalary: AppFormatters.formatCurrency(d['net']),
                  grossSalary: AppFormatters.formatCurrency(d['gross']),
                  status: run['status'] ?? 'Draft',
                  payoutStatus: run['payoutStatus'] ?? 'Unpaid',
                );
              }));
            }
          } catch (_) {
            // ignore
          }
        }
      }
      return payslips;
    } catch (e) {
      return [];
    }
  }

  Future<List<ReimbursementModel>> getReimbursements() async {
    try {
      final response = await _dio.get('/hrms/payroll/reimbursements');
      if (response.data is List) {
        return (response.data as List).map((r) => ReimbursementModel(
          id: r['id'] ?? '',
          employeeName: '${r['employee']?['firstName'] ?? ''} ${r['employee']?['lastName'] ?? ''}'.trim(),
          claimType: r['expenseType'] ?? '',
          amount: AppFormatters.formatCurrency(r['claimedAmount']),
          status: r['status'] ?? 'Pending',
          submittedDate: AppFormatters.formatDate(r['createdAt']),
          remarks: r['remarks'] ?? '',
        )).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<ITDeclarationModel>> getITDeclarations() async {
    return []; // Backend not implemented for this
  }

  Future<List<SalaryInputModel>> getSalaryInputs() async {
    try {
      final response = await _dio.get('/hrms/payroll/salary-inputs');
      if (response.data is List) {
        return (response.data as List).map((s) => SalaryInputModel(
          id: s['id'] ?? '',
          employeeName: '${s['employee']?['firstName'] ?? ''} ${s['employee']?['lastName'] ?? ''}'.trim(),
          employeeCode: s['employee']?['employeeCode'] ?? '',
          period: s['month'] != null ? '${s['month']}/${s['year']}' : '',
          adjustmentType: s['componentType'] ?? '',
          amount: AppFormatters.formatCurrency(s['amount']),
          remarks: s['remarks'] ?? '',
        )).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getPayrollEligibilityCheck(String batchMonth) async {
    try {
      final response = await _dio.get(
        '/hrms/payroll/eligibility-check',
        queryParameters: {'batchMonth': batchMonth},
      );
      if (response.data is List) {
        return response.data as List;
      }
      return [];
    } catch (e) {
      throw Exception('Failed to check eligibility: $e');
    }
  }

  Future<void> runPayroll(Map<String, dynamic> data) async {
    try {
      await _dio.post('/hrms/payroll/runs', data: data);
    } catch (e) {
      throw Exception('Failed to run payroll: $e');
    }
  }

  Future<void> createSalaryInput(Map<String, dynamic> data) async {
    try {
      await _dio.post('/hrms/payroll/salary-inputs', data: data);
    } catch (e) {
      throw Exception('Failed to create salary input: $e');
    }
  }

  Future<void> createSettlement(Map<String, dynamic> data) async {
    try {
      await _dio.post('/hrms/payroll/settlements', data: data);
    } catch (e) {
      throw Exception('Failed to process settlement: $e');
    }
  }

  Future<void> createITDeclaration(Map<String, dynamic> data) async {
    try {
      await _dio.post('/hrms/payroll/it-declarations', data: data);
    } catch (e) {
      throw Exception('Failed to submit IT declaration: $e');
    }
  }

  Future<void> createReimbursement(Map<String, dynamic> data) async {
    try {
      await _dio.post('/hrms/payroll/reimbursements', data: data);
    } catch (e) {
      throw Exception('Failed to submit reimbursement: $e');
    }
  }
}
