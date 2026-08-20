import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/performance_repository.dart';
import '../../../../shared/widgets/loaders/skeleton.dart';

class PerformanceDashboardTab extends ConsumerWidget {
  const PerformanceDashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final performanceRepo = ref.watch(performanceRepositoryProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Performance Dashboard', style: AppTypography.title),
                    const SizedBox(height: 4),
                    Text(
                      'Overview of organization performance metrics and active cycles.',
                      style: AppTypography.caption.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s24),
          _buildStatCards(context, isDark),
          const SizedBox(height: AppSpacing.s24),
          Text('Goal Completion Tracking', style: AppTypography.subtitle),
          const SizedBox(height: AppSpacing.s12),
          FutureBuilder(
            future: performanceRepo.getGoals(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.s16),
            itemCount: 3,
            separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.s12),
            itemBuilder: (context, index) => const Skeleton(height: 100, width: double.infinity, borderRadius: 8),
          );
              }
              if (snapshot.hasError) {
                return const Text('Error loading goals');
              }
              final goals = snapshot.data ?? [];
              return Column(
                children: goals.take(3).map((goal) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.s12),
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
                            Expanded(child: Text(goal.title, style: AppTypography.subtitle)),
                            Text('${goal.progress.toInt()}%', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s8),
                        LinearProgressIndicator(
                          value: goal.progress / 100,
                          backgroundColor: Colors.grey.shade200,
                          color: goal.progress >= 100 ? Colors.green : (goal.progress >= 50 ? Colors.blue : Colors.orange),
                        ),
                        const SizedBox(height: AppSpacing.s8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(goal.employee.name, style: AppTypography.caption),
                            Text('Due: ${goal.dueDate}', style: AppTypography.caption),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: AppSpacing.s24),
          Text('Active Cycles', style: AppTypography.subtitle),
          const SizedBox(height: AppSpacing.s12),
          FutureBuilder(
            future: performanceRepo.getActiveCycles(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.s16),
            itemCount: 3,
            separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.s12),
            itemBuilder: (context, index) => const Skeleton(height: 100, width: double.infinity, borderRadius: 8),
          );
              }
              final cycles = snapshot.data ?? [];
              final activeCycles = cycles.where((c) => c.status == 'Active' || c.status == 'Review Phase').toList();
              
              return Column(
                children: activeCycles.map((cycle) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.s12),
                    padding: const EdgeInsets.all(AppSpacing.s16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : AppColors.cardLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cycle.name, style: AppTypography.subtitle),
                        const SizedBox(height: AppSpacing.s8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${cycle.completionPercentage}% Completed', style: AppTypography.caption),
                            Text(cycle.status, style: AppTypography.caption.copyWith(color: isDark ? AppColors.primaryDark : AppColors.primaryLight)),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s8),
                        LinearProgressIndicator(
                          value: cycle.completionPercentage / 100,
                          backgroundColor: Colors.grey.shade200,
                          color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          )
        ],
      ),
    );
  }

  Widget _buildStatCards(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _StatCard(title: 'Active Cycles', value: '3', icon: LucideIcons.clock, color: Colors.blue, isDark: isDark),
          _StatCard(title: 'Pending Self', value: '12', icon: LucideIcons.alertCircle, color: Colors.orange, isDark: isDark),
          _StatCard(title: 'Pending Manager', value: '8', icon: LucideIcons.users, color: Colors.purple, isDark: isDark),
          _StatCard(title: 'Completed', value: '145', icon: LucideIcons.checkCircle2, color: Colors.green, isDark: isDark),
          _StatCard(title: 'Avg Rating', value: '4.1', icon: LucideIcons.award, color: Colors.amber, isDark: isDark),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: AppSpacing.s12),
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
