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
