import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/loaders/skeleton.dart';
import '../providers/regularization_providers.dart';

class RegularizationListScreen extends ConsumerWidget {
  const RegularizationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(regularizationListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Regularization Requests'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/hrms/attendance/regularization/new'),
        child: const Icon(LucideIcons.plus),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(regularizationListProvider.future),
        child: state.when(
          data: (requests) {
            if (requests.isEmpty) {
              return const Center(child: Text('No regularization requests found.'));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.s16),
              itemCount: requests.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s12),
              itemBuilder: (context, index) {
                final req = requests[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1.0,
                    ),
                  ),
                  child: Padding(
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
                                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    LucideIcons.userCheck,
                                    color: Theme.of(context).primaryColor,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.s12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      req.employeeName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      req.date,
                                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            _buildStatusBadge(req.status),
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
                                    'In Time',
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    req.inTime,
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Out Time',
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    req.outTime,
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s12),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.s8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          width: double.infinity,
                          child: Text(
                            'Reason: ${req.reason}',
                            style: TextStyle(color: Colors.grey.shade800, fontSize: 13),
                          ),
                        ),
                        if (req.status == 'Pending') ...[
                          const SizedBox(height: AppSpacing.s16),
                          SizedBox(
                            width: double.infinity,
                            child: TextButton.icon(
                              onPressed: () => context.push('/hrms/attendance/approval-center'),
                              icon: const Icon(LucideIcons.externalLink, size: 16),
                              label: const Text('View in Approval Center'),
                              style: TextButton.styleFrom(
                                foregroundColor: Theme.of(context).primaryColor,
                                backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.s16),
            itemCount: 5,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s12),
            itemBuilder: (_, __) => const Skeleton(height: 100, width: double.infinity),
          ),
          error: (err, _) => Center(child: Text('Error: $err')),
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
