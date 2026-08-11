import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_spacing.dart';

class PayrollProcessingScreen extends StatefulWidget {
  const PayrollProcessingScreen({super.key});

  @override
  State<PayrollProcessingScreen> createState() =>
      _PayrollProcessingScreenState();
}

class _PayrollProcessingScreenState extends State<PayrollProcessingScreen> {
  int _currentStep = 0;
  bool _isProcessing = false;

  void _processPayroll() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payroll processed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Process Payroll',
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
          if (_currentStep < 2) {
            setState(() => _currentStep++);
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
          return Padding(
            padding: const EdgeInsets.only(top: AppSpacing.s16),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: _isProcessing ? null : details.onStepContinue,
                    child: _isProcessing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(isLastStep ? 'Run Payroll' : 'Continue'),
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isProcessing ? null : details.onStepCancel,
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('Select Employee'),
            content: Container(
              padding: const EdgeInsets.all(AppSpacing.s16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Search employee...',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  Icon(LucideIcons.search, color: Colors.grey),
                ],
              ),
            ),
            isActive: _currentStep >= 0,
          ),
          Step(
            title: const Text('Validation'),
            content: Container(
              padding: const EdgeInsets.all(AppSpacing.s16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                border: Border.all(color: Colors.blue.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.info,
                    color: Colors.blue.shade700,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('Attendance records and inputs validated for this employee.'),
                  ),
                ],
              ),
            ),
            isActive: _currentStep >= 1,
          ),
          Step(
            title: const Text('Confirm Run'),
            content: const Text(
              'Processing payroll action for the selected employee.',
            ),
            isActive: _currentStep >= 2,
          ),
        ],
      ),
    );
  }
}
