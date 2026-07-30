import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/buttons/app_button.dart';
import '../../../../shared/widgets/cards/app_card.dart';

class ExpenseClaimFormScreen extends ConsumerStatefulWidget {
  const ExpenseClaimFormScreen({super.key});

  @override
  ConsumerState<ExpenseClaimFormScreen> createState() =>
      _ExpenseClaimFormScreenState();
}

class _ExpenseClaimFormScreenState
    extends ConsumerState<ExpenseClaimFormScreen> {
  final _amountController = TextEditingController();
  final _gstAmountController = TextEditingController();
  final _descController = TextEditingController();

  String _selectedCategory = 'Travel';
  DateTime? _expenseDate;
  String? _attachmentName;

  bool _isGstApplicable = false;
  bool _isInputCreditClaimable = false;

  final List<String> _categories = [
    'Travel',
    'Meals',
    'Office Supplies',
    'Marketing',
    'Software',
    'Hardware',
    'Other',
  ];

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _expenseDate = picked;
      });
    }
  }

  void _pickAttachment() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'jpg',
        'jpeg',
        'png',
        'pdf',
        'xlsx',
        'xls',
        'doc',
        'docx',
      ],
    );

    if (result != null) {
      setState(() {
        _attachmentName = result.files.single.name;
      });
    }
  }

  void _submit() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Expense Logged Successfully!')),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
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
                    'Expense Details',
                    style: AppTypography.subtitle.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s16),

                  Text('Category *', style: AppTypography.label),
                  const SizedBox(height: AppSpacing.s8),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    items: _categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedCategory = v!),
                  ),
                  const SizedBox(height: AppSpacing.s16),

                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: _pickDate,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Expense Date *',
                              border: OutlineInputBorder(),
                            ),
                            child: Text(
                              _expenseDate?.toString().split(' ')[0] ??
                                  'Select Date',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s16),
                      Expanded(
                        child: AppTextField(
                          label: 'Amount (Total) *',
                          placeholder: '0.00',
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s16),

                  AppTextField(
                    label: 'Description',
                    placeholder: 'What was this expense for?',
                    controller: _descController,
                    maxLines: 2,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.s16),

            AppCard(
              padding: const EdgeInsets.all(AppSpacing.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tax & Compliance',
                    style: AppTypography.subtitle.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s16),

                  SwitchListTile(
                    title: const Text('GST Applicable?'),
                    value: _isGstApplicable,
                    onChanged: (v) => setState(() => _isGstApplicable = v),
                    contentPadding: EdgeInsets.zero,
                  ),

                  if (_isGstApplicable) ...[
                    const SizedBox(height: AppSpacing.s8),
                    AppTextField(
                      label: 'GST Amount',
                      placeholder: '0.00',
                      controller: _gstAmountController,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    SwitchListTile(
                      title: const Text('Input Credit Claimable?'),
                      value: _isInputCreditClaimable,
                      onChanged: (v) =>
                          setState(() => _isInputCreditClaimable = v),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.s16),

            AppCard(
              padding: const EdgeInsets.all(AppSpacing.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Receipt Attachment',
                    style: AppTypography.subtitle.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s16),

                  InkWell(
                    onTap: _pickAttachment,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.s24),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.primaryLight.withValues(alpha: 0.3),
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: AppColors.primaryLight.withValues(alpha: 0.05),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              LucideIcons.uploadCloud,
                              size: 32,
                              color: AppColors.primaryLight,
                            ),
                            const SizedBox(height: AppSpacing.s8),
                            Text(
                              _attachmentName ?? 'Tap to upload receipt',
                              style: AppTypography.body.copyWith(
                                color: _attachmentName != null
                                    ? AppColors.primaryLight
                                    : AppColors.mutedForegroundLight,
                                fontWeight: _attachmentName != null
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.s32),

            AppButton(text: 'Save Expense', onPressed: _submit),
            const SizedBox(height: 80), // Padding for Floating Nav Pill
          ],
        ),
      ),
    );
  }
}
