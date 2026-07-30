class PayrollDashboardKPIs {
  final String currentPeriod;
  final int pendingPayrollCount;
  final int processedCount;
  final int pendingVerificationCount;
  final int pendingPayoutCount;

  const PayrollDashboardKPIs({
    required this.currentPeriod,
    required this.pendingPayrollCount,
    required this.processedCount,
    required this.pendingVerificationCount,
    required this.pendingPayoutCount,
  });
}

class PayrollRunModel {
  final String id;
  final String period;
  final String status;
  final int employeeCount;
  final String grossAmount;
  final String netAmount;
  final String createdDate;
  final String? processedDate;

  const PayrollRunModel({
    required this.id,
    required this.period,
    required this.status,
    required this.employeeCount,
    required this.grossAmount,
    required this.netAmount,
    required this.createdDate,
    this.processedDate,
  });
}

class PayslipModel {
  final String id;
  final String employeeName;
  final String employeeCode;
  final String department;
  final String period;
  final String netSalary;
  final String grossSalary;
  final String status;
  final String payoutStatus;

  const PayslipModel({
    required this.id,
    required this.employeeName,
    required this.employeeCode,
    required this.department,
    required this.period,
    required this.netSalary,
    required this.grossSalary,
    required this.status,
    required this.payoutStatus,
  });
}

class ReimbursementModel {
  final String id;
  final String employeeName;
  final String claimType;
  final String amount;
  final String status; // Pending, Approved, Rejected
  final String submittedDate;
  final String remarks;

  const ReimbursementModel({
    required this.id,
    required this.employeeName,
    required this.claimType,
    required this.amount,
    required this.status,
    required this.submittedDate,
    required this.remarks,
  });
}

class ITDeclarationModel {
  final String id;
  final String employeeName;
  final String regime;
  final String declaredAmount;
  final String status;
  final String submittedDate;

  const ITDeclarationModel({
    required this.id,
    required this.employeeName,
    required this.regime,
    required this.declaredAmount,
    required this.status,
    required this.submittedDate,
  });
}

class SalaryInputModel {
  final String id;
  final String employeeName;
  final String employeeCode;
  final String period;
  final String adjustmentType; // e.g. Bonus, Deduction, Arrears
  final String amount;
  final String remarks;

  const SalaryInputModel({
    required this.id,
    required this.employeeName,
    required this.employeeCode,
    required this.period,
    required this.adjustmentType,
    required this.amount,
    required this.remarks,
  });
}
