import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../data/performance_repository.dart';
import 'providers/employee_providers.dart';

class GoalFormScreen extends ConsumerStatefulWidget {
  const GoalFormScreen({super.key});

  @override
  ConsumerState<GoalFormScreen> createState() => _GoalFormScreenState();
}

class _GoalFormScreenState extends ConsumerState<GoalFormScreen> {
  final _titleController = TextEditingController();
  final _kpiController = TextEditingController();
  final _targetController = TextEditingController();
  final _currentController = TextEditingController();
  final _unitController = TextEditingController();
  final _weightageController = TextEditingController();
  final _dueDateController = TextEditingController();

  String _category = 'Strategic';
  String _priority = 'Medium';
  String _status = 'On Track';
  
  String? _selectedEmployeeId;
  String? _selectedCycleId;
  
  List<dynamic> _cycles = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(performanceRepositoryProvider).getActiveCycles().then((cycles) {
        if (mounted) {
          setState(() {
            _cycles = cycles;
            if (_cycles.isNotEmpty) {
              _selectedCycleId = _cycles.first.id;
            }
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _kpiController.dispose();
    _targetController.dispose();
    _currentController.dispose();
    _unitController.dispose();
    _weightageController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  Future<void> _saveGoal() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Goal Title is required')),
      );
      return;
    }
    
    setState(() => _isSubmitting = true);
    
    try {
      final payload = {
        'title': _titleController.text,
        'employeeId': _selectedEmployeeId,
        'cycleId': _selectedCycleId,
        'category': _category,
        'priority': _priority,
        'status': _status,
        'kpi': _kpiController.text,
        'targetValue': double.tryParse(_targetController.text) ?? 0,
        'currentValue': double.tryParse(_currentController.text) ?? 0,
        'unit': _unitController.text,
        'weightage': double.tryParse(_weightageController.text) ?? 0,
        'dueDate': _dueDateController.text,
      };
      
      await ref.read(performanceRepositoryProvider).createGoal(payload);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Goal Saved Successfully')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving goal: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final employeesAsync = ref.watch(employeeListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Create New Goal', style: AppTypography.title.copyWith(fontWeight: FontWeight.w700)),
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        elevation: 0,
        actions: [
          if (_isSubmitting)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))),
            )
          else
            TextButton.icon(
              onPressed: _saveGoal,
              icon: const Icon(LucideIcons.save, size: 16),
              label: const Text('Save'),
              style: TextButton.styleFrom(
                foregroundColor: isDark ? AppColors.primaryDark : AppColors.primaryLight,
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.s16),
              decoration: BoxDecoration(
                color: isDark ? Colors.indigo.withValues(alpha: 0.1) : Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.target, color: Colors.indigo.shade400, size: 24),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Goal Details', style: AppTypography.subtitle.copyWith(fontWeight: FontWeight.bold)),
                        Text('Define the objective and metrics', style: AppTypography.caption.copyWith(color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s24),
            
            Text('Goal Title *', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: AppSpacing.s8),
            AppTextField(
              controller: _titleController,
              placeholder: 'Enter goal title',
            ),
            const SizedBox(height: AppSpacing.s16),
            
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Employee', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: AppSpacing.s8),
                      employeesAsync.when(
                        data: (employees) => Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _selectedEmployeeId,
                              hint: const Text('Select Employee'),
                              items: employees.map((e) => DropdownMenuItem(value: e.id, child: Text('${e.firstName} ${e.lastName}'))).toList(),
                              onChanged: (v) => setState(() => _selectedEmployeeId = v),
                            ),
                          ),
                        ),
                        loading: () => const CircularProgressIndicator(),
                        error: (e, st) => const Text('Error loading'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.s16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Appraisal Cycle', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: AppSpacing.s8),
                      Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedCycleId,
                            hint: const Text('Select Cycle'),
                            items: _cycles.map((c) => DropdownMenuItem<String>(value: c.id, child: Text(c.name))).toList(),
                            onChanged: (v) => setState(() => _selectedCycleId = v),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s16),
            
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Category', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: AppSpacing.s8),
                      _buildDropdown(
                        value: _category,
                        items: const ['Strategic', 'Departmental', 'Individual'],
                        onChanged: (val) => setState(() => _category = val!),
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.s16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Priority', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: AppSpacing.s8),
                      _buildDropdown(
                        value: _priority,
                        items: const ['High', 'Medium', 'Low'],
                        onChanged: (val) => setState(() => _priority = val!),
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s24),
            
            const Divider(),
            const SizedBox(height: AppSpacing.s16),
            Text('Measurement', style: AppTypography.subtitle.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.s16),
            
            Text('Key Performance Indicator (KPI)', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: AppSpacing.s8),
            AppTextField(
              controller: _kpiController,
              placeholder: 'e.g. Quarterly Revenue',
            ),
            const SizedBox(height: AppSpacing.s16),
            
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Target', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: AppSpacing.s8),
                      AppTextField(
                        controller: _targetController,
                        placeholder: '0',
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.s16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Current', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: AppSpacing.s8),
                      AppTextField(
                        controller: _currentController,
                        placeholder: '0',
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.s16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Unit', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: AppSpacing.s8),
                      AppTextField(
                        controller: _unitController,
                        placeholder: 'e.g. %',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s16),
            
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Weightage (%)', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: AppSpacing.s8),
                      AppTextField(
                        controller: _weightageController,
                        placeholder: '0',
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.s16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Due Date', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: AppSpacing.s8),
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            setState(() {
                              _dueDateController.text = "\${date.year}-\${date.month.toString().padLeft(2, '0')}-\${date.day.toString().padLeft(2, '0')}";
                            });
                          }
                        },
                        child: IgnorePointer(
                          child: AppTextField(
                            controller: _dueDateController,
                            placeholder: 'YYYY-MM-DD',
                            prefixIcon: const Icon(LucideIcons.calendar),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s16),
            
            Text('Status', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: AppSpacing.s8),
            _buildDropdown(
              value: _status,
              items: const ['On Track', 'At Risk', 'Behind', 'Completed'],
              onChanged: (val) => setState(() => _status = val!),
              isDark: isDark,
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: isDark ? Colors.grey[900] : Colors.white,
          onChanged: onChanged,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: AppTypography.body),
            );
          }).toList(),
        ),
      ),
    );
  }
}
