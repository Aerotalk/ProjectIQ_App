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
  final _titleController = TextEditingController();
  String _selectedTemplate = 'Standard';
  String _selectedCurrency = 'USD';

  final List<String> _templates = ['Standard', 'Travel', 'Meals'];
  final List<String> _currencies = ['USD', 'INR', 'EUR'];

    _titleController.dispose();
    super.dispose();
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

                  Text('Template *', style: AppTypography.label),
                  const SizedBox(height: AppSpacing.s8),
                  DropdownButtonFormField<String>(
                    value: _selectedTemplate,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    items: _templates
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedTemplate = v!),
                  ),
                  const SizedBox(height: AppSpacing.s16),

                  AppTextField(
                    label: 'Title / Purpose *',
                    placeholder: 'e.g., April Client Visit',
                    controller: _titleController,
                  ),
                  const SizedBox(height: AppSpacing.s16),

                  Text('Currency *', style: AppTypography.label),
                  const SizedBox(height: AppSpacing.s8),
                  DropdownButtonFormField<String>(
                    value: _selectedCurrency,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    items: _currencies
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedCurrency = v!),
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
