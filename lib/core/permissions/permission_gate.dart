import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'permission_manager.dart';

// We'll create the provider later in global state, but for now we define a dummy provider or expect it to be passed
// For a robust system, the PermissionManager would be provided via Riverpod.
// We'll define a placeholder provider here that should be overridden or defined in the providers file.

final permissionManagerProvider = Provider<PermissionManager>((ref) {
  return PermissionManager(); // This will be initialized properly in the global state
});

class PermissionGate extends ConsumerWidget {
  final String permission;
  final Widget child;
  final Widget? fallback;

  const PermissionGate({
    super.key,
    required this.permission,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionManager = ref.watch(permissionManagerProvider);

    if (permissionManager.hasPermission(permission)) {
      return child;
    }

    return fallback ?? const SizedBox.shrink();
  }
}
