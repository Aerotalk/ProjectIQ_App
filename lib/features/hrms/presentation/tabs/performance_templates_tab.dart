import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';

class PerformanceTemplatesTab extends StatefulWidget {
  const PerformanceTemplatesTab({super.key});

  @override
  State<PerformanceTemplatesTab> createState() => _PerformanceTemplatesTabState();
}

class _PerformanceTemplatesTabState extends State<PerformanceTemplatesTab> {
  int _activeTabIndex = 1; // Default to Competencies Library to match frontend
  final List<String> _tabs = ['Review Templates', 'Competencies Library', 'Rating Scales'];

  final List<Map<String, dynamic>> _mockCompetencies = [
    {'name': 'Communication', 'category': 'Core', 'weightage': 15, 'active': true},
    {'name': 'Leadership', 'category': 'Leadership', 'weightage': 20, 'active': true},
    {'name': 'Technical Skills', 'category': 'Technical', 'weightage': 25, 'active': true},
    {'name': 'Problem Solving', 'category': 'Core', 'weightage': 15, 'active': false},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Tabs
        Container(
          margin: const EdgeInsets.all(AppSpacing.s16),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
          child: Row(
            children: List.generate(_tabs.length, (index) {
              final isActive = _activeTabIndex == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _activeTabIndex = index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
                    decoration: BoxDecoration(
                      color: isActive ? (isDark ? AppColors.primaryDark : AppColors.primaryLight).withValues(alpha: 0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _tabs[index],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                        color: isActive 
                            ? (isDark ? AppColors.primaryDark : AppColors.primaryLight) 
                            : (isDark ? Colors.grey[400] : Colors.grey[600]),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

        // Action Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
          child: Row(
            children: [
              Expanded(
                child: AppTextField(
                  placeholder: 'Search...',
                  prefixIcon: Icon(LucideIcons.search, size: 20, color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForegroundLight),
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              ElevatedButton.icon(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(LucideIcons.plus, size: 20),
                label: const Text('Add New'),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.s16),

        // Content Area
        Expanded(
          child: _activeTabIndex == 1
              ? _buildCompetenciesList(isDark)
              : Center(
                  child: Text(
                    'Mock content for \${_tabs[_activeTabIndex]}.\nStructure mirrors Competencies list.',
                    textAlign: TextAlign.center,
                    style: AppTypography.caption.copyWith(color: Colors.grey),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildCompetenciesList(bool isDark) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s8),
      itemCount: _mockCompetencies.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s12),
      itemBuilder: (context, index) {
        final comp = _mockCompetencies[index];
        return Container(
          padding: const EdgeInsets.all(AppSpacing.s16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(comp['name'], style: AppTypography.subtitle),
                    const SizedBox(height: 4),
                    Text(comp['category'], style: AppTypography.caption.copyWith(color: Colors.grey)),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Weightage', style: AppTypography.caption.copyWith(color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text('\${comp['weightage']}%', style: AppTypography.body.copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (comp['active'] ? Colors.green : Colors.red).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  comp['active'] ? 'Active' : 'Inactive',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: comp['active'] ? Colors.green : Colors.red,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Row(
                children: [
                  IconButton(
                    icon: Icon(LucideIcons.edit2, size: 18, color: Colors.grey[600]),
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: Icon(LucideIcons.trash2, size: 18, color: Colors.red[400]),
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
