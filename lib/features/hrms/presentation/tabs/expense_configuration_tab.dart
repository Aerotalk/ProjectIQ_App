import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/expense_repository.dart';
import '../../../../shared/widgets/loaders/skeleton.dart';

class ExpenseConfigurationTab extends ConsumerWidget {
  const ExpenseConfigurationTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final repo = ref.watch(expenseRepositoryProvider);

    return FutureBuilder(
      future: repo.getCategories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.s16),
            itemCount: 3,
            separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.s12),
            itemBuilder: (context, index) => const Skeleton(height: 100, width: double.infinity, borderRadius: 8),
          );
        }
        final categories = snapshot.data ?? [];
        if (categories.isEmpty) return const Center(child: Text('No categories configured.'));

        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.s16),
          itemCount: categories.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.s12),
          itemBuilder: (context, index) {
            final category = categories[index];
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
                      Text(category['category'], style: AppTypography.subtitle),
                      Text('GL Code: ${category['glCode']}', style: AppTypography.caption.copyWith(color: Colors.grey)),
                    ],
                  ),
                  Switch(
                    value: category['active'] as bool,
                    onChanged: (val) {},
                    activeThumbColor: AppColors.primaryLight,
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
