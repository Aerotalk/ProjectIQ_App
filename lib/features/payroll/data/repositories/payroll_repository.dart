import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/payroll_models.dart';

final payrollRepositoryProvider = Provider<PayrollRepository>((ref) {
  return PayrollRepository();
});

class PayrollRepository {
  Future<PayrollDashboardKPIs> getDashboardKPIs() async {
    await Future.delayed(const Duration(seconds: 1));
    return const PayrollDashboardKPIs(
      currentPeriod: 'July 2026',
      pendingPayrollCount: 8,
      processedCount: 145,
      pendingVerificationCount: 2,
      pendingPayoutCount: 1,
    );
  }

  Future<List<PayrollRunModel>> getPayrollRuns() async {
    await Future.delayed(const Duration(seconds: 1));
    return const [
      PayrollRunModel(
        id: 'PR-2026-07',
        period: 'July 2026',
        status: 'Processing',
        employeeCount: 150,
        grossAmount: '₹ 15,20,000',
        netAmount: '₹ 12,50,000',
        createdDate: '2026-07-28',
      ),
      PayrollRunModel(
        id: 'PR-2026-06',
        period: 'June 2026',
        status: 'Processed',
        employeeCount: 148,
        grossAmount: '₹ 14,80,000',
        netAmount: '₹ 11,90,000',
        createdDate: '2026-06-28',
        processedDate: '2026-06-30',
      ),
    ];
  }

  Future<List<PayslipModel>> getPayslips() async {
    await Future.delayed(const Duration(seconds: 1));
    return const [
      PayslipModel(
        id: '1',
        employeeName: 'John Doe',
        employeeCode: 'EMP001',
        department: 'Engineering',
        period: 'July 2026',
        grossSalary: '₹ 1,50,000',
        netSalary: '₹ 1,15,000',
        status: 'Processed',
        payoutStatus: 'Paid',
      ),
      PayslipModel(
        id: '2',
        employeeName: 'Jane Smith',
        employeeCode: 'EMP002',
        department: 'Marketing',
        period: 'July 2026',
        grossSalary: '₹ 1,20,000',
        netSalary: '₹ 95,000',
        status: 'Processing',
        payoutStatus: 'Pending',
      ),
      PayslipModel(
        id: '3',
        employeeName: 'John Doe',
        employeeCode: 'EMP001',
        department: 'Engineering',
        period: 'June 2026',
        grossSalary: '₹ 1,50,000',
        netSalary: '₹ 1,15,000',
        status: 'Processed',
        payoutStatus: 'Paid',
      ),
    ];
  }

  Future<List<ReimbursementModel>> getReimbursements() async {
    await Future.delayed(const Duration(seconds: 1));
    return const [
      ReimbursementModel(
        id: 'RMB-001',
        employeeName: 'Jane Smith',
        claimType: 'Travel',
        amount: '₹ 5,000',
        status: 'Pending',
        submittedDate: '2026-07-15',
        remarks: 'Client visit to Mumbai',
      ),
      ReimbursementModel(
        id: 'RMB-002',
        employeeName: 'John Doe',
        claimType: 'Internet',
        amount: '₹ 1,500',
        status: 'Approved',
        submittedDate: '2026-06-10',
        remarks: 'Monthly broadband',
      ),
    ];
  }

  Future<List<ITDeclarationModel>> getITDeclarations() async {
    await Future.delayed(const Duration(seconds: 1));
    return const [
      ITDeclarationModel(
        id: 'ITD-001',
        employeeName: 'John Doe',
        regime: 'New Regime',
        declaredAmount: '₹ 1,50,000',
        status: 'Approved',
        submittedDate: '2026-04-05',
      ),
      ITDeclarationModel(
        id: 'ITD-002',
        employeeName: 'Jane Smith',
        regime: 'Old Regime',
        declaredAmount: '₹ 2,00,000',
        status: 'Pending Review',
        submittedDate: '2026-07-20',
      ),
    ];
  }

  Future<List<SalaryInputModel>> getSalaryInputs() async {
    await Future.delayed(const Duration(seconds: 1));
    return const [
      SalaryInputModel(
        id: 'SI-001',
        employeeName: 'Alice Johnson',
        employeeCode: 'EMP003',
        period: 'July 2026',
        adjustmentType: 'Performance Bonus',
        amount: '₹ 25,000',
        remarks: 'Q2 Targets Achieved',
      ),
      SalaryInputModel(
        id: 'SI-002',
        employeeName: 'Bob Brown',
        employeeCode: 'EMP004',
        period: 'July 2026',
        adjustmentType: 'Leave Deduction',
        amount: '-₹ 3,500',
        remarks: 'Unpaid Leave (1 Day)',
      ),
    ];
  }
}
