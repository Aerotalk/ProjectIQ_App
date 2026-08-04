import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/performance_repository.dart';

class CalibrationTab extends ConsumerWidget {
  const CalibrationTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final repo = ref.watch(performanceRepositoryProvider);

    return FutureBuilder(
      future: repo.getCalibrationRecords(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final records = snapshot.data ?? [];
        if (records.isEmpty) return const Center(child: Text('No calibration records found.'));

        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.s16),
          itemCount: records.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s12),
          itemBuilder: (context, index) {
            final record = records[index];
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
                      Text(record['employee'], style: AppTypography.subtitle),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: record['status'] == 'Finalized' ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          record['status'],
                          style: AppTypography.caption.copyWith(
                            color: record['status'] == 'Finalized' ? Colors.green : Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Current Rating', style: AppTypography.caption.copyWith(color: Colors.grey)),
                          Text('${record['currentRating']}', style: AppTypography.title.copyWith(fontSize: 16)),
                        ],
                      ),
                      const Icon(Icons.arrow_forward, color: Colors.grey, size: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Proposed Rating', style: AppTypography.caption.copyWith(color: Colors.grey)),
                          Text('${record['proposedRating']}', style: AppTypography.title.copyWith(fontSize: 16, color: AppColors.primaryLight)),
                        ],
                      ),
                    ],
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
