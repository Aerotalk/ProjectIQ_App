import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'permission_service.dart';

class PermissionGuard extends ConsumerWidget {
  final String permission;
  final Widget child;
  final Widget fallback;

  const PermissionGuard({
    super.key,
    required this.permission,
    required this.child,
    this.fallback = const SizedBox.shrink(),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionService = ref.watch(permissionServiceProvider);
    
    if (permissionService.can(permission)) {
      return child;
    }
    
    return fallback;
  }
}

class RoleGuard extends ConsumerWidget {
  final String role;
  final Widget child;
  final Widget fallback;

  const RoleGuard({
    super.key,
    required this.role,
    required this.child,
    this.fallback = const SizedBox.shrink(),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionService = ref.watch(permissionServiceProvider);
    
    if (permissionService.hasRole(role)) {
      return child;
    }
    
    return fallback;
  }
}
