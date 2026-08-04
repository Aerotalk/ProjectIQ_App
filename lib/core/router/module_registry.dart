import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../permissions/permission_service.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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

// Core Modules (Bottom Navigation)
const List<AppModule> _coreModules = [
  AppModule(
    id: 'dashboard',
    title: 'Home',
    icon: LucideIcons.home,
    route: '/dashboard',
  ),
  AppModule(
    id: 'attendance_nav',
    title: 'Attendance',
    icon: LucideIcons.clock,
    route: '/attendance',
    permission: 'attendance.view',
  ),
  AppModule(
    id: 'requests',
    title: 'Requests',
    icon: LucideIcons.fileText,
    route: '/requests',
    permission: 'requests.view', // Assumed permission for employee requests
  ),
  AppModule(
    id: 'hrms',
    title: 'HRMS',
    icon: LucideIcons.layers,
    route: '/hrms',
    permission: 'employee.view', // Only those who can view employees get the HRMS tab
  ),
  AppModule(
    id: 'approvals',
    title: 'Approvals',
    icon: LucideIcons.checkCircle,
    route: '/approvals',
    permission: 'approvals.view', // Managers/HR
  ),
  AppModule(
    id: 'notifications',
    title: 'Alerts',
    icon: LucideIcons.bell,
    route: '/notifications',
  ),
  AppModule(
    id: 'profile',
    title: 'Profile',
    icon: LucideIcons.user,
    route: '/profile',
  ),
];

// HRMS Inner Modules (The App Launcher inside the HRMS tab)
const List<AppModule> _hrmsModules = [
  AppModule(
    id: 'employees',
    title: 'Directory',
    icon: LucideIcons.users,
    route: '/hrms/employees',
    permission: 'employee.view',
    visibility: ModuleVisibility.hidden,
  ),
  AppModule(
    id: 'departments',
    title: 'Departments',
    icon: LucideIcons.building,
    route: '/hrms/departments',
    permission: 'department.view',
    visibility: ModuleVisibility.hidden,
  ),
  AppModule(
    id: 'designations',
    title: 'Designations',
    icon: LucideIcons.briefcase,
    route: '/hrms/designations',
    permission: 'designation.view',
    visibility: ModuleVisibility.hidden,
  ),
  AppModule(
    id: 'attendance_admin',
    title: 'Workforce',
    icon: LucideIcons.clock,
    route: '/hrms/attendance',
    visibility: ModuleVisibility.hidden,
  ),
  AppModule(
    id: 'payroll',
    title: 'Payroll',
    icon: LucideIcons.banknote,
    route: '/hrms/payroll',
    permission: 'payroll.view',
    visibility: ModuleVisibility.hidden,
  ),
  AppModule(
    id: 'expense',
    title: 'Expense Claims',
    icon: LucideIcons.receipt,
    route: '/hrms/expense-claims',
    permission: 'expense.view',
    visibility: ModuleVisibility.hidden,
  ),
  AppModule(
    id: 'performance',
    title: 'Performance',
    icon: LucideIcons.trendingUp,
    route: '/hrms/performance',
    permission: 'performance.view',
    visibility: ModuleVisibility.hidden,
  ),
];

final List<AppModule> _allModules = [..._coreModules, ..._hrmsModules];

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
    final modules = permittedModules
        .where((m) => m.visibility == ModuleVisibility.bottomNav)
        .toList();
        
    // Conflict resolution: If user has BOTH Requests and Approvals, combine them or just show Approvals if HRMS is present.
    // The spec requires maximum 5 items to look good.
    final hasHrms = modules.any((m) => m.id == 'hrms');
    
    return modules.where((m) {
      // If user has HRMS (HR role), hide Requests & generic Attendance in bottom nav to save space, 
      // because Attendance is also in HRMS module for HR.
      if (hasHrms) {
        if (m.id == 'requests' || m.id == 'attendance_nav') return false;
      }
      return true;
    }).take(5).toList(); // Ensure max 5 items
  }

  // Helper for HRMS Grid (App Launcher)
  List<AppModule> get hrmsGridModules {
    return _hrmsModules.where((module) {
      if (module.permission == null) return true;
      return _permissionService.can(module.permission!);
    }).toList();
  }
}
