import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/inputs/app_select.dart';
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
  String? _roleId;
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.designation?.designationCode ?? '');
    _nameController = TextEditingController(text: widget.designation?.designationName ?? '');
    _roleId = widget.designation?.roleId ?? widget.designation?.role?['id'];
    _descController = TextEditingController(text: widget.designation?.description ?? '');
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

    final actionNotifier = ref.read(designationActionProvider.notifier);

    if (widget.designation == null) {
      await actionNotifier.createDesignation(
        designationCode: _codeController.text,
        designationName: _nameController.text,
        roleId: _roleId,
        description: _descController.text,
      );
    } else {
      await actionNotifier.updateDesignation(
        id: widget.designation!.id,
        designationCode: _codeController.text,
        designationName: _nameController.text,
        roleId: _roleId,
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
    final rolesAsync = ref.watch(availableRolesProvider);
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
              rolesAsync.when(
                data: (roles) {
                  final items = roles
                      .where((r) => !['ROLE_SUPER_ADMIN', 'ROLE_COMPANY_ADMIN', 'ROLE_ORG_ADMIN'].contains(r['roleName']))
                      .map((r) {
                    final label = r['roleName'].toString().replaceAll('ROLE_', '').replaceAll('_', ' ');
                    return DropdownMenuItem<String>(
                      value: r['id'].toString(),
                      child: Text(label),
                    );
                  }).toList();
                  return AppSelect<String>(
                    label: 'Role',
                    value: _roleId,
                    placeholder: 'Select a Role',
                    items: items,
                    onChanged: (val) => setState(() => _roleId = val),
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (err, st) => Text('Error loading roles: $err'),
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
