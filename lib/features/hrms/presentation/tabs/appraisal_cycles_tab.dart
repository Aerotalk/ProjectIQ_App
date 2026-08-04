import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/performance_repository.dart';

class AppraisalCyclesTab extends ConsumerWidget {
  const AppraisalCyclesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final repo = ref.watch(performanceRepositoryProvider);

    return FutureBuilder(
      future: repo.getActiveCycles(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final cycles = snapshot.data ?? [];
        if (cycles.isEmpty) return const Center(child: Text('No cycles found.'));

        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.s16),
          itemCount: cycles.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s12),
          itemBuilder: (context, index) {
            final cycle = cycles[index];
            return Container(
              padding: const EdgeInsets.all(AppSpacing.s16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(cycle.name, style: AppTypography.subtitle)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: cycle.status == 'Active' ? Colors.green.withValues(alpha: 0.1) : Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          cycle.status,
                          style: AppTypography.caption.copyWith(
                            color: cycle.status == 'Active' ? Colors.green : Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('${cycle.type} • ${cycle.period}', style: AppTypography.caption.copyWith(color: Colors.grey)),
                  const SizedBox(height: AppSpacing.s16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Completion', style: AppTypography.caption),
                      Text('${cycle.completionPercentage}%', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: cycle.completionPercentage / 100,
                    backgroundColor: Colors.grey.shade200,
                    color: cycle.completionPercentage >= 100 ? Colors.green : (isDark ? AppColors.primaryDark : AppColors.primaryLight),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
