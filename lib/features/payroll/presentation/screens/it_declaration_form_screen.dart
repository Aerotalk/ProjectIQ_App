import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../../shared/widgets/buttons/app_button.dart';
import '../../../../../shared/widgets/cards/app_card.dart';
import '../../data/repositories/payroll_repository.dart';

class ITDeclarationFormScreen extends ConsumerStatefulWidget {
  const ITDeclarationFormScreen({super.key});

  @override
  ConsumerState<ITDeclarationFormScreen> createState() =>
      _ITDeclarationFormScreenState();
}

class _DeclarationItem {
  String section = '80C';
  String amount = '';
  String remarks = '';
}

class _ITDeclarationFormScreenState
    extends ConsumerState<ITDeclarationFormScreen> {
  String _selectedYear = '2026-2027';
  String _selectedRegime = 'New Tax Regime';

  final List<String> _years = ['2025-2026', '2026-2027', '2027-2028'];
  final List<String> _regimes = ['Old Tax Regime', 'New Tax Regime'];
  final List<String> _sections = [
    '80C',
    '80D',
    '80CCD',
    'House Rent',
    'Home Loan Interest',
  ];

  final List<_DeclarationItem> _items = [_DeclarationItem()];

  void _addItem() {
    setState(() {
      _items.add(_DeclarationItem());
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  bool _isLoading = false;

  Future<void> _submit() async {
    setState(() => _isLoading = true);

    try {
      final payload = {
        'financialYear': _selectedYear,
        'taxRegime': _selectedRegime,
        'declarations': _items.map((i) => {
          'section': i.section,
          'amount': double.tryParse(i.amount) ?? 0,
          'remarks': i.remarks,
        }).toList(),
      };

      await ref.read(payrollRepositoryProvider).createITDeclaration(payload);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('IT Declaration Updated Successfully!')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update IT Declaration')),
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
                    'General Setup',
                    style: AppTypography.subtitle.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s16),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Financial Year *',
                              style: AppTypography.label,
                            ),
                            const SizedBox(height: AppSpacing.s8),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedYear,
                              isExpanded: true,
                              isDense: true,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 10,
                                ),
                              ),
                              items: _years
                                  .map(
                                    (y) => DropdownMenuItem(
                                      value: y,
                                      child: Text(
                                        y,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _selectedYear = v!),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tax Regime *', style: AppTypography.label),
                            const SizedBox(height: AppSpacing.s8),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedRegime,
                              isExpanded: true,
                              isDense: true,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 10,
                                ),
                              ),
                              items: _regimes
                                  .map(
                                    (r) => DropdownMenuItem(
                                      value: r,
                                      child: Text(
                                        r,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _selectedRegime = v!),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.s16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Declaration Items',
                  style: AppTypography.subtitle.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton.icon(
                  onPressed: _addItem,
                  icon: const Icon(LucideIcons.plus, size: 16),
                  label: const Text('Add Item'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s8),

            ..._items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.s16),
                child: AppCard(
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Section *', style: AppTypography.label),
                                const SizedBox(height: AppSpacing.s8),
                                DropdownButtonFormField<String>(
                                  initialValue: item.section,
                                  isExpanded: true,
                                  isDense: true,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 10,
                                    ),
                                  ),
                                  items: _sections
                                      .map(
                                        (s) => DropdownMenuItem(
                                          value: s,
                                          child: Text(
                                            s,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) =>
                                      setState(() => item.section = v!),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s12),
                          Expanded(
                            flex: 2,
                            child: AppTextField(
                              label: 'Amount *',
                              placeholder: '0.00',
                              keyboardType: TextInputType.number,
                              onChanged: (v) => item.amount = v,
                            ),
                          ),
                          if (_items.length > 1) ...[
                            const SizedBox(width: AppSpacing.s8),
                            Padding(
                              padding: const EdgeInsets.only(top: 28),
                              child: IconButton(
                                icon: const Icon(
                                  LucideIcons.trash2,
                                  color: Colors.red,
                                ),
                                onPressed: () => _removeItem(index),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      AppTextField(
                        label: 'Remarks (Optional)',
                        placeholder: 'Additional details...',
                        onChanged: (v) => item.remarks = v,
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: AppSpacing.s24),
            AppButton(
              text: 'Save Declarations',
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
