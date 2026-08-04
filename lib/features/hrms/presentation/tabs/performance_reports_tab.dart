import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/buttons/app_button.dart';
import '../../../../shared/widgets/cards/app_card.dart';

class PerformanceReportsTab extends StatefulWidget {
  const PerformanceReportsTab({super.key});

  @override
  State<PerformanceReportsTab> createState() => _PerformanceReportsTabState();
}

class _PerformanceReportsTabState extends State<PerformanceReportsTab> {
  String _activeReport = 'department';
  String _selectedCycle = 'H1 2024';

  final List<Map<String, dynamic>> _reports = [
    {'id': 'department', 'title': 'Department Ratings', 'icon': LucideIcons.barChart2},
    {'id': 'goals', 'title': 'Goal Achievement', 'icon': LucideIcons.pieChart},
    {'id': 'promotions', 'title': 'Promotion Recs.', 'icon': LucideIcons.trendingUp},
  ];

  final List<Map<String, dynamic>> _departmentData = [
    {'department': 'Engineering', 'avgRating': 4.2, 'topPerformers': 12, 'needsImprovement': 2, 'totalEmployees': 45},
    {'department': 'Sales', 'avgRating': 3.9, 'topPerformers': 8, 'needsImprovement': 5, 'totalEmployees': 32},
    {'department': 'Marketing', 'avgRating': 4.1, 'topPerformers': 5, 'needsImprovement': 1, 'totalEmployees': 18},
    {'department': 'HR', 'avgRating': 4.0, 'topPerformers': 2, 'needsImprovement': 0, 'totalEmployees': 8},
  ];

  final List<Map<String, dynamic>> _goalData = [
    {'title': 'Q1 OKRs', 'completion': 85, 'onTrack': 10, 'atRisk': 2, 'completed': 25},
    {'title': 'Annual KPIs', 'completion': 45, 'onTrack': 30, 'atRisk': 5, 'completed': 5},
  ];

  final List<Map<String, dynamic>> _promotionData = [
    {'employee': 'Alice Chen', 'department': 'Engineering', 'currentRole': 'SDE II', 'proposedRole': 'Senior SDE', 'rating': 4.8},
    {'employee': 'Bob Smith', 'department': 'Sales', 'currentRole': 'Account Exec', 'proposedRole': 'Senior AE', 'rating': 4.5},
  ];

  void _showExportSuccess(String format) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Report exported as $format successfully.'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
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
                        Text('Performance Reports', style: AppTypography.subtitle.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Analyze ratings, goals, and talent across the organization.', style: AppTypography.caption),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardDark : AppColors.cardLight,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                      ),
                      child: Row(
                        children: [
                          const Text('Cycle:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(width: 8),
                          DropdownButton<String>(
                            value: _selectedCycle,
                            isDense: true,
                            underline: const SizedBox(),
                            icon: const Icon(LucideIcons.chevronDown, size: 16),
                            items: const [
                              DropdownMenuItem(value: 'H1 2024', child: Text('H1 2024 (Active)', style: TextStyle(fontSize: 13))),
                              DropdownMenuItem(value: '2023 Annual', child: Text('2023 Annual', style: TextStyle(fontSize: 13))),
                            ],
                            onChanged: (v) {
                              if (v != null) setState(() => _selectedCycle = v);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s12),
                    SizedBox(
                      height: 36,
                      child: AppButton(
                        text: 'PDF',
                        icon: LucideIcons.fileText,
                        onPressed: () => _showExportSuccess('PDF'),
                        variant: AppButtonVariant.outline,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s8),
                    SizedBox(
                      height: 36,
                      child: AppButton(
                        text: 'Excel',
                        icon: LucideIcons.download,
                        onPressed: () => _showExportSuccess('Excel'),
                        variant: AppButtonVariant.outline,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s24),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _reports.map((report) {
                    final isActive = _activeReport == report['id'];
                    return Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.s8),
                      child: ChoiceChip(
                        label: Text(report['title']),
                        selected: isActive,
                        onSelected: (selected) {
                          if (selected) setState(() => _activeReport = report['id']);
                        },
                        avatar: Icon(
                          report['icon'],
                          size: 16,
                          color: isActive ? (isDark ? AppColors.primaryDark : AppColors.primaryLight) : Colors.grey,
                        ),
                        backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
                        selectedColor: (isDark ? AppColors.primaryDark : AppColors.primaryLight).withValues(alpha: 0.1),
                        labelStyle: TextStyle(
                          color: isActive ? (isDark ? AppColors.primaryDark : AppColors.primaryLight) : (isDark ? Colors.white : Colors.black87),
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: isActive ? (isDark ? AppColors.primaryDark : AppColors.primaryLight) : Colors.transparent),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: _activeReport == 'department'
              ? _buildDepartmentReport(isDark)
              : _activeReport == 'goals'
                  ? _buildGoalReport(isDark)
                  : _buildPromotionReport(isDark),
        ),
      ],
    );
  }

  Widget _buildDepartmentReport(bool isDark) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.s16),
      itemCount: _departmentData.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s12),
      itemBuilder: (context, index) {
        final dept = _departmentData[index];
        return AppCard(
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(dept['department'], style: AppTypography.subtitle),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (isDark ? AppColors.primaryDark : AppColors.primaryLight).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(LucideIcons.star, size: 12, color: isDark ? AppColors.primaryDark : AppColors.primaryLight),
                        const SizedBox(width: 4),
                        Text(
                          dept['avgRating'].toString(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStat('Headcount', dept['totalEmployees'].toString()),
                  _buildStat('Top Performers', dept['topPerformers'].toString(), color: Colors.green),
                  _buildStat('Needs Improvement', dept['needsImprovement'].toString(), color: Colors.orange),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGoalReport(bool isDark) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.s16),
      itemCount: _goalData.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s12),
      itemBuilder: (context, index) {
        final goal = _goalData[index];
        return AppCard(
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(goal['title'], style: AppTypography.subtitle),
                  Text('${goal['completion']}%', style: AppTypography.title.copyWith(color: isDark ? AppColors.primaryDark : AppColors.primaryLight)),
                ],
              ),
              const SizedBox(height: AppSpacing.s8),
              LinearProgressIndicator(
                value: goal['completion'] / 100,
                backgroundColor: isDark ? AppColors.borderDark : AppColors.borderLight,
                color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                borderRadius: BorderRadius.circular(4),
                minHeight: 8,
              ),
              const SizedBox(height: AppSpacing.s16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStat('Completed', goal['completed'].toString(), color: Colors.green),
                  _buildStat('On Track', goal['onTrack'].toString(), color: Colors.blue),
                  _buildStat('At Risk', goal['atRisk'].toString(), color: Colors.red),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPromotionReport(bool isDark) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.s16),
      itemCount: _promotionData.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s12),
      itemBuilder: (context, index) {
        final promo = _promotionData[index];
        return AppCard(
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(promo['employee'], style: AppTypography.subtitle),
                    const SizedBox(height: 4),
                    Text(promo['department'], style: AppTypography.caption.copyWith(color: Colors.grey)),
                    const SizedBox(height: AppSpacing.s12),
                    Row(
                      children: [
                        Text(promo['currentRole'], style: AppTypography.caption),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Icon(LucideIcons.arrowRight, size: 14, color: Colors.grey),
                        ),
                        Text(promo['proposedRole'], style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, color: isDark ? AppColors.primaryDark : AppColors.primaryLight)),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.star, size: 12, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      promo['rating'].toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStat(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.caption.copyWith(color: Colors.grey, fontSize: 11)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
