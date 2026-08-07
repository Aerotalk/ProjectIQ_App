import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/buttons/app_button.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../data/performance_repository.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

class PerformanceReportsTab extends ConsumerStatefulWidget {
  const PerformanceReportsTab({super.key});

  @override
  ConsumerState<PerformanceReportsTab> createState() => _PerformanceReportsTabState();
}

class _PerformanceReportsTabState extends ConsumerState<PerformanceReportsTab> {
  String _activeReport = 'department';
  String _selectedCycle = 'H1 2024';

  final List<Map<String, dynamic>> _reports = [
    {'id': 'department', 'title': 'Department Ratings', 'icon': LucideIcons.barChart2},
    {'id': 'goals', 'title': 'Goal Achievement', 'icon': LucideIcons.pieChart},
    {'id': 'promotions', 'title': 'Promotion Recs.', 'icon': LucideIcons.trendingUp},
  ];

  List<Map<String, dynamic>> _departmentData = [];
  List<Map<String, dynamic>> _goalData = [];
  List<Map<String, dynamic>> _promotionData = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(performanceRepositoryProvider);
      final goals = await repo.getGoals();

      // Department Map
      final Map<String, Map<String, dynamic>> deptMap = {};
      
      int totalCompleted = 0;
      int totalNeedsImp = 0;

      for (var g in goals) {
        final dept = g.employee.department.isNotEmpty ? g.employee.department : 'Unknown';
        final empId = g.employee.id;

        if (!deptMap.containsKey(dept)) {
          deptMap[dept] = {
            'totalEmployeesSet': <String>{},
            'completed': 0,
            'needsImprovement': 0,
            'totalRating': 0.0,
          };
        }

        final data = deptMap[dept]!;
        (data['totalEmployeesSet'] as Set<String>).add(empId);
        
        if (g.status == 'Completed' || g.progress >= 100) {
          data['completed'] = (data['completed'] as int) + 1;
          data['totalRating'] = (data['totalRating'] as double) + 5.0;
          totalCompleted++;
        } else if (g.progress < 50 && g.status != 'Draft') {
          data['needsImprovement'] = (data['needsImprovement'] as int) + 1;
          data['totalRating'] = (data['totalRating'] as double) + 2.0;
          totalNeedsImp++;
        } else {
          data['totalRating'] = (data['totalRating'] as double) + 3.5;
        }
      }

      final newDeptData = deptMap.entries.map((e) {
        final data = e.value;
        final count = (data['totalEmployeesSet'] as Set).length;
        final completed = data['completed'] as int;
        final needsImp = data['needsImprovement'] as int;
        double avg = (data['totalRating'] as double) / (count + completed + needsImp > 0 ? (count + completed + needsImp) : 1);
        
        return {
          'department': e.key,
          'avgRating': double.parse(avg.toStringAsFixed(1)),
          'topPerformers': completed,
          'needsImprovement': needsImp,
          'totalEmployees': count,
        };
      }).toList();

      final newGoalData = [
        {
          'title': 'Overall Goals',
          'completion': goals.isEmpty ? 0 : ((totalCompleted / goals.length) * 100).toInt(),
          'onTrack': goals.length - totalCompleted - totalNeedsImp,
          'atRisk': totalNeedsImp,
          'completed': totalCompleted,
        }
      ];

      setState(() {
        _departmentData = newDeptData;
        _goalData = newGoalData;
        _promotionData = []; // waiting on actual promotion APIs
        _isLoading = false;
      });

    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleExport(String format) async {
    final hasData = _activeReport == 'department' ? _departmentData.isNotEmpty : (_activeReport == 'goals' ? _goalData.isNotEmpty : _promotionData.isNotEmpty);
    if (!hasData) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No data available to export for ${_activeReport.replaceAll('-', ' ')}.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (format == 'PDF') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF export not supported on mobile yet. Try Excel.'), backgroundColor: Colors.orange),
      );
      return;
    }

    try {
      List<List<dynamic>> rows = [];
      if (_activeReport == 'department') {
        rows.add(['Department', 'Avg Rating', 'Top Performers', 'Needs Improvement', 'Total Employees']);
        for (var d in _departmentData) {
          rows.add([d['department'], d['avgRating'], d['topPerformers'], d['needsImprovement'], d['totalEmployees']]);
        }
      } else if (_activeReport == 'goals') {
        rows.add(['Title', 'Completion %', 'On Track', 'At Risk', 'Completed']);
        for (var g in _goalData) {
          rows.add([g['title'], g['completion'], g['onTrack'], g['atRisk'], g['completed']]);
        }
      } else {
        rows.add(['Data']);
        rows.add(['No promotion data']);
      }

      String csvData = Csv().encode(rows);
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/performance_report_$_activeReport.csv');
      await file.writeAsString(csvData);
      
      if (mounted) {
        await Share.shareXFiles([XFile(file.path)], text: 'Performance Report - $_activeReport');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e'), backgroundColor: Colors.red),
      );
    }
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
                        onPressed: (_activeReport == 'department' && _departmentData.isEmpty) || 
                                   (_activeReport == 'goals' && _goalData.isEmpty) || 
                                   (_activeReport == 'promotions') ? null : () => _handleExport('PDF'),
                        variant: AppButtonVariant.outline,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s8),
                    SizedBox(
                      height: 36,
                      child: AppButton(
                        text: 'Excel',
                        icon: LucideIcons.download,
                        onPressed: (_activeReport == 'department' && _departmentData.isEmpty) || 
                                   (_activeReport == 'goals' && _goalData.isEmpty) || 
                                   (_activeReport == 'promotions') ? null : () => _handleExport('Excel'),
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
          child: _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : _activeReport == 'department'
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
