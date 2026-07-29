import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'permission_manager.dart';

class FeatureGuard {
  static String? guardRoute(
    BuildContext context, 
    GoRouterState state, 
    PermissionManager permissionManager, 
    String requiredPermission,
    {String fallbackRoute = '/dashboard'}
  ) {
    if (!permissionManager.hasPermission(requiredPermission)) {
      return fallbackRoute;
    }
    return null; // allow access
  }
}
