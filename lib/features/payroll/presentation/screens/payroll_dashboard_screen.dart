import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/loaders/skeleton.dart';
import '../providers/payroll_providers.dart';

class PayrollDashboardScreen extends ConsumerWidget {
  const PayrollDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHR = ref.watch(payrollRoleProvider).isHR;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Payroll',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
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
              ] else ...[
                _buildEmployeeSummary(context, isDark),
                const SizedBox(height: AppSpacing.s24),
              ],
              Text(
                'Quick Actions',
                style: AppTypography.subtitle.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.s16),
              _buildQuickActions(context, isHR),
              const SizedBox(height: AppSpacing.s24),
              if (isHR)
                _buildRecentRuns(context, ref, isDark)
              else
                _buildRecentPayslips(context, ref, isDark),
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
        {
          'title': 'Payroll Runs',
          'icon': LucideIcons.list,
          'route': '/hrms/payroll/runs',
          'color': Colors.blue,
        },
        {
          'title': 'Salary Inputs',
          'icon': LucideIcons.edit3,
          'route': '/hrms/payroll/inputs',
          'color': Colors.indigo,
        },
        {
          'title': 'Processing',
          'icon': LucideIcons.settings,
          'route': '/hrms/payroll/processing',
          'color': Colors.orange,
        },
        {
          'title': 'Verification',
          'icon': LucideIcons.checkSquare,
          'route': '/hrms/payroll/verification',
          'color': Colors.teal,
        },
        {
          'title': 'Payouts',
          'icon': LucideIcons.send,
          'route': '/hrms/payroll/payouts',
          'color': Colors.green,
        },
        {
          'title': 'Reimbursements',
          'icon': LucideIcons.receipt,
          'route': '/hrms/payroll/reimbursements',
          'color': Colors.purple,
        },
        {
          'title': 'IT Declarations',
          'icon': LucideIcons.fileText,
          'route': '/hrms/payroll/it-declarations',
          'color': Colors.red,
        },
        {
          'title': 'Settlements',
          'icon': LucideIcons.doorOpen,
          'route': '/hrms/payroll/settlements',
          'color': Colors.brown,
        },
      ];
    } else {
      actions = [
        {
          'title': 'My Payslips',
          'icon': LucideIcons.fileDown,
          'route': '/hrms/payroll/payslips',
          'color': Colors.blue,
        },
        {
          'title': 'Salary Details',
          'icon': LucideIcons.pieChart,
          'route': '/hrms/payroll/salary-details',
          'color': Colors.green,
        },
        {
          'title': 'Reimbursements',
          'icon': LucideIcons.receipt,
          'route': '/hrms/payroll/reimbursements',
          'color': Colors.purple,
        },
        {
          'title': 'IT Declaration',
          'icon': LucideIcons.fileText,
          'route': '/hrms/payroll/it-declarations',
          'color': Colors.red,
        },
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
                  child: Icon(action['icon'], color: action['color'], size: 24),
                ),
                const SizedBox(height: AppSpacing.s8),
                Text(
                  action['title'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmployeeSummary(BuildContext context, bool isDark) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.s24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Next Payout', style: AppTypography.caption.copyWith(color: Colors.grey)),
              const SizedBox(height: 8),
              Text('₹ 1,15,000', style: AppTypography.title),
              const SizedBox(height: 4),
              Text('Expected by 31 Jul 2026', style: AppTypography.caption.copyWith(color: Colors.green)),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.banknote, color: Colors.blue, size: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentRuns(BuildContext context, WidgetRef ref, bool isDark) {
    final runsState = ref.watch(payrollRunsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Payroll Runs', style: AppTypography.subtitle.copyWith(fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () => context.push('/hrms/payroll/runs'),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s8),
        runsState.when(
          data: (runs) {
            if (runs.isEmpty) return const Text('No recent runs.');
            return Column(
              children: runs.take(2).map<Widget>((run) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.s12),
                  child: AppCard(
                    padding: const EdgeInsets.all(AppSpacing.s16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(run.period, style: AppTypography.body.copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text('${run.employeeCount} Employees', style: AppTypography.caption.copyWith(color: Colors.grey)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(run.netAmount, style: AppTypography.body.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(run.status, style: AppTypography.caption.copyWith(color: run.status == 'Processed' ? Colors.green : Colors.orange)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const Skeleton(height: 100, width: double.infinity),
          error: (e, _) => Text('Error loading runs: $e'),
        ),
      ],
    );
  }

  Widget _buildRecentPayslips(BuildContext context, WidgetRef ref, bool isDark) {
    final payslipsState = ref.watch(payslipsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Payslips', style: AppTypography.subtitle.copyWith(fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () => context.push('/hrms/payroll/payslips'),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s8),
        payslipsState.when(
          data: (payslips) {
            if (payslips.isEmpty) return const Text('No recent payslips.');
            return Column(
              children: payslips.take(2).map<Widget>((payslip) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.s12),
                  child: AppCard(
                    padding: const EdgeInsets.all(AppSpacing.s16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: (isDark ? AppColors.primaryDark : AppColors.primaryLight).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                              child: Icon(LucideIcons.fileText, size: 20, color: isDark ? AppColors.primaryDark : AppColors.primaryLight),
                            ),
                            const SizedBox(width: AppSpacing.s12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(payslip.period, style: AppTypography.body.copyWith(fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text('Net: ${payslip.netSalary}', style: AppTypography.caption.copyWith(color: Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(LucideIcons.download, size: 18),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Action executed successfully!')));
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const Skeleton(height: 80, width: double.infinity),
          error: (e, _) => Text('Error: $e'),
        ),
      ],
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
