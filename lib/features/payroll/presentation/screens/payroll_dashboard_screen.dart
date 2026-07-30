import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/loaders/skeleton.dart';
import '../../../authentication/presentation/auth_controller.dart';
import '../providers/payroll_providers.dart';

class PayrollDashboardScreen extends ConsumerWidget {
  const PayrollDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    final isHR = user?.hasRole('ROLE_SUPER_ADMIN') ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payroll', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(payrollDashboardProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isHR) ...[
                _buildKPIs(context, ref),
                const SizedBox(height: AppSpacing.s24),
              ],
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
              _buildQuickActions(context, isHR),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKPIs(BuildContext context, WidgetRef ref) {
    final kpiState = ref.watch(payrollDashboardProvider);

    return kpiState.when(
      data: (kpis) {
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _KPICard(
                    title: 'Current Period',
                    value: kpis.currentPeriod,
                    icon: LucideIcons.calendar,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: _KPICard(
                    title: 'Pending Payroll',
                    value: kpis.pendingPayrollCount.toString(),
                    icon: LucideIcons.clock,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s12),
            Row(
              children: [
                Expanded(
                  child: _KPICard(
                    title: 'Processed',
                    value: kpis.processedCount.toString(),
                    icon: LucideIcons.checkCircle,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: _KPICard(
                    title: 'Pending Payout',
                    value: kpis.pendingPayoutCount.toString(),
                    icon: LucideIcons.banknote,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        );
      },
      loading: () => const Column(
        children: [
          Row(
            children: [
              Expanded(child: Skeleton(height: 100)),
              SizedBox(width: AppSpacing.s12),
              Expanded(child: Skeleton(height: 100)),
            ],
          ),
          SizedBox(height: AppSpacing.s12),
          Row(
            children: [
              Expanded(child: Skeleton(height: 100)),
              SizedBox(width: AppSpacing.s12),
              Expanded(child: Skeleton(height: 100)),
            ],
          ),
        ],
      ),
      error: (e, _) => Center(child: Text('Error loading KPIs: $e')),
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isHR) {
    List<Map<String, dynamic>> actions = [];

    if (isHR) {
      actions = [
        {'title': 'Payroll Runs', 'icon': LucideIcons.list, 'route': '/hrms/payroll/runs', 'color': Colors.blue},
        {'title': 'Salary Inputs', 'icon': LucideIcons.edit3, 'route': '/hrms/payroll/inputs', 'color': Colors.indigo},
        {'title': 'Processing', 'icon': LucideIcons.settings, 'route': '/hrms/payroll/processing', 'color': Colors.orange},
        {'title': 'Verification', 'icon': LucideIcons.checkSquare, 'route': '/hrms/payroll/verification', 'color': Colors.teal},
        {'title': 'Payouts', 'icon': LucideIcons.send, 'route': '/hrms/payroll/payouts', 'color': Colors.green},
        {'title': 'Reimbursements', 'icon': LucideIcons.receipt, 'route': '/hrms/payroll/reimbursements', 'color': Colors.purple},
        {'title': 'IT Declarations', 'icon': LucideIcons.fileText, 'route': '/hrms/payroll/it-declarations', 'color': Colors.red},
        {'title': 'Settlements', 'icon': LucideIcons.doorOpen, 'route': '/hrms/payroll/settlements', 'color': Colors.brown},
      ];
    } else {
      actions = [
        {'title': 'My Payslips', 'icon': LucideIcons.fileDown, 'route': '/hrms/payroll/payslips', 'color': Colors.blue},
        {'title': 'Salary Details', 'icon': LucideIcons.pieChart, 'route': '/hrms/payroll/salary-details', 'color': Colors.green},
        {'title': 'Reimbursements', 'icon': LucideIcons.receipt, 'route': '/hrms/payroll/reimbursements', 'color': Colors.purple},
        {'title': 'IT Declaration', 'icon': LucideIcons.fileText, 'route': '/hrms/payroll/it-declarations', 'color': Colors.red},
      ];
    }

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.s12,
      crossAxisSpacing: AppSpacing.s12,
      childAspectRatio: 0.9,
      children: actions.map((action) {
        return InkWell(
          onTap: () => context.push(action['route']),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300, width: 1.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.s12),
                  decoration: BoxDecoration(
                    color: (action['color'] as Color).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Icon(
                    action['icon'],
                    color: action['color'],
                    size: 24,
                  ),
                ),
                const SizedBox(height: AppSpacing.s8),
                Text(
                  action['title'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _KPICard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _KPICard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
