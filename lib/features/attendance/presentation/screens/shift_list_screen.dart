import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/loaders/skeleton.dart';
import '../providers/shift_providers.dart';

class ShiftListScreen extends ConsumerWidget {
  const ShiftListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(shiftListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shift Master'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/hrms/attendance/shifts/new'),
        child: const Icon(LucideIcons.plus),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(shiftListProvider.future),
        child: state.when(
          data: (shifts) {
            if (shifts.isEmpty) {
              return const Center(child: Text('No shifts found.'));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.s16),
              itemCount: shifts.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s12),
              itemBuilder: (context, index) {
                final shift = shifts[index];
                return Card(
                  child: ListTile(
                    title: Text(shift.shiftName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Code: ${shift.shiftCode}\nTimings: ${shift.startTime} - ${shift.endTime}\nGrace Time: ${shift.graceTimeMinutes} mins'),
                    isThreeLine: true,
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
}
