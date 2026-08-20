import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/theme/app_spacing.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../../shared/widgets/buttons/app_button.dart';
import '../../../../../shared/widgets/cards/app_card.dart';
import '../../data/repositories/payroll_repository.dart';

class ReimbursementFormScreen extends ConsumerStatefulWidget {
  const ReimbursementFormScreen({super.key});

  @override
  ConsumerState<ReimbursementFormScreen> createState() =>
      _ReimbursementFormScreenState();
}

class _ReimbursementFormScreenState
    extends ConsumerState<ReimbursementFormScreen> {
  final _amountController = TextEditingController();
  final _billNoController = TextEditingController();
  final _remarksController = TextEditingController();

  String _selectedType = 'Travel';
  DateTime? _billDate;
  DateTime? _claimPeriod;
  String? _attachmentName;
  bool _isLoading = false;

  final List<String> _types = [
    'Travel',
    'Medical',
    'Office Supplies',
    'Client Meeting',
    'Other',
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _billNoController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _pickDate(bool isBillDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() {
        if (isBillDate) {
          _billDate = picked;
        } else {
          _claimPeriod = picked;
        }
      });
    }
  }

  void _pickAttachment() async {
    final result = await FilePicker.platform.pickFiles(
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

    if (result != null && mounted) {
      setState(() {
        _attachmentName = result.files.single.name;
      });
    }
  }

  Future<void> _submit() async {
    if (_amountController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final payload = {
        'expenseType': _selectedType,
        'claimedAmount': double.tryParse(_amountController.text) ?? 0,
        'billDate': _billDate?.toIso8601String(),
        'claimPeriod': _claimPeriod?.toIso8601String(),
        'billNumber': _billNoController.text,
        'remarks': _remarksController.text,
        'attachment': _attachmentName,
      };

      await ref.read(payrollRepositoryProvider).createReimbursement(payload);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reimbursement Claim Submitted Successfully!'),
        ),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Reimbursement Claim')),
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
                    'Claim Details',
                    style: AppTypography.subtitle.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s16),

                  Text('Reimbursement Type *', style: AppTypography.label),
                  const SizedBox(height: AppSpacing.s8),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedType,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    items: _types
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedType = v!),
                  ),
                  const SizedBox(height: AppSpacing.s16),

                  AppTextField(
                    label: 'Claimed Amount *',
                    placeholder: 'e.g. 5000',
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: AppSpacing.s16),

                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _pickDate(false),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Claim Period *',
                              border: OutlineInputBorder(),
                            ),
                            child: Text(
                              _claimPeriod?.toString().split(' ')[0] ??
                                  'Select Date',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s16),
                      Expanded(
                        child: InkWell(
                          onTap: () => _pickDate(true),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Bill Date *',
                              border: OutlineInputBorder(),
                            ),
                            child: Text(
                              _billDate?.toString().split(' ')[0] ??
                                  'Select Date',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s16),

                  AppTextField(
                    label: 'Bill Number',
                    placeholder: 'Enter bill/invoice number',
                    controller: _billNoController,
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
                    'Supporting Documents',
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
                              _attachmentName ?? 'Tap to upload receipt (PDF, JPG, PNG, Excel, Word)',
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

                  const SizedBox(height: AppSpacing.s16),
                  AppTextField(
                    label: 'Remarks',
                    placeholder: 'Any additional details...',
                    controller: _remarksController,
                    maxLines: 3,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.s32),

            AppButton(
              text: 'Submit Claim',
              onPressed: _isLoading ? null : _submit,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 80), // Padding for Floating Nav Pill
          ],
        ),
      ),
    );
  }
}
