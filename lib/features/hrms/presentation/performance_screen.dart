import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import 'tabs/performance_dashboard_tab.dart';
import 'tabs/goals_list_tab.dart';
import 'tabs/appraisal_cycles_tab.dart';
import 'tabs/employee_reviews_tab.dart';
import 'tabs/manager_reviews_tab.dart';
import 'tabs/calibration_tab.dart';
import 'tabs/performance_templates_tab.dart';
import 'tabs/performance_reports_tab.dart';

class PerformanceScreen extends ConsumerStatefulWidget {
  const PerformanceScreen({super.key});

  @override
  ConsumerState<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends ConsumerState<PerformanceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Performance Management', style: AppTypography.title.copyWith(fontWeight: FontWeight.w700)),
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        elevation: 0,
        scrolledUnderElevation: 4,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: isDark ? AppColors.primaryDark : AppColors.primaryLight,
          labelColor: isDark ? AppColors.primaryDark : AppColors.primaryLight,
          unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
          tabs: const [
            Tab(text: 'Dashboard', icon: Icon(LucideIcons.layoutDashboard, size: 20)),
            Tab(text: 'Appraisal Cycles', icon: Icon(LucideIcons.refreshCw, size: 20)),
            Tab(text: 'Goals & KRAs', icon: Icon(LucideIcons.target, size: 20)),
            Tab(text: 'Employee Reviews', icon: Icon(LucideIcons.userCheck, size: 20)),
            Tab(text: 'Manager Reviews', icon: Icon(LucideIcons.users, size: 20)),
            Tab(text: 'Calibration', icon: Icon(LucideIcons.scale, size: 20)),
            Tab(text: 'Templates', icon: Icon(LucideIcons.fileText, size: 20)),
            Tab(text: 'Reports', icon: Icon(LucideIcons.barChart2, size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          PerformanceDashboardTab(),
          AppraisalCyclesTab(),
          GoalsListTab(),
          EmployeeReviewsTab(),
          ManagerReviewsTab(),
          CalibrationTab(),
          PerformanceTemplatesTab(),
          PerformanceReportsTab(),
        ],
      ),
    );
  }
}
