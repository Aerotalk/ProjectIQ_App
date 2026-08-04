import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/performance_repository.dart';
import '../../data/models/performance_models.dart';

class GoalsListTab extends ConsumerStatefulWidget {
  const GoalsListTab({super.key});

  @override
  ConsumerState<GoalsListTab> createState() => _GoalsListTabState();
}

class _GoalsListTabState extends ConsumerState<GoalsListTab> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final performanceRepo = ref.watch(performanceRepositoryProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search goals...',
                    prefixIcon: const Icon(LucideIcons.search, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade300),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(LucideIcons.plus, size: 16),
                label: const Text('New Goal'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              )
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Goal>>(
            future: performanceRepo.getGoals(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text('Error loading goals'));
              }
              
              final goals = snapshot.data ?? [];
              final filteredGoals = goals.where((g) => 
                g.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                g.employee.name.toLowerCase().contains(_searchQuery.toLowerCase())
              ).toList();

              if (filteredGoals.isEmpty) {
                return const Center(child: Text('No goals found'));
              }

              return ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.s16),
                itemCount: filteredGoals.length,
                separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.s12),
                itemBuilder: (context, index) {
                  final goal = filteredGoals[index];
                  return _GoalCard(goal: goal, isDark: isDark);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _GoalCard extends StatelessWidget {
  final Goal goal;
  final bool isDark;

  const _GoalCard({required this.goal, required this.isDark});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed': return Colors.green;
      case 'In Progress': return Colors.blue;
      case 'Not Started': return Colors.grey;
      case 'Under Review': return Colors.orange;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(goal.title, style: AppTypography.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(goal.category, style: AppTypography.caption.copyWith(color: Colors.grey)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(goal.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  goal.status,
                  style: AppTypography.caption.copyWith(color: _getStatusColor(goal.status), fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s16),
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary.withOpacity(0.2),
                child: Text(goal.employee.name.substring(0, 1), style: AppTypography.caption.copyWith(color: AppColors.primary)),
              ),
              const SizedBox(width: AppSpacing.s8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(goal.employee.name, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold)),
                    Text(goal.employee.department, style: AppTypography.caption.copyWith(color: Colors.grey)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Weightage', style: AppTypography.caption.copyWith(color: Colors.grey)),
                  Text('${goal.weightage}%', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold)),
                ],
              )
            ],
          ),
          const SizedBox(height: AppSpacing.s16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Progress', style: AppTypography.caption),
                        Text('${goal.progress.toInt()}%', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: goal.progress / 100,
                      backgroundColor: Colors.grey.shade200,
                      color: goal.progress >= 100 ? Colors.green : AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Target: ${goal.targetValue} ${goal.unit}', style: AppTypography.caption),
              Text('Due: ${goal.dueDate}', style: AppTypography.caption.copyWith(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}
