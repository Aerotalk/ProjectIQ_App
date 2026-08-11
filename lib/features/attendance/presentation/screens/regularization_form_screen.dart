import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/inputs/app_date_picker.dart';
import '../../../../shared/widgets/inputs/app_time_picker.dart';
import '../../data/models/regularization_model.dart';
import '../providers/regularization_providers.dart';
import 'package:uuid/uuid.dart';
import '../../../../features/authentication/presentation/auth_controller.dart';

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

    final user = ref.read(authControllerProvider).user;
    final userName = user?.username ?? 'Unknown Employee';

    final newReq = RegularizationModel(
      id: const Uuid().v4(),
      employeeName: userName,
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
              AppDatePicker(
                label: 'Date *',
                initialDate: DateTime.tryParse(_dateController.text),
                onChanged: (date) {
                  if (date != null) {
                    _dateController.text = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                  }
                },
                isRequired: true,
              ),
              const SizedBox(height: AppSpacing.s16),
              AppTimePicker(
                label: 'In Time *',
                onChanged: (time) {
                  if (time != null) {
                    final now = DateTime.now();
                    _inTimeController.text = "${time.hourOfPeriod.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} ${time.period == DayPeriod.am ? 'AM' : 'PM'}";
                  }
                },
                isRequired: true,
              ),
              const SizedBox(height: AppSpacing.s16),
              AppTimePicker(
                label: 'Out Time *',
                onChanged: (time) {
                  if (time != null) {
                    final now = DateTime.now();
                    _outTimeController.text = "${time.hourOfPeriod.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} ${time.period == DayPeriod.am ? 'AM' : 'PM'}";
                  }
                },
                isRequired: true,
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
