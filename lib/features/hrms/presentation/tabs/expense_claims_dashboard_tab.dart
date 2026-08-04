import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/expense_repository.dart';

class ExpenseClaimsDashboardTab extends ConsumerWidget {
  const ExpenseClaimsDashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final repo = ref.watch(expenseRepositoryProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Expense Overview', style: AppTypography.title),
          const SizedBox(height: AppSpacing.s16),
          Row(
            children: [
              Expanded(child: _buildStatCard(context, 'Total Claims', '1', LucideIcons.fileText, Colors.blue, isDark)),
              const SizedBox(width: AppSpacing.s12),
              Expanded(child: _buildStatCard(context, 'Pending Approval', '1', LucideIcons.clock, Colors.orange, isDark)),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          Row(
            children: [
              Expanded(child: _buildStatCard(context, 'Approved', '0', LucideIcons.checkCircle, Colors.green, isDark)),
              const SizedBox(width: AppSpacing.s12),
              Expanded(child: _buildStatCard(context, 'Total Amount', '\$250.50', LucideIcons.dollarSign, Colors.purple, isDark)),
            ],
          ),
          const SizedBox(height: AppSpacing.s24),
          Text('Recent Claims', style: AppTypography.subtitle),
          const SizedBox(height: AppSpacing.s16),
          FutureBuilder(
            future: repo.getClaims(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final claims = snapshot.data ?? [];
              if (claims.isEmpty) return const Text('No recent claims.');

              return Column(
                children: claims.map((claim) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.s12),
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
                            Text(claim['title'], style: AppTypography.subtitle),
                            Text(claim['claimNo'], style: AppTypography.caption.copyWith(color: Colors.grey)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('\$${claim['totalClaimed']}', style: AppTypography.subtitle.copyWith(fontWeight: FontWeight.bold)),
                            Text(claim['status'], style: AppTypography.caption.copyWith(color: Colors.blue)),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color, bool isDark) {
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: AppSpacing.s12),
          Text(title, style: AppTypography.caption.copyWith(color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: AppTypography.title),
        ],
      ),
    );
  }
}
