import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../../shared/widgets/buttons/app_button.dart';
import '../../../../../shared/widgets/cards/app_card.dart';
import '../../data/repositories/payroll_repository.dart';

class SalaryInputFormScreen extends ConsumerStatefulWidget {
  const SalaryInputFormScreen({super.key});

  @override
  ConsumerState<SalaryInputFormScreen> createState() =>
      _SalaryInputFormScreenState();
}

class _SalaryInputFormScreenState extends ConsumerState<SalaryInputFormScreen> {
  String _employee = 'John Doe (EMP001)';
  String _period = 'July 2026';
  String _component = 'Bonus';
  String _type = 'Addition';
  bool _recurring = false;
  DateTime? _recurringUntil;
  bool _isLoading = false;

  final _amountController = TextEditingController();
  final _reasonController = TextEditingController();

  final List<String> _employees = ['John Doe (EMP001)', 'Jane Smith (EMP002)'];
  final List<String> _periods = ['June 2026', 'July 2026', 'August 2026'];
  final List<String> _components = [
    'Bonus',
    'Commission',
    'Deduction',
    'Other',
  ];
  final List<String> _types = ['Addition', 'Override', 'Deduction'];

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_amountController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final payload = {
        'employee': _employee,
        'period': _period,
        'component': _component,
        'type': _type,
        'amount': double.tryParse(_amountController.text) ?? 0,
        'reason': _reasonController.text,
        'recurring': _recurring,
        'recurringUntil': _recurringUntil?.toIso8601String(),
      };
      
      await ref.read(payrollRepositoryProvider).createSalaryInput(payload);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Salary Input Added Successfully!')),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null && mounted) {
      setState(() => _recurringUntil = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Salary Input')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Input Details',
                    style: AppTypography.subtitle.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s16),

                  Text('Employee *', style: AppTypography.label),
                  const SizedBox(height: AppSpacing.s8),
                  DropdownButtonFormField<String>(
                    initialValue: _employee,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    items: _employees
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => _employee = v!),
                  ),
                  const SizedBox(height: AppSpacing.s16),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Payroll Period *',
                              style: AppTypography.label,
                            ),
                            const SizedBox(height: AppSpacing.s8),
                            DropdownButtonFormField<String>(
                              initialValue: _period,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                              ),
                              items: _periods
                                  .map(
                                    (p) => DropdownMenuItem(
                                      value: p,
                                      child: Text(p),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) => setState(() => _period = v!),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Pay Component *', style: AppTypography.label),
                            const SizedBox(height: AppSpacing.s8),
                            DropdownButtonFormField<String>(
                              initialValue: _component,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                              ),
                              items: _components
                                  .map(
                                    (c) => DropdownMenuItem(
                                      value: c,
                                      child: Text(c),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) => setState(() => _component = v!),
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
                        flex: 2,
                        child: AppTextField(
                          label: 'Amount *',
                          placeholder: '0.00',
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s16),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Input Type *', style: AppTypography.label),
                      const SizedBox(height: AppSpacing.s8),
                      Row(
                        children: _types
                            .map(
                              (t) => Expanded(
                                child: RadioListTile<String>(
                                  title: Text(
                                    t,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  value: t,
                                  // ignore: deprecated_member_use
                                  groupValue: _type,
                                  contentPadding: EdgeInsets.zero,
                                  // ignore: deprecated_member_use
                                  onChanged: (v) =>
                                      setState(() => _type = v!),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppSpacing.s16),

                  AppTextField(
                    label: 'Reason (Optional)',
                    placeholder: 'Reason for salary input',
                    controller: _reasonController,
                    maxLines: 2,
                  ),

                  const SizedBox(height: AppSpacing.s16),
                  const Divider(),
                  const SizedBox(height: AppSpacing.s16),

                  Row(
                    children: [
                      Checkbox(
                        value: _recurring,
                        onChanged: (v) =>
                            setState(() => _recurring = v ?? false),
                      ),
                      const Text('Recurring Input'),
                    ],
                  ),

                  if (_recurring) ...[
                    const SizedBox(height: AppSpacing.s16),
                    InkWell(
                      onTap: _pickDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Recurring Until',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _recurringUntil?.toString().split(' ')[0] ??
                              'Select Date',
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.s24),
            AppButton(
              text: 'Save Input',
              onPressed: _isLoading ? null : _submit,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
