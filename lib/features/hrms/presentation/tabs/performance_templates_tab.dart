import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/buttons/app_button.dart';

class PerformanceTemplatesTab extends StatefulWidget {
  const PerformanceTemplatesTab({super.key});

  @override
  State<PerformanceTemplatesTab> createState() => _PerformanceTemplatesTabState();
}

class _PerformanceTemplatesTabState extends State<PerformanceTemplatesTab> {
  int _activeTabIndex = 1; // Default to Competencies Library
  final List<String> _tabs = ['Review Templates', 'Competencies Library', 'Rating Scales'];

  final List<Map<String, dynamic>> _mockCompetencies = [
    {'name': 'Communication', 'category': 'Core', 'weightage': 15, 'active': true},
    {'name': 'Leadership', 'category': 'Leadership', 'weightage': 20, 'active': true},
    {'name': 'Technical Skills', 'category': 'Technical', 'weightage': 25, 'active': true},
    {'name': 'Problem Solving', 'category': 'Core', 'weightage': 15, 'active': false},
  ];

  final List<Map<String, dynamic>> _mockTemplates = [
    {'name': 'Annual Performance Review 2024', 'type': 'Annual', 'status': 'Active'},
    {'name': 'Q3 Check-in', 'type': 'Quarterly', 'status': 'Draft'},
  ];

  final List<Map<String, dynamic>> _mockScales = [
    {'name': 'Standard 5-Point', 'levels': 5, 'active': true},
    {'name': '3-Point Simple', 'levels': 3, 'active': true},
  ];

  void _deleteItem(int index) {
    setState(() {
      if (_activeTabIndex == 0) _mockTemplates.removeAt(index);
      else if (_activeTabIndex == 1) _mockCompetencies.removeAt(index);
      else _mockScales.removeAt(index);
    });
  }

  void _showAddDrawer(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: AppSpacing.s24,
            right: AppSpacing.s24,
            top: AppSpacing.s24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add New ${_tabs[_activeTabIndex]}', style: AppTypography.title),
              const SizedBox(height: AppSpacing.s24),
              AppTextField(label: 'Name', placeholder: 'Enter name'),
              const SizedBox(height: AppSpacing.s16),
              if (_activeTabIndex == 1) ...[
                AppTextField(label: 'Category', placeholder: 'e.g. Core, Technical'),
                const SizedBox(height: AppSpacing.s16),
                AppTextField(label: 'Weightage (%)', placeholder: '0', keyboardType: TextInputType.number),
              ],
              const SizedBox(height: AppSpacing.s32),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  text: 'Save',
                  onPressed: () {
                    setState(() {
                      if (_activeTabIndex == 0) {
                        _mockTemplates.add({'name': 'New Template', 'type': 'Custom', 'status': 'Draft'});
                      } else if (_activeTabIndex == 1) {
                        _mockCompetencies.add({'name': 'New Competency', 'category': 'Custom', 'weightage': 10, 'active': true});
                      } else {
                        _mockScales.add({'name': 'New Scale', 'levels': 4, 'active': true});
                      }
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.s24),
            ],
          ),
        );
      },
    );
  }

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
                onPressed: () => _showAddDrawer(context, isDark),
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
          child: _buildList(isDark),
        ),
      ],
    );
  }

  Widget _buildList(bool isDark) {
    List data = _activeTabIndex == 0 ? _mockTemplates : (_activeTabIndex == 1 ? _mockCompetencies : _mockScales);
    
    if (data.isEmpty) {
      return Center(child: Text("No items found.", style: AppTypography.caption));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s8),
      itemCount: data.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s12),
      itemBuilder: (context, index) {
        final item = data[index];
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
                    Text(item['name'], style: AppTypography.subtitle),
                    const SizedBox(height: 4),
                    Text(
                      _activeTabIndex == 0 ? item['type'] : (_activeTabIndex == 1 ? item['category'] : '${item['levels']} Levels'),
                      style: AppTypography.caption.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              if (_activeTabIndex == 1)
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Weightage', style: AppTypography.caption.copyWith(color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text("${item['weightage']}%", style: AppTypography.body.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ((item['active'] ?? item['status'] == 'Active') ? Colors.green : Colors.orange).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  item['status'] ?? (item['active'] ? 'Active' : 'Inactive'),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: (item['active'] ?? item['status'] == 'Active') ? Colors.green : Colors.orange,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Row(
                children: [
                  IconButton(
                    icon: Icon(LucideIcons.edit2, size: 18, color: Colors.grey[600]),
                    onPressed: () => _showAddDrawer(context, isDark),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: Icon(LucideIcons.trash2, size: 18, color: Colors.red[400]),
                    onPressed: () => _deleteItem(index),
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
