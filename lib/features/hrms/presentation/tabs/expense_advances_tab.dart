import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../data/expense_repository.dart';
import '../../../../shared/widgets/loaders/skeleton.dart';

class ExpenseAdvancesTab extends ConsumerWidget {
  const ExpenseAdvancesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final repo = ref.watch(expenseRepositoryProvider);

    return FutureBuilder(
      future: repo.getAdvances(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.s16),
            itemCount: 3,
            separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.s12),
            itemBuilder: (context, index) => const Skeleton(height: 100, width: double.infinity, borderRadius: 8),
          );
        }
        final advances = snapshot.data ?? [];
        if (advances.isEmpty) return const Center(child: Text('No advances found.'));

        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.s16),
          itemCount: advances.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.s12),
          itemBuilder: (context, index) {
            final advance = advances[index];
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
                      Text(advance['reason'], style: AppTypography.subtitle),
                      Text(advance['advanceNo'], style: AppTypography.caption.copyWith(color: Colors.grey)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(AppFormatters.formatCurrency(advance['amount']), style: AppTypography.subtitle.copyWith(fontWeight: FontWeight.bold)),
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          advance['status'],
                          style: AppTypography.caption.copyWith(color: Colors.orange, fontWeight: FontWeight.bold),
                        ),
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
