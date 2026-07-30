import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/loaders/skeleton.dart';
import '../../../authentication/presentation/auth_controller.dart';
import '../providers/payroll_providers.dart';

class ReimbursementListScreen extends ConsumerWidget {
  const ReimbursementListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reimbursementsProvider);
    final user = ref.watch(authControllerProvider).user;
    final isHR = user?.hasRole('ROLE_SUPER_ADMIN') ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(isHR ? 'Reimbursement Claims' : 'My Reimbursements', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      floatingActionButton: !isHR ? FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('New Claim coming soon')));
        },
        child: const Icon(LucideIcons.plus),
      ) : null,
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(reimbursementsProvider.future),
        child: state.when(
          data: (claims) {
            if (claims.isEmpty) {
              return const Center(child: Text('No claims found.'));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.s16),
              itemCount: claims.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s12),
              itemBuilder: (context, index) {
                final claim = claims[index];
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
                                padding: const EdgeInsets.all(AppSpacing.s8),
                                decoration: BoxDecoration(
                                  color: Colors.purple.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(LucideIcons.receipt, color: Colors.purple, size: 20),
                              ),
                              const SizedBox(width: AppSpacing.s12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isHR ? claim.employeeName : claim.claimType,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    claim.submittedDate,
                                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          _buildStatusBadge(claim.status),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      const Divider(height: 1),
                      const SizedBox(height: AppSpacing.s16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Amount', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                          Text(claim.amount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Remarks: ${claim.remarks}', style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                      if (isHR && claim.status == 'Pending') ...[
                        const SizedBox(height: AppSpacing.s16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                                child: const Text('Reject'),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.s12),
                            Expanded(
                              child: FilledButton(
                                onPressed: () {},
                                style: FilledButton.styleFrom(backgroundColor: Colors.green),
                                child: const Text('Approve'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              },
            );
          },
          loading: () => ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.s16),
            itemCount: 3,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s12),
            itemBuilder: (_, __) => const Skeleton(height: 120, width: double.infinity),
          ),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'approved': color = Colors.green; break;
      case 'rejected': color = Colors.red; break;
      default: color = Colors.orange;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
