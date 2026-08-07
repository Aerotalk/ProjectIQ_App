import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/authentication/presentation/auth_controller.dart';

final permissionServiceProvider = Provider<PermissionService>((ref) {
  // Watch stringified roles and permissions to only rebuild when they change
  final rolesStr = ref.watch(authControllerProvider.select((s) => s.user?.roles.join(',') ?? ''));
  final permsStr = ref.watch(authControllerProvider.select((s) => s.user?.effectivePermissions.join(',') ?? ''));
  final isAuthenticated = ref.watch(authControllerProvider.select((s) => s.isAuthenticated));

  return PermissionService(
    roles: rolesStr.isNotEmpty ? rolesStr.split(',') : [],
    permissions: permsStr.isNotEmpty ? permsStr.split(',') : [],
    isAuthenticated: isAuthenticated,
  );
});

class PermissionService {
  final List<String> roles;
  final List<String> permissions;
  final bool isAuthenticated;

  PermissionService({
    required this.roles,
    required this.permissions,
    required this.isAuthenticated,
  });

  bool can(String permission) {
    if (!isAuthenticated) return false;
    if (isSuperAdmin || isCompanyAdmin) return true; // Admins have all permissions
    return permissions.contains(permission);
  }

  bool hasRole(String role) {
    if (!isAuthenticated) return false;
    return roles.contains(role);
  }

  bool get isSuperAdmin => hasRole('ROLE_SUPER_ADMIN');
  bool get isCompanyAdmin => hasRole('ROLE_COMPANY_ADMIN');
  bool get isEmployee => hasRole('ROLE_EMPLOYEE');
}
