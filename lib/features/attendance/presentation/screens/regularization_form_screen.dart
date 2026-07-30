import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../data/models/regularization_model.dart';
import '../providers/regularization_providers.dart';
import 'package:uuid/uuid.dart';

class RegularizationFormScreen extends ConsumerStatefulWidget {
  const RegularizationFormScreen({super.key});

  @override
  ConsumerState<RegularizationFormScreen> createState() => _RegularizationFormScreenState();
}

class _RegularizationFormScreenState extends ConsumerState<RegularizationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _inTimeController = TextEditingController();
  final _outTimeController = TextEditingController();
  final _reasonController = TextEditingController();
  final _remarksController = TextEditingController();

  @override
  void dispose() {
    _dateController.dispose();
    _inTimeController.dispose();
    _outTimeController.dispose();
    _reasonController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final newReq = RegularizationModel(
      id: const Uuid().v4(),
      employeeName: 'Current User', // Mocked
      date: _dateController.text,
      inTime: _inTimeController.text,
      outTime: _outTimeController.text,
      reason: _reasonController.text,
      remarks: _remarksController.text,
      status: 'Pending',
    );

    ref.read(submitRegularizationProvider.notifier).submit(newReq).then((_) {
      if (mounted) context.pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final submitState = ref.watch(submitRegularizationProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Apply Regularization')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AppTextField(
                label: 'Date (YYYY-MM-DD)',
                controller: _dateController,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: AppSpacing.s16),
              AppTextField(
                label: 'In Time (e.g. 09:00 AM)',
                controller: _inTimeController,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: AppSpacing.s16),
              AppTextField(
                label: 'Out Time (e.g. 06:00 PM)',
                controller: _outTimeController,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: AppSpacing.s16),
              AppTextField(
                label: 'Reason',
                controller: _reasonController,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: AppSpacing.s16),
              AppTextField(
                label: 'Remarks (Optional)',
                controller: _remarksController,
              ),
              const SizedBox(height: AppSpacing.s32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: submitState.isLoading ? null : _submit,
                  child: submitState.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Submit Request'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
