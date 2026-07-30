import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../providers/leave_providers.dart';
import '../providers/regularization_providers.dart';
import '../providers/attendance_exception_providers.dart';
import '../providers/permission_providers.dart';

class ApprovalCenterScreen extends ConsumerStatefulWidget {
  const ApprovalCenterScreen({super.key});

  @override
  ConsumerState<ApprovalCenterScreen> createState() => _ApprovalCenterScreenState();
}

class _ApprovalCenterScreenState extends ConsumerState<ApprovalCenterScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleAction(String type, String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$type $action Successfully'),
        backgroundColor: action == 'Approved' ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Approval Center', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
          tabs: const [
            Tab(text: 'Leaves'),
            Tab(text: 'Regularizations'),
            Tab(text: 'Permissions'),
            Tab(text: 'Exceptions'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLeavesTab(),
          _buildRegularizationsTab(),
          _buildPermissionsTab(),
          _buildExceptionsTab(),
        ],
      ),
    );
  }

  Widget _buildLeavesTab() {
    final state = ref.watch(leaveListProvider);
    return state.when(
      data: (leaves) {
        final pending = leaves.where((l) => l.status == 'Pending').toList();
        if (pending.isEmpty) {
          return const Center(child: Text('No pending leave requests.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.s16),
          itemCount: pending.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s12),
          itemBuilder: (context, index) {
            final leave = pending[index];
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300, width: 1.0),
              ),
              padding: const EdgeInsets.all(AppSpacing.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(leave.employeeName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('${leave.leaveType} • ${leave.durationDays} Days', style: TextStyle(color: Colors.grey.shade700)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _handleAction('Leave', 'Rejected'),
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                          child: const Text('Reject'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => _handleAction('Leave', 'Approved'),
                          style: FilledButton.styleFrom(backgroundColor: Colors.green),
                          child: const Text('Approve'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildRegularizationsTab() {
    final state = ref.watch(regularizationListProvider);
    return state.when(
      data: (regs) {
        final pending = regs.where((r) => r.status == 'Pending').toList();
        if (pending.isEmpty) {
          return const Center(child: Text('No pending regularization requests.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.s16),
          itemCount: pending.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s12),
          itemBuilder: (context, index) {
            final reg = pending[index];
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300, width: 1.0),
              ),
              padding: const EdgeInsets.all(AppSpacing.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(reg.employeeName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('Date: ${reg.date} • Reason: ${reg.reason}', style: TextStyle(color: Colors.grey.shade700)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _handleAction('Regularization', 'Rejected'),
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                          child: const Text('Reject'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => _handleAction('Regularization', 'Approved'),
                          style: FilledButton.styleFrom(backgroundColor: Colors.green),
                          child: const Text('Approve'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildPermissionsTab() {
    final state = ref.watch(permissionListProvider);
    return state.when(
      data: (perms) {
        final pending = perms.where((p) => p.status == 'Pending').toList();
        if (pending.isEmpty) {
          return const Center(child: Text('No pending out-pass requests.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.s16),
          itemCount: pending.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s12),
          itemBuilder: (context, index) {
            final perm = pending[index];
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300, width: 1.0),
              ),
              padding: const EdgeInsets.all(AppSpacing.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(perm.employeeName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('Type: ${perm.permissionType} • Date: ${perm.permissionDate}', style: TextStyle(color: Colors.grey.shade700)),
                  const SizedBox(height: 4),
                  Text('Time: ${perm.startTime} to ${perm.endTime}', style: TextStyle(color: Colors.grey.shade700)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _handleAction('Out-pass', 'Rejected'),
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                          child: const Text('Reject'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => _handleAction('Out-pass', 'Approved'),
                          style: FilledButton.styleFrom(backgroundColor: Colors.green),
                          child: const Text('Approve'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildExceptionsTab() {
    final state = ref.watch(attendanceExceptionListProvider);
    return state.when(
      data: (exceptions) {
        final pending = exceptions.where((e) => e.resolved == false).toList();
        if (pending.isEmpty) {
          return const Center(child: Text('No pending exceptions.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.s16),
          itemCount: pending.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s12),
          itemBuilder: (context, index) {
            final exc = pending[index];
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300, width: 1.0),
              ),
              padding: const EdgeInsets.all(AppSpacing.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(exc.employeeName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('Exception: ${exc.exceptionType} • ${exc.date}', style: TextStyle(color: Colors.red.shade700)),
                  const SizedBox(height: 4),
                  Text(exc.description, style: TextStyle(color: Colors.grey.shade700)),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => _handleAction('Exception', 'Resolved'),
                      child: const Text('Mark as Resolved'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}
