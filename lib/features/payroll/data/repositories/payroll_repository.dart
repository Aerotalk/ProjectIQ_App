import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/payroll_models.dart';
import '../../../../core/network/api_client.dart';

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
          grossAmount: '₹ ${(r['totalGross'] ?? 0).toStringAsFixed(2)}',
          netAmount: '₹ ${(r['totalNet'] ?? 0).toStringAsFixed(2)}',
          createdDate: r['createdAt']?.toString().split('T')[0] ?? '',
          processedDate: r['processedAt']?.toString().split('T')[0],
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
                  netSalary: '₹ ${(d['net'] ?? 0).toStringAsFixed(2)}',
                  grossSalary: '₹ ${(d['gross'] ?? 0).toStringAsFixed(2)}',
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
          amount: '₹ ${(r['claimedAmount'] ?? 0).toStringAsFixed(2)}',
          status: r['status'] ?? 'Pending',
          submittedDate: r['createdAt']?.toString().split('T')[0] ?? '',
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
          amount: '₹ ${(s['amount'] ?? 0).toStringAsFixed(2)}',
          remarks: s['remarks'] ?? '',
        )).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
