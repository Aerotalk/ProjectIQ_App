import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/authentication/presentation/login_screen.dart';
import '../../features/authentication/presentation/auth_controller.dart';
import '../../features/dashboard/presentation/home_shell.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/dashboard/presentation/hrms_screen.dart';
import '../../features/dashboard/presentation/profile_screen.dart';
import '../../features/dashboard/presentation/profile_settings_screen.dart';
import '../../features/dashboard/presentation/notifications_screen.dart';
import '../../features/hrms/presentation/employee_directory_screen.dart';
import '../../features/hrms/presentation/employee_profile_screen.dart';
import '../../features/hrms/presentation/add_employee_screen.dart';
import '../../features/hrms/presentation/performance_screen.dart';
import '../../features/departments/presentation/screens/department_list_screen.dart';
import '../../features/departments/presentation/screens/department_details_screen.dart';
import '../../features/departments/presentation/screens/department_form_screen.dart';
import '../../features/designations/presentation/screens/designation_list_screen.dart';
import '../../features/designations/presentation/screens/designation_details_screen.dart';
import '../../features/designations/presentation/screens/designation_form_screen.dart';
import '../../features/attendance/presentation/screens/attendance_dashboard_screen.dart';
import '../../features/attendance/presentation/screens/attendance_calendar_screen.dart';
import '../../features/attendance/presentation/screens/regularization_list_screen.dart';
import '../../features/attendance/presentation/screens/regularization_form_screen.dart';
import '../../features/attendance/presentation/screens/leave_list_screen.dart';
import '../../features/attendance/presentation/screens/leave_form_screen.dart';
import '../../features/attendance/presentation/screens/shift_list_screen.dart';
import '../../features/attendance/presentation/screens/shift_form_screen.dart';
import '../../features/attendance/presentation/screens/daily_attendance_list_screen.dart';
import '../../features/attendance/presentation/screens/attendance_exception_list_screen.dart';
import '../../features/attendance/presentation/screens/permission_list_screen.dart';
import '../../features/attendance/presentation/screens/permission_form_screen.dart';
import '../../features/attendance/presentation/screens/approval_center_screen.dart';
import '../../features/payroll/presentation/screens/payroll_dashboard_screen.dart';
import '../../features/payroll/presentation/screens/payslips_screen.dart';
import '../../features/payroll/presentation/screens/salary_details_screen.dart';
import '../../features/payroll/presentation/screens/reimbursement_list_screen.dart';
import '../../features/payroll/presentation/screens/it_declaration_screen.dart';
import '../../features/payroll/presentation/screens/payroll_runs_screen.dart';
import '../../features/payroll/presentation/screens/salary_inputs_screen.dart';
import '../../features/payroll/presentation/screens/payroll_processing_screen.dart';
import '../../features/payroll/presentation/screens/verification_screen.dart';
import '../../features/payroll/presentation/screens/reimbursement_form_screen.dart';
import '../../features/payroll/presentation/screens/it_declaration_form_screen.dart';
import '../../features/payroll/presentation/screens/salary_input_form_screen.dart';
import '../../features/payroll/presentation/screens/settlement_form_screen.dart';
import '../../features/payroll/presentation/screens/payouts_screen.dart';
import '../../features/hrms/presentation/expense_claims_screen.dart';
import '../../features/hrms/presentation/expense_claim_form_screen.dart';
import '../../shared/widgets/navigation/premium_navigation_wrapper.dart';
import 'module_registry.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  // Only rebuild the router if authentication status or loading status changes
  final isLoading = ref.watch(authControllerProvider.select((state) => state.isLoading));
  final isAuthenticated = ref.watch(authControllerProvider.select((state) => state.isAuthenticated));
  
  final moduleRegistry = ref.watch(moduleRegistryProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final isLoggingIn = state.matchedLocation == '/login';
      final isSplash = state.matchedLocation == '/splash';

      if (authState.isLoading) {
        return isSplash ? null : '/splash';
      }

      if (!authState.isAuthenticated) {
        return isLoggingIn ? null : '/login';
      }

      if (isLoggingIn || isSplash || state.matchedLocation == '/') {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      ...[
        GoRoute(
          path: '/profile-settings',
          builder: (context, state) => const ProfileSettingsScreen(),
        ),
        GoRoute(
          path: '/hrms/employees',
          builder: (context, state) => const EmployeeDirectoryScreen(),
        ),
        GoRoute(
          path: '/hrms/employees/new',
          builder: (context, state) => const AddEmployeeScreen(),
        ),
        GoRoute(
          path: '/hrms/employees/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return EmployeeProfileScreen(employeeId: id);
          },
        ),
        GoRoute(
          path: '/hrms/departments',
          builder: (context, state) => const DepartmentListScreen(),
        ),
        GoRoute(
          path: '/departments/new',
          builder: (context, state) => const DepartmentFormScreen(),
        ),
        GoRoute(
          path: '/departments/:id/edit',
          builder: (context, state) {
            final dept = state.extra;
            return DepartmentFormScreen(department: dept as dynamic);
          },
        ),
        GoRoute(
          path: '/departments/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return DepartmentDetailsScreen(departmentId: id);
          },
        ),
        GoRoute(
          path: '/hrms/designations',
          builder: (context, state) => const DesignationListScreen(),
        ),
        GoRoute(
          path: '/designations/new',
          builder: (context, state) => const DesignationFormScreen(),
        ),
        GoRoute(
          path: '/designations/:id/edit',
          builder: (context, state) {
            final desig = state.extra;
            return DesignationFormScreen(designation: desig as dynamic);
          },
        ),
        GoRoute(
          path: '/designations/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return DesignationDetailsScreen(designationId: id);
          },
        ),
        GoRoute(
          path: '/hrms/attendance',
          builder: (context, state) => const AttendanceDashboardScreen(),
        ),
        GoRoute(
          path: '/hrms/attendance/calendar',
          builder: (context, state) => const AttendanceCalendarScreen(),
        ),
        GoRoute(
          path: '/hrms/attendance/regularization',
          builder: (context, state) => const RegularizationListScreen(),
        ),
        GoRoute(
          path: '/hrms/attendance/regularization/new',
          builder: (context, state) => const RegularizationFormScreen(),
        ),
        GoRoute(
          path: '/hrms/attendance/daily-logs',
          builder: (context, state) => const DailyAttendanceListScreen(),
        ),
        GoRoute(
          path: '/hrms/attendance/exceptions',
          builder: (context, state) => const AttendanceExceptionListScreen(),
        ),
        GoRoute(
          path: '/hrms/attendance/permissions',
          builder: (context, state) => const PermissionListScreen(),
        ),
        GoRoute(
          path: '/hrms/attendance/permissions/new',
          builder: (context, state) => const PermissionFormScreen(),
        ),
        GoRoute(
          path: '/hrms/attendance/shifts',
          builder: (context, state) => const ShiftListScreen(),
        ),
        GoRoute(
          path: '/hrms/attendance/shifts/new',
          builder: (context, state) => const ShiftFormScreen(),
        ),
        GoRoute(
          path: '/hrms/attendance/leaves',
          builder: (context, state) => const LeaveListScreen(),
        ),
        GoRoute(
          path: '/hrms/attendance/leaves/new',
          builder: (context, state) => const LeaveFormScreen(),
        ),
        GoRoute(
          path: '/hrms/attendance/approval-center',
          builder: (context, state) => const ApprovalCenterScreen(),
        ),
        GoRoute(
          path: '/hrms/payroll',
          builder: (context, state) => const PayrollDashboardScreen(),
        ),
        GoRoute(
          path: '/hrms/payroll/payslips',
          builder: (context, state) => const PayslipsScreen(),
        ),
        GoRoute(
          path: '/hrms/payroll/salary-details',
          builder: (context, state) => const SalaryDetailsScreen(),
        ),
        GoRoute(
          path: '/hrms/payroll/reimbursements',
          builder: (context, state) => const ReimbursementListScreen(),
        ),
        GoRoute(
          path: '/hrms/payroll/it-declarations',
          builder: (context, state) => const ITDeclarationScreen(),
        ),
        GoRoute(
          path: '/hrms/payroll/runs',
          builder: (context, state) => const PayrollRunsScreen(),
        ),
        GoRoute(
          path: '/hrms/payroll/inputs',
          builder: (context, state) => const SalaryInputsScreen(),
        ),
        GoRoute(
          path: '/hrms/payroll/processing',
          builder: (context, state) => const PayrollProcessingScreen(),
        ),
        GoRoute(
          path: '/hrms/payroll/verification',
          builder: (context, state) => const VerificationScreen(),
        ),
        GoRoute(
          path: '/hrms/payroll/reimbursements/new',
          builder: (context, state) => const ReimbursementFormScreen(),
        ),
        GoRoute(
          path: '/hrms/payroll/it-declarations/new',
          builder: (context, state) => const ITDeclarationFormScreen(),
        ),
        GoRoute(
          path: '/hrms/payroll/inputs/new',
          builder: (context, state) => const SalaryInputFormScreen(),
        ),
        GoRoute(
          path: '/hrms/payroll/payouts',
          builder: (context, state) => const PayoutsScreen(),
        ),
        GoRoute(
          path: '/hrms/payroll/settlements',
          builder: (context, state) => const SettlementFormScreen(),
        ),
        GoRoute(
          path: '/hrms/expense-claims',
          builder: (context, state) => const ExpenseClaimsScreen(),
        ),
        GoRoute(
          path: '/hrms/expense-claims/new',
          builder: (context, state) => const ExpenseClaimFormScreen(),
        ),
        GoRoute(
          path: '/hrms/performance',
          builder: (context, state) => const PerformanceScreen(),
        ),
      ].map(
        (route) => GoRoute(
          path: route.path,
          name: route.name,
          builder: (context, state) =>
              PremiumNavigationWrapper(child: route.builder!(context, state)),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return HomeShell(navigationShell: navigationShell);
        },
        branches: moduleRegistry.bottomNavModules.map((module) {
          return StatefulShellBranch(
            routes: [
              GoRoute(
                path: module.route,
                builder: (context, state) {
                  if (module.route == '/dashboard') {
                    return const DashboardScreen();
                  }
                  if (module.route == '/hrms') {
                    return const HRMSScreen();
                  }
                  if (module.route == '/profile') {
                    return const ProfileScreen();
                  }
                  if (module.route == '/notifications') {
                    return const NotificationsScreen();
                  }
                  if (module.route == '/approvals') {
                    return const ApprovalCenterScreen();
                  }

                  // Placeholder for dynamic module injection
                  return Scaffold(
                    body: Center(
                      child: Text(
                        'Module: ${module.title}\n(Under Construction)',
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        }).toList(),
      ),
    ],
  );
});
