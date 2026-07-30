import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../data/models/designation_model.dart';
import '../providers/designation_providers.dart';

class DesignationFormScreen extends ConsumerStatefulWidget {
  final DesignationModel? designation; // If null, it's create mode.

  const DesignationFormScreen({super.key, this.designation});

  @override
  ConsumerState<DesignationFormScreen> createState() => _DesignationFormScreenState();
}

class _DesignationFormScreenState extends ConsumerState<DesignationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codeController;
  late TextEditingController _nameController;
  late TextEditingController _levelController;
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.designation?.designationCode ?? '');
    _nameController = TextEditingController(text: widget.designation?.designationName ?? '');
    _levelController = TextEditingController(
      text: widget.designation?.hierarchyLevel != null ? widget.designation!.hierarchyLevel.toString() : '',
    );
    _descController = TextEditingController(text: widget.designation?.description ?? '');
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _levelController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final actionNotifier = ref.read(designationActionProvider.notifier);
    final hierarchyLevel = int.tryParse(_levelController.text);

    if (widget.designation == null) {
      await actionNotifier.createDesignation(
        designationCode: _codeController.text,
        designationName: _nameController.text,
        hierarchyLevel: hierarchyLevel,
        description: _descController.text,
      );
    } else {
      await actionNotifier.updateDesignation(
        id: widget.designation!.id,
        designationCode: _codeController.text,
        designationName: _nameController.text,
        hierarchyLevel: hierarchyLevel,
        description: _descController.text,
      );
    }

    final error = ref.read(designationActionProvider).error;
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
    final actionState = ref.watch(designationActionProvider);
    final isEdit = widget.designation != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Designation' : 'Add Designation'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                label: 'Designation Code *',
                controller: _codeController,
                placeholder: 'e.g. SDEV, MGR, DIR',
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Designation code is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.s16),
              AppTextField(
                label: 'Designation Name *',
                controller: _nameController,
                placeholder: 'e.g. Senior Developer',
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Designation name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.s16),
              AppTextField(
                label: 'Hierarchy Level *',
                controller: _levelController,
                keyboardType: TextInputType.number,
                placeholder: '1 (Highest), 2, 3...',
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Hierarchy level is required';
                  }
                  if (int.tryParse(val) == null) {
                    return 'Must be a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.s16),
              AppTextField(
                label: 'Description',
                controller: _descController,
                maxLines: 3,
                placeholder: 'Brief description of the designation...',
              ),
              const SizedBox(height: AppSpacing.s32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: actionState.isLoading ? null : _submit,
                  child: actionState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(isEdit ? 'Update Designation' : 'Save Designation'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
