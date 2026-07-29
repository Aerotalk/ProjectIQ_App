import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/authentication/presentation/auth_controller.dart';
import '../../features/authentication/domain/user.dart';

final permissionServiceProvider = Provider<PermissionService>((ref) {
  final authState = ref.watch(authControllerProvider);
  return PermissionService(authState.user);
});

class PermissionService {
  final User? _user;

  PermissionService(this._user);

  bool can(String permission) {
    if (_user == null) return false;
    return _user!.hasPermission(permission);
  }

  bool hasRole(String role) {
    if (_user == null) return false;
    return _user!.hasRole(role);
  }

  bool get isSuperAdmin => hasRole('ROLE_SUPER_ADMIN');
  bool get isCompanyAdmin => hasRole('ROLE_COMPANY_ADMIN');
  bool get isEmployee => hasRole('ROLE_EMPLOYEE');
}
