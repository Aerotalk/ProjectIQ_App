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
import '../../features/departments/presentation/screens/department_list_screen.dart';
import '../../features/departments/presentation/screens/department_details_screen.dart';
import '../../features/departments/presentation/screens/department_form_screen.dart';
import '../../features/designations/presentation/screens/designation_list_screen.dart';
import '../../features/designations/presentation/screens/designation_details_screen.dart';
import '../../features/designations/presentation/screens/designation_form_screen.dart';
import 'module_registry.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);
  final moduleRegistry = ref.watch(moduleRegistryProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggingIn = state.matchedLocation == '/login';

      if (authState.isLoading) {
        // We might want a splash screen here, but for now just wait
        return null;
      }

      if (!authState.isAuthenticated) {
        return isLoggingIn ? null : '/login';
      }

      if (isLoggingIn && authState.isAuthenticated) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
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
          // This should ideally pass the department object or fetch it inside the screen.
          // In our implementation, we'd need to pass the state if we want synchronous edit, 
          // but we can just use the ID and fetch, or we can use Riverpod to fetch the dept.
          // For simplicity, we just pass the ID and let the screen fetch it, OR we pass null 
          // and rely on a selectedDept state. But DepartmentFormScreen currently accepts 
          // `DepartmentModel? department`. Let's handle that properly. 
          // The easiest way is to push passing `extra: department`.
          final dept = state.extra;
          return DepartmentFormScreen(department: dept as dynamic); // Casting dynamically or changing screen.
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
                  
                  // Placeholder for dynamic module injection
                  return Scaffold(
                    body: Center(
                      child: Text('Module: ${module.title}\n(Under Construction)'),
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
