import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/loaders/skeleton.dart';
import '../providers/payroll_providers.dart';

class PayrollRunsScreen extends ConsumerWidget {
  const PayrollRunsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(payslipsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Employee Payrolls',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(payslipsProvider.future),
        child: state.when(
          data: (payslips) {
            if (payslips.isEmpty) {
              return const Center(child: Text('No employee payrolls found.'));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.s16),
              itemCount: payslips.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSpacing.s12),
              itemBuilder: (context, index) {
                final payslip = payslips[index];
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    payslip.employeeName.substring(0, payslip.employeeName.length >= 2 ? 2 : payslip.employeeName.length).toUpperCase(),
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 16),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.s12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    payslip.employeeName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${payslip.period} • ${payslip.department}',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          _buildStatusBadge(payslip.status),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      const Divider(height: 1),
                      const SizedBox(height: AppSpacing.s16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Gross Pay',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  payslip.grossSalary,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Net Pay',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  payslip.netSalary,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            // Route to Payroll Processing or Verification
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Opening details for ${payslip.employeeName}...'),
                              ),
                            );
                          },
                          child: const Text('View Employee Actions'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          loading: () => ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.s16),
            itemCount: 3,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.s12),
            itemBuilder: (_, _) =>
                const Skeleton(height: 150, width: double.infinity),
          ),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'processed':
        color = Colors.green;
        break;
      case 'processing':
        color = Colors.orange;
        break;
      default:
        color = Colors.blue;
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
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
