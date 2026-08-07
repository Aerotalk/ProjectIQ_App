import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../data/expense_repository.dart';

class ExpenseBatchProcessingTab extends ConsumerWidget {
  const ExpenseBatchProcessingTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final repo = ref.watch(expenseRepositoryProvider);

    return FutureBuilder(
      future: repo.getBatches(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final batches = snapshot.data ?? [];
        if (batches.isEmpty) return const Center(child: Text('No batches found.'));

        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.s16),
          itemCount: batches.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s12),
          itemBuilder: (context, index) {
            final batch = batches[index];
            return Container(
              padding: const EdgeInsets.all(AppSpacing.s16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(batch['batchNo'], style: AppTypography.subtitle),
                      Text('Processed on: ${batch['createdAt'].toString().substring(0, 10)}', style: AppTypography.caption.copyWith(color: Colors.grey)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(AppFormatters.formatCurrency(batch['totalAmount']), style: AppTypography.subtitle.copyWith(fontWeight: FontWeight.bold)),
                      Text(batch['status'], style: AppTypography.caption.copyWith(color: Colors.green)),
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
