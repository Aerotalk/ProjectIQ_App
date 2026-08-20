import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/inputs/app_date_picker.dart';
import '../../../../shared/widgets/inputs/app_time_picker.dart';
import '../../data/models/permission_model.dart';
import '../providers/permission_providers.dart';
import 'package:uuid/uuid.dart';
import '../../../../features/authentication/presentation/auth_controller.dart';

class PermissionFormScreen extends ConsumerStatefulWidget {
  const PermissionFormScreen({super.key});

  @override
  ConsumerState<PermissionFormScreen> createState() => _PermissionFormScreenState();
}

class _PermissionFormScreenState extends ConsumerState<PermissionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _permissionTypeController = TextEditingController();
  final _dateController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _permissionTypeController.dispose();
    _dateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  String _calculateTotalHours() {
    if (_startTimeController.text.isEmpty || _endTimeController.text.isEmpty) return '0.0';
    try {
      DateTime parseTime(String timeString) {
        final parts = timeString.split(' ');
        final timeParts = parts[0].split(':');
        int hour = int.parse(timeParts[0]);
        final int minute = int.parse(timeParts[1]);
        if (parts[1].toUpperCase() == 'PM' && hour != 12) hour += 12;
        if (parts[1].toUpperCase() == 'AM' && hour == 12) hour = 0;
        return DateTime(2000, 1, 1, hour, minute);
      }
      final start = parseTime(_startTimeController.text);
      final end = parseTime(_endTimeController.text);
      final diff = end.difference(start).inMinutes / 60.0;
      return diff > 0 ? diff.toStringAsFixed(1) : '0.0';
    } catch (e) {
      return '0.0';
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final user = ref.read(authControllerProvider).user;
      final userName = user?.username ?? 'Unknown Employee';

      final newPerm = PermissionModel(
        id: const Uuid().v4(),
        permissionNumber: 'PRM-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
        employeeId: user?.employeeId,
        employeeName: userName,
        department: 'Engineering',
        permissionDate: _dateController.text,
        permissionType: _permissionTypeController.text,
        startTime: _startTimeController.text,
        endTime: _endTimeController.text,
        totalHours: _calculateTotalHours(),
        reason: _reasonController.text,
        status: 'Pending',
      );

      ref.read(submitPermissionProvider.notifier).submit(newPerm).then((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permission request submitted successfully!')));
          context.pop();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final submitState = ref.watch(submitPermissionProvider);
    final isLoading = submitState is AsyncLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Permission', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AppTextField(
                label: 'Permission Type (e.g. Personal, Official)',
                controller: _permissionTypeController,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: AppSpacing.s16),
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
              Row(
                children: [
                  Expanded(
                    child: AppTimePicker(
                      label: 'Start Time *',
                      onChanged: (time) {
                        if (time != null) {
                          _startTimeController.text = "${time.hourOfPeriod.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} ${time.period == DayPeriod.am ? 'AM' : 'PM'}";
                        }
                      },
                      isRequired: true,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s16),
                  Expanded(
                    child: AppTimePicker(
                      label: 'End Time *',
                      onChanged: (time) {
                        if (time != null) {
                          _endTimeController.text = "${time.hourOfPeriod.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} ${time.period == DayPeriod.am ? 'AM' : 'PM'}";
                        }
                      },
                      isRequired: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s16),
              AppTextField(
                label: 'Reason',
                controller: _reasonController,
                maxLines: 3,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: AppSpacing.s32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Submit Request'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
