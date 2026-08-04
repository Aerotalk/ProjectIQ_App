import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/loaders/skeleton.dart';
import '../providers/attendance_dashboard_providers.dart';
import '../widgets/attendance_kpi_card.dart';
import '../widgets/quick_action_button.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AttendanceDashboardScreen extends ConsumerWidget {
  const AttendanceDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(attendanceDashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance & Workforce'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(attendanceDashboardProvider.future),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildQuickActions(context),
              const SizedBox(height: AppSpacing.s24),
              _buildSectionTitle(context, 'Dashboard Summary', LucideIcons.barChart2),
              const SizedBox(height: AppSpacing.s16),
              state.when(
                data: (data) => _buildKpiGrid(context, data.kpis),
                loading: () => _buildKpiSkeletons(),
                error: (err, stack) => _buildError(err),
              ),
              const SizedBox(height: AppSpacing.s24),
              _buildSectionTitle(context, "Today's Attendance", LucideIcons.users),
              const SizedBox(height: AppSpacing.s16),
              state.when(
                data: (data) => _buildTodayAttendance(context, data.todayAttendance),
                loading: () => const Skeleton(height: 150, width: double.infinity),
                error: (err, stack) => _buildError(err),
              ),
              const SizedBox(height: AppSpacing.s24),
              _buildSectionTitle(context, 'Pending Leave Requests', LucideIcons.fileText),
              const SizedBox(height: AppSpacing.s16),
              state.when(
                data: (data) => _buildPendingLeaves(context, data.pendingLeaves),
                loading: () => const Skeleton(height: 100, width: double.infinity),
                error: (err, stack) => _buildError(err),
              ),
              const SizedBox(height: AppSpacing.s32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        const SizedBox(width: AppSpacing.s8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.s12,
      crossAxisSpacing: AppSpacing.s12,
      childAspectRatio: 0.7,
      children: [
        QuickActionButton(
          icon: LucideIcons.calendar,
          label: 'Calendar',
          color: Colors.blue,
          onTap: () => context.push('/hrms/attendance/calendar'),
        ),
        QuickActionButton(
          icon: LucideIcons.checkSquare,
          label: 'Regularize',
          color: Colors.cyan,
          onTap: () => context.push('/hrms/attendance/regularization'),
        ),
        QuickActionButton(
          icon: LucideIcons.clock,
          label: 'Shifts',
          color: Colors.orange,
          onTap: () => context.push('/hrms/attendance/shifts'),
        ),
        QuickActionButton(
          icon: LucideIcons.fileText,
          label: 'Leaves',
          color: Colors.purple,
          onTap: () => context.push('/hrms/attendance/leaves'),
        ),
        QuickActionButton(
          icon: LucideIcons.clipboardList,
          label: 'Daily Logs',
          color: Colors.indigo,
          onTap: () => context.push('/hrms/attendance/daily-logs'),
        ),
        QuickActionButton(
          icon: LucideIcons.alertTriangle,
          label: 'Exceptions',
          color: Colors.red,
          onTap: () => context.push('/hrms/attendance/exceptions'),
        ),
        QuickActionButton(
          icon: LucideIcons.doorOpen,
          label: 'Out-pass',
          color: Colors.teal,
          onTap: () => context.push('/hrms/attendance/permissions'),
        ),
      ],
    ).animate().fade(duration: 400.ms).slideY(begin: 0.1, curve: Curves.easeOutQuad);
  }

  Widget _buildKpiGrid(BuildContext context, dynamic kpis) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.s12,
      crossAxisSpacing: AppSpacing.s12,
      childAspectRatio: 1.5,
      children: [
        AttendanceKpiCard(
          label: 'Present Today',
          value: kpis.present,
          icon: LucideIcons.users,
          color: Colors.green,
          bgColor: Colors.green.withValues(alpha: 0.1),
          onTap: () {},
        ),
        AttendanceKpiCard(
          label: 'Absent',
          value: kpis.absent,
          icon: LucideIcons.userMinus,
          color: Colors.red,
          bgColor: Colors.red.withValues(alpha: 0.1),
          onTap: () {},
        ),
        AttendanceKpiCard(
          label: 'Late Arrivals',
          value: kpis.lateArrivals,
          icon: LucideIcons.clock,
          color: Colors.orange,
          bgColor: Colors.orange.withValues(alpha: 0.1),
          onTap: () {},
        ),
        AttendanceKpiCard(
          label: 'On Leave',
          value: kpis.onLeave,
          icon: LucideIcons.calendar,
          color: Colors.blue,
          bgColor: Colors.blue.withValues(alpha: 0.1),
          onTap: () {},
        ),
      ],
    ).animate().fade(duration: 400.ms, delay: 100.ms).slideY(begin: 0.1, curve: Curves.easeOutQuad);
  }

  Widget _buildKpiSkeletons() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.s12,
      crossAxisSpacing: AppSpacing.s12,
      childAspectRatio: 1.5,
      children: List.generate(4, (index) => const Skeleton(width: double.infinity, height: double.infinity)),
    );
  }

  Widget _buildTodayAttendance(BuildContext context, List<dynamic> attendance) {
    if (attendance.isEmpty) {
      return _buildEmptyState(context, 'No attendance records today.');
    }
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.2)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: attendance.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final record = attendance[index];
          return ListTile(
            title: Text(record.employeeName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            subtitle: Text('Shift: ${record.shift} • In: ${record.checkInTime}'),
            trailing: _buildStatusBadge(record.status),
            dense: true,
          );
        },
      ),
    ).animate().fade(duration: 400.ms, delay: 200.ms).slideY(begin: 0.1, curve: Curves.easeOutQuad);
  }

  Widget _buildPendingLeaves(BuildContext context, List<dynamic> leaves) {
    if (leaves.isEmpty) {
      return _buildEmptyState(context, 'No pending leave requests.');
    }
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.2)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: leaves.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final leave = leaves[index];
          return ListTile(
            title: Text(leave.employeeName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            subtitle: Text('${leave.leaveType} • ${leave.days} Days'),
            trailing: const Icon(LucideIcons.chevronRight, size: 16),
            dense: true,
          );
        },
      ),
    ).animate().fade(duration: 400.ms, delay: 300.ms).slideY(begin: 0.1, curve: Curves.easeOutQuad);
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'present':
        color = Colors.green;
        break;
      case 'absent':
        color = Colors.red;
        break;
      case 'late':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(LucideIcons.inbox, size: 32, color: Theme.of(context).disabledColor),
          const SizedBox(height: AppSpacing.s12),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).disabledColor,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(Object error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: AppColors.destructiveLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.destructiveLight.withValues(alpha: 0.3)),
      ),
      child: Text(
        'Failed to load data: $error',
        style: const TextStyle(color: AppColors.destructiveLight),
      ),
    );
  }
}
