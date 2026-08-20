import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/inputs/app_date_picker.dart';
import '../../data/models/leave_model.dart';
import '../providers/leave_providers.dart';
import 'package:uuid/uuid.dart';
import '../../../../features/authentication/presentation/auth_controller.dart';

class LeaveFormScreen extends ConsumerStatefulWidget {
  const LeaveFormScreen({super.key});

  @override
  ConsumerState<LeaveFormScreen> createState() => _LeaveFormScreenState();
}

class _LeaveFormScreenState extends ConsumerState<LeaveFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _leaveTypeController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _leaveTypeController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authControllerProvider).user;
    final userName = user?.username ?? 'Unknown Employee';
    
    int duration = 1;
    final start = DateTime.tryParse(_startDateController.text);
    final end = DateTime.tryParse(_endDateController.text);
    if (start != null && end != null) {
      duration = end.difference(start).inDays + 1;
      if (duration < 1) duration = 1;
    }

    final newReq = LeaveModel(
      id: const Uuid().v4(),
      leaveType: _leaveTypeController.text,
      employeeId: user?.employeeId,
      employeeName: userName,
      startDate: _startDateController.text,
      endDate: _endDateController.text,
      durationDays: duration,
      reason: _reasonController.text,
      status: 'Pending',
    );

    ref.read(submitLeaveProvider.notifier).submit(newReq);
  }

  @override
  Widget build(BuildContext context) {
    final submitState = ref.watch(submitLeaveProvider);

    ref.listen(submitLeaveProvider, (prev, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${next.error}'), backgroundColor: Colors.red),
        );
      } else if (!next.isLoading && next.hasValue && prev?.isLoading == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Leave applied successfully')),
        );
        context.pop();
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Apply Leave')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AppTextField(
                label: 'Leave Type (e.g. Sick, Casual)',
                controller: _leaveTypeController,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: AppSpacing.s16),
              AppDatePicker(
                label: 'Start Date *',
                initialDate: DateTime.tryParse(_startDateController.text),
                onChanged: (date) {
                  if (date != null) {
                    _startDateController.text = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                  }
                },
                isRequired: true,
              ),
              const SizedBox(height: AppSpacing.s8),
              DropdownButtonFormField<String>(
                initialValue: 'Session 1',
                decoration: const InputDecoration(labelText: 'From Session', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'Session 1', child: Text('Session 1 (Morning)')),
                  DropdownMenuItem(value: 'Session 2', child: Text('Session 2 (Afternoon)')),
                ],
                onChanged: (v) {},
              ),
              const SizedBox(height: AppSpacing.s16),
              AppDatePicker(
                label: 'End Date *',
                initialDate: DateTime.tryParse(_endDateController.text),
                onChanged: (date) {
                  if (date != null) {
                    _endDateController.text = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                  }
                },
                isRequired: true,
              ),
              const SizedBox(height: AppSpacing.s8),
              DropdownButtonFormField<String>(
                initialValue: 'Session 2',
                decoration: const InputDecoration(labelText: 'To Session', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'Session 1', child: Text('Session 1 (Morning)')),
                  DropdownMenuItem(value: 'Session 2', child: Text('Session 2 (Afternoon)')),
                ],
                onChanged: (v) {},
              ),
              const SizedBox(height: AppSpacing.s16),
              AppTextField(
                label: 'Reason',
                controller: _reasonController,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: AppSpacing.s32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: submitState.isLoading ? null : _submit,
                  child: submitState.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Submit Application'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
