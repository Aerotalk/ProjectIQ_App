import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/performance_repository.dart';
import '../../../../shared/widgets/loaders/skeleton.dart';

class ManagerReviewsTab extends ConsumerWidget {
  const ManagerReviewsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final repo = ref.watch(performanceRepositoryProvider);

    return FutureBuilder(
      future: repo.getManagerReviews(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.s16),
            itemCount: 3,
            separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.s12),
            itemBuilder: (context, index) => const Skeleton(height: 100, width: double.infinity, borderRadius: 8),
          );
        }
        final reviews = snapshot.data ?? [];
        if (reviews.isEmpty) return const Center(child: Text('No manager reviews pending.'));

        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.s16),
          itemCount: reviews.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.s12),
          itemBuilder: (context, index) {
            final review = reviews[index];
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
                      Text(review['employee'], style: AppTypography.subtitle),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          review['status'],
                          style: AppTypography.caption.copyWith(color: Colors.orange, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  Text('Cycle: ${review['cycle']}', style: AppTypography.body),
                  const SizedBox(height: AppSpacing.s4),
                  Text('Overall Rating: ${review['overallRating']}', style: AppTypography.caption.copyWith(color: Colors.grey)),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
