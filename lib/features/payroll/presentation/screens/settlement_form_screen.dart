import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/buttons/app_button.dart';
import '../../../../../shared/widgets/cards/app_card.dart';

class SettlementFormScreen extends ConsumerStatefulWidget {
  const SettlementFormScreen({super.key});

  @override
  ConsumerState<SettlementFormScreen> createState() =>
      _SettlementFormScreenState();
}

class _SettlementFormScreenState extends ConsumerState<SettlementFormScreen> {
  String _employee = 'Alice Smith (Exiting)';
  DateTime? _settlementDate;
  DateTime? _lastWorkingDate;

  final List<String> _employees = [
    'Alice Smith (Exiting)',
    'Bob Johnson (Resigned)',
  ];

  void _pickDate(bool isLastWorking) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isLastWorking) {
          _lastWorkingDate = picked;
        } else {
          _settlementDate = picked;
        }
      });
    }
  }

  void _submit() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Final Settlement Processed Successfully!')),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Final Settlement')),
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
                    'Employee Details',
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
                        child: InkWell(
                          onTap: () => _pickDate(true),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Last Working Date *',
                              border: OutlineInputBorder(),
                            ),
                            child: Text(
                              _lastWorkingDate?.toString().split(' ')[0] ??
                                  'Select Date',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s16),
                      Expanded(
                        child: InkWell(
                          onTap: () => _pickDate(false),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Settlement Date *',
                              border: OutlineInputBorder(),
                            ),
                            child: Text(
                              _settlementDate?.toString().split(' ')[0] ??
                                  'Select Date',
                            ),
                          ),
                        ),
                      ),
                    ],
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
                    'Auto-Calculated Settlement Items',
                    style: AppTypography.subtitle.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s16),

                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDark ? Colors.white12 : Colors.black12,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        _buildTableRow(
                          'Basic Pay (Pro-rated)',
                          '₹ 15,000.00',
                          true,
                        ),
                        _buildTableRow('Leave Encashment', '₹ 12,500.00', true),
                        _buildTableRow(
                          'Notice Period Recovery',
                          '- ₹ 5,000.00',
                          false,
                        ),
                        _buildTableRow(
                          'Pending Reimbursements',
                          '₹ 2,000.00',
                          true,
                        ),
                        const Divider(height: 1),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.s16),
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.black.withValues(alpha: 0.02),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Net Settlement Amount',
                                style: AppTypography.subtitle.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '₹ 24,500.00',
                                style: AppTypography.title.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.s32),

            AppButton(text: 'Submit Settlement', onPressed: _submit),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildTableRow(String label, String amount, bool isPositive) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.body),
          Text(
            amount,
            style: AppTypography.body.copyWith(
              color: isPositive ? Colors.green : Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
