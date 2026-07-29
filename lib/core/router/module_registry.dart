import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../permissions/permission_service.dart';

enum ModuleVisibility {
  bottomNav, // Shows up in the primary bottom navigation
  drawer,    // Shows up in a side drawer or "More" menu
  hidden,    // Accessible via route but not visible in standard navigation menus
}

class AppModule {
  final String id;
  final String title;
  final IconData icon;
  final String route;
  final String? permission;
  final ModuleVisibility visibility;

  const AppModule({
    required this.id,
    required this.title,
    required this.icon,
    required this.route,
    this.permission,
    this.visibility = ModuleVisibility.bottomNav,
  });
}

// The master list of all possible modules in the HRMS
const List<AppModule> _allModules = [
  AppModule(
    id: 'dashboard',
    title: 'Dashboard',
    icon: Icons.dashboard_rounded,
    route: '/dashboard',
  ),
  AppModule(
    id: 'employees',
    title: 'Employees',
    icon: Icons.people_rounded,
    route: '/employees',
    permission: 'employee.view',
  ),
  AppModule(
    id: 'attendance',
    title: 'Attendance',
    icon: Icons.access_time_rounded,
    route: '/attendance',
    permission: 'attendance.view',
  ),
  AppModule(
    id: 'leave',
    title: 'Leave',
    icon: Icons.date_range_rounded,
    route: '/leave',
    permission: 'leave.view',
  ),
  AppModule(
    id: 'payroll',
    title: 'Payroll',
    icon: Icons.payments_rounded,
    route: '/payroll',
    permission: 'payroll.view',
    visibility: ModuleVisibility.drawer,
  ),
  AppModule(
    id: 'expense',
    title: 'Expenses',
    icon: Icons.receipt_long_rounded,
    route: '/expense-claims',
    permission: 'expense.view',
    visibility: ModuleVisibility.drawer,
  ),
];

final moduleRegistryProvider = Provider<ModuleRegistry>((ref) {
  return ModuleRegistry(ref.watch(permissionServiceProvider));
});

class ModuleRegistry {
  final PermissionService _permissionService;

  ModuleRegistry(this._permissionService);

  // Returns all modules the user is allowed to see
  List<AppModule> get permittedModules {
    return _allModules.where((module) {
      if (module.permission == null) return true;
      return _permissionService.can(module.permission!);
    }).toList();
  }

  // Helper for Bottom Navigation
  List<AppModule> get bottomNavModules {
    return permittedModules
        .where((m) => m.visibility == ModuleVisibility.bottomNav)
        .toList();
  }

  // Helper for Drawer or More Menu
  List<AppModule> get drawerModules {
    return permittedModules
        .where((m) => m.visibility == ModuleVisibility.drawer)
        .toList();
  }
}
