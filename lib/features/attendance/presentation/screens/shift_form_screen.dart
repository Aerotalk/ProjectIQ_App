import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../data/models/shift_model.dart';
import '../providers/shift_providers.dart';
import 'package:uuid/uuid.dart';

class ShiftFormScreen extends ConsumerStatefulWidget {
  const ShiftFormScreen({super.key});

  @override
  ConsumerState<ShiftFormScreen> createState() => _ShiftFormScreenState();
}

class _ShiftFormScreenState extends ConsumerState<ShiftFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _shiftNameController = TextEditingController();
  final _shiftCodeController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _graceTimeController = TextEditingController();

  @override
  void dispose() {
    _shiftNameController.dispose();
    _shiftCodeController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _graceTimeController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final newReq = ShiftModel(
      id: const Uuid().v4(),
      shiftName: _shiftNameController.text,
      shiftCode: _shiftCodeController.text,
      startTime: _startTimeController.text,
      endTime: _endTimeController.text,
      graceTimeMinutes: int.tryParse(_graceTimeController.text) ?? 0,
    );

    ref.read(submitShiftProvider.notifier).submit(newReq).then((_) {
      if (mounted) context.pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final submitState = ref.watch(submitShiftProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Shift')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AppTextField(
                label: 'Shift Name',
                controller: _shiftNameController,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: AppSpacing.s16),
              AppTextField(
                label: 'Shift Code',
                controller: _shiftCodeController,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: AppSpacing.s16),
              AppTextField(
                label: 'Start Time (e.g. 09:00 AM)',
                controller: _startTimeController,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: AppSpacing.s16),
              AppTextField(
                label: 'End Time (e.g. 06:00 PM)',
                controller: _endTimeController,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: AppSpacing.s16),
              AppTextField(
                label: 'Grace Time (Minutes)',
                controller: _graceTimeController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppSpacing.s32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: submitState.isLoading ? null : _submit,
                  child: submitState.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save Shift'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
