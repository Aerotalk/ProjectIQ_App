import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/buttons/app_button.dart';
import '../../data/models/department_model.dart';
import '../providers/department_providers.dart';

class DepartmentFormScreen extends ConsumerStatefulWidget {
  final DepartmentModel? department; // If null, it's create mode.

  const DepartmentFormScreen({super.key, this.department});

  @override
  ConsumerState<DepartmentFormScreen> createState() => _DepartmentFormScreenState();
}

class _DepartmentFormScreenState extends ConsumerState<DepartmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codeController;
  late TextEditingController _nameController;
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.department?.departmentCode ?? '');
    _nameController = TextEditingController(text: widget.department?.departmentName ?? '');
    _descController = TextEditingController(text: widget.department?.description ?? '');
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final actionNotifier = ref.read(departmentActionProvider.notifier);

    if (widget.department == null) {
      await actionNotifier.createDepartment(
        departmentCode: _codeController.text,
        departmentName: _nameController.text,
        description: _descController.text,
      );
    } else {
      await actionNotifier.updateDepartment(
        id: widget.department!.id,
        departmentCode: _codeController.text,
        departmentName: _nameController.text,
        description: _descController.text,
      );
    }

    final error = ref.read(departmentActionProvider).error;
    if (error == null && mounted) {
      context.pop();
    } else if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: AppColors.destructiveLight,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(departmentActionProvider);
    final isEdit = widget.department != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Department' : 'Add Department'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                label: 'Department Code *',
                controller: _codeController,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Department code is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.s16),
              AppTextField(
                label: 'Department Name *',
                controller: _nameController,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Department name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.s16),
              AppTextField(
                label: 'Description',
                controller: _descController,
                maxLines: 3,
              ),
              const SizedBox(height: AppSpacing.s32),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  onPressed: actionState.isLoading ? null : _submit,
                  isLoading: actionState.isLoading,
                  text: isEdit ? 'Update Department' : 'Save Department',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
