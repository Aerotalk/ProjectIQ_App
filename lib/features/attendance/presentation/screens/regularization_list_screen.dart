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
                return Card(
                  child: ListTile(
                    title: Text(req.employeeName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Date: ${req.date}\nIn: ${req.inTime} - Out: ${req.outTime}\nReason: ${req.reason}'),
                    isThreeLine: true,
                    trailing: _buildStatusBadge(req.status),
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
