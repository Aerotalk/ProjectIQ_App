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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // In Flutter, since we have a tab bar view, doing a row with sidebar might be cramped on mobile.
    // Instead we'll use a top row of chips for report types.
    
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
                            value: 'H1 2024',
                            isDense: true,
                            underline: const SizedBox(),
                            icon: const Icon(LucideIcons.chevronDown, size: 16),
                            items: const [
                              DropdownMenuItem(value: 'H1 2024', child: Text('H1 2024 (Active)', style: TextStyle(fontSize: 13))),
                            ],
                            onChanged: (v) {},
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s12),
                    AppButton.outlined(
                      text: 'PDF',
                      icon: LucideIcons.fileText,
                      onPressed: () {},
                      height: 36,
                    ),
                    const SizedBox(width: AppSpacing.s8),
                    AppButton.outlined(
                      text: 'Excel',
                      icon: LucideIcons.download,
                      onPressed: () {},
                      height: 36,
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
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.barChart2, size: 48, color: Colors.grey.withValues(alpha: 0.3)),
                      const SizedBox(height: 16),
                      Text('Mock visualization for \${_activeReport.replaceAll('-', ' ')} report.'),
                      const SizedBox(height: 8),
                      Text(
                        'In a full implementation, this area would render specific\ncharts or data grids for the selected report type.',
                        textAlign: TextAlign.center,
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                ),
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
