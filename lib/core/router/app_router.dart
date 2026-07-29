import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/authentication/presentation/login_screen.dart';
import '../../features/authentication/presentation/auth_controller.dart';
import '../../features/dashboard/presentation/home_shell.dart';
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
