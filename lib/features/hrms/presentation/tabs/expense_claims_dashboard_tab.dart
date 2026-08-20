import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../data/expense_repository.dart';
import '../../../../shared/widgets/loaders/skeleton.dart';

class ExpenseClaimsDashboardTab extends ConsumerWidget {
  const ExpenseClaimsDashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final repo = ref.watch(expenseRepositoryProvider);

    return FutureBuilder(
      future: repo.getClaims(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.s16),
            itemCount: 3,
            separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.s12),
            itemBuilder: (context, index) => const Skeleton(height: 100, width: double.infinity, borderRadius: 8),
          );
        }
        
        final claims = snapshot.data ?? [];
        final int totalClaims = claims.length;

        final int approvedClaims = claims.where((c) => c['status'] == 'Approved').length;
        final double totalAmount = claims.where((c) => c['status'] == 'Approved' || c['status'] == 'Pending').fold(0.0, (sum, c) {
          double amount = 0.0;
          if (c['totalClaimed'] is num) {
            amount = (c['totalClaimed'] as num).toDouble();
          } else if (c['totalClaimed'] is String) {
            amount = double.tryParse(c['totalClaimed']) ?? 0.0;
          }
          return sum + amount;
        });

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Expense Overview', style: AppTypography.title),
              const SizedBox(height: AppSpacing.s16),
              Row(
                children: [
                  Expanded(child: _buildStatCard(context, 'Total Claims', totalClaims.toString(), LucideIcons.fileText, Colors.blue, isDark)),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(child: _buildStatCard(context, 'Approved', approvedClaims.toString(), LucideIcons.checkCircle, Colors.green, isDark)),
                ],
              ),
              const SizedBox(height: AppSpacing.s12),
              Row(
                children: [
                  Expanded(child: _buildStatCard(context, 'Pending Approval', claims.where((c) => c['status'] == 'Pending').length.toString(), LucideIcons.clock, Colors.orange, isDark)),
                  const SizedBox(width: AppSpacing.s16),
                  Expanded(child: _buildStatCard(context, 'Total Amount', AppFormatters.formatCurrency(totalAmount), LucideIcons.dollarSign, Colors.purple, isDark)),
                ],
              ),
              const SizedBox(height: AppSpacing.s24),
              Text('Recent Claims', style: AppTypography.subtitle),
              const SizedBox(height: AppSpacing.s16),
              if (claims.isEmpty) const Text('No recent claims.') else 
              Column(
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
                            Text(AppFormatters.formatCurrency(claim['totalClaimed']), style: AppTypography.subtitle.copyWith(fontWeight: FontWeight.bold)),
                            Text(claim['status'], style: AppTypography.caption.copyWith(color: Colors.blue)),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
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
