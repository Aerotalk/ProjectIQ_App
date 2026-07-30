import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../authentication/presentation/auth_controller.dart';
import '../../data/repositories/payroll_repository.dart';

// Provides a way to toggle between HR and Employee views for testing.
// In production, this would strictly rely on the AuthController role.
class PayrollRoleState {
  final bool isHR;
  final bool isForcedOverride;

  const PayrollRoleState({required this.isHR, this.isForcedOverride = false});
}

class PayrollRoleNotifier extends Notifier<PayrollRoleState> {
  @override
  PayrollRoleState build() {
    final authState = ref.watch(authControllerProvider);
    final isSuperAdmin = authState.user?.roles.contains('ROLE_SUPER_ADMIN') ?? false;
    final isHR = authState.user?.roles.contains('ROLE_HR') ?? false;
    
    // Default to HR view if they have the role
    return PayrollRoleState(isHR: isSuperAdmin || isHR, isForcedOverride: false);
  }

  void toggleRole() {
    state = PayrollRoleState(isHR: !state.isHR, isForcedOverride: true);
  }
}

final payrollRoleProvider = NotifierProvider<PayrollRoleNotifier, PayrollRoleState>(() {
  return PayrollRoleNotifier();
});

// Provides dashboard KPIs
final payrollDashboardProvider = FutureProvider((ref) async {
  return ref.read(payrollRepositoryProvider).getDashboardKPIs();
});

final payrollRunsProvider = FutureProvider((ref) async {
  return ref.read(payrollRepositoryProvider).getPayrollRuns();
});

final payslipsProvider = FutureProvider((ref) async {
  return ref.read(payrollRepositoryProvider).getPayslips();
});

final reimbursementsProvider = FutureProvider((ref) async {
  return ref.read(payrollRepositoryProvider).getReimbursements();
});

final itDeclarationsProvider = FutureProvider((ref) async {
  return ref.read(payrollRepositoryProvider).getITDeclarations();
});

final salaryInputsProvider = FutureProvider((ref) async {
  return ref.read(payrollRepositoryProvider).getSalaryInputs();
});
