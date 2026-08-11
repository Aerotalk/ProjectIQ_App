import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/inputs/app_select.dart';
import '../providers/payroll_providers.dart';
import '../../data/repositories/payroll_repository.dart';

class PayrollProcessingScreen extends ConsumerStatefulWidget {
  const PayrollProcessingScreen({super.key});

  @override
  ConsumerState<PayrollProcessingScreen> createState() =>
      _PayrollProcessingScreenState();
}

class _PayrollProcessingScreenState extends ConsumerState<PayrollProcessingScreen> {
  int _currentStep = 0;
  bool _isProcessing = false;
  
  // Batch Setup State
  String? _selectedMonth;
  String? _selectedYear;
  
  // Eligibility State
  bool _isCheckingEligibility = false;
  bool _eligibilityChecked = false;
  List<dynamic> _missingDataEmployees = [];

  final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  final List<String> _years = ['2025', '2026', '2027'];

  String get _batchMonth => '${_selectedMonth ?? ''} ${_selectedYear ?? ''}'.trim();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = _months[now.month - 1];
    _selectedYear = now.year.toString();
  }

  void _checkEligibility() async {
    if (_selectedMonth == null || _selectedYear == null) return;
    
    setState(() {
      _isCheckingEligibility = true;
      _eligibilityChecked = false;
      _missingDataEmployees = [];
    });
    
    try {
      final repo = ref.read(payrollRepositoryProvider);
      final missing = await repo.getPayrollEligibilityCheck(_batchMonth);
      
      setState(() {
        _missingDataEmployees = missing;
        _eligibilityChecked = true;
      });
      
      if (missing.isEmpty) {
        setState(() => _currentStep = 2);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error checking eligibility: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCheckingEligibility = false);
      }
    }
  }

  void _processPayroll() async {
    setState(() => _isProcessing = true);
    try {
      final repo = ref.read(payrollRepositoryProvider);
      await repo.runPayroll({
        'batchMonth': _batchMonth,
      });
      
      ref.invalidate(payrollRunsProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payroll batch initialized! Processing in background.'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to run payroll: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Run Payroll Batch',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep == 0) {
            setState(() => _currentStep = 1);
            _checkEligibility();
          } else if (_currentStep == 1) {
            if (_eligibilityChecked && _missingDataEmployees.isEmpty) {
               setState(() => _currentStep = 2);
            }
          } else {
            _processPayroll();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep--);
          } else {
            context.pop();
          }
        },
        controlsBuilder: (context, details) {
          final isLastStep = _currentStep == 2;
          final isEligibilityStep = _currentStep == 1;
          
          bool canContinue = true;
          if (isEligibilityStep && (!_eligibilityChecked || _missingDataEmployees.isNotEmpty)) {
            canContinue = false;
          }
          
          return Padding(
            padding: const EdgeInsets.only(top: AppSpacing.s16),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: (_isProcessing || _isCheckingEligibility || !canContinue) ? null : details.onStepContinue,
                    child: (_isProcessing || _isCheckingEligibility)
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(isLastStep ? 'Run Payroll' : 'Continue'),
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: (_isProcessing || _isCheckingEligibility) ? null : details.onStepCancel,
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('Batch Setup'),
            content: Column(
              children: [
                AppSelect<String>(
                  value: _selectedMonth,
                  label: 'Payroll Month',
                  placeholder: 'Select Month',
                  items: _months.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                  onChanged: (v) => setState(() => _selectedMonth = v),
                ),
                const SizedBox(height: 16),
                AppSelect<String>(
                  value: _selectedYear,
                  label: 'Payroll Year',
                  placeholder: 'Select Year',
                  items: _years.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
                  onChanged: (v) => setState(() => _selectedYear = v),
                ),
              ],
            ),
            isActive: _currentStep >= 0,
          ),
          Step(
            title: const Text('Eligibility Pre-Check'),
            content: _buildEligibilityContent(),
            isActive: _currentStep >= 1,
          ),
          Step(
            title: const Text('Confirm Run'),
            content: Container(
               padding: const EdgeInsets.all(AppSpacing.s16),
               decoration: BoxDecoration(
                 color: Colors.green.shade50,
                 border: Border.all(color: Colors.green.shade200),
                 borderRadius: BorderRadius.circular(8),
               ),
               child: const Row(
                 children: [
                   Icon(LucideIcons.checkCircle, color: Colors.green),
                   SizedBox(width: 12),
                   Expanded(
                     child: Text('All employees are eligible. You can now execute the payroll run.'),
                   ),
                 ],
               ),
             ),
            isActive: _currentStep >= 2,
          ),
        ],
      ),
    );
  }

  Widget _buildEligibilityContent() {
    if (_isCheckingEligibility) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (!_eligibilityChecked) {
      return const Text('Ready to check eligibility.');
    }
    
    if (_missingDataEmployees.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          border: Border.all(color: Colors.green.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          children: [
            Icon(LucideIcons.checkCircle, color: Colors.green),
            SizedBox(width: 12),
            Expanded(child: Text('All employees have completed Bank, Statutory, and Salary configuration!')),
          ],
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.s16),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            border: Border.all(color: Colors.red.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(LucideIcons.alertTriangle, color: Colors.red.shade700),
              const SizedBox(width: 12),
              Expanded(child: Text('Payroll Engine Blocked. ${_missingDataEmployees.length} employees have incomplete configurations.', style: TextStyle(color: Colors.red.shade900))),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text('Employees requiring attention:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ..._missingDataEmployees.map((emp) {
          final missingSteps = List<String>.from(emp['missingSteps'] ?? []);
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${emp['firstName']} ${emp['lastName']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Missing: ${missingSteps.join(', ')}', style: const TextStyle(color: Colors.red, fontSize: 13)),
              ],
            ),
          );
        }),
      ],
    );
  }
}
