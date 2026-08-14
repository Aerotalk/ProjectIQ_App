import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:projectiq_app/shared/widgets/inputs/app_text_field.dart';
import 'package:projectiq_app/shared/widgets/inputs/app_phone_field.dart';
import 'package:projectiq_app/shared/widgets/inputs/app_select.dart';
import 'package:projectiq_app/shared/widgets/inputs/app_date_picker.dart';
import 'package:projectiq_app/shared/widgets/inputs/app_country_state_picker.dart';
import 'package:projectiq_app/core/theme/app_spacing.dart';
import 'package:projectiq_app/features/hrms/presentation/providers/employee_form_provider.dart';
import 'package:file_picker/file_picker.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────
String _fmtDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime? _parseDate(Map<String, dynamic> data, String key) {
  final v = data[key];
  return v != null ? DateTime.tryParse(v.toString()) : null;
}

Widget _sectionTitle(String title) => Padding(
  padding: const EdgeInsets.only(bottom: AppSpacing.s8, top: AppSpacing.s8),
  child: Text(
    title,
    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
  ),
);

Widget _divider() => const Padding(
  padding: EdgeInsets.symmetric(vertical: AppSpacing.s8),
  child: Divider(),
);

/// Shader-safe replacement for Checkbox — avoids circular GPU geometry.
Widget _appCheckTile({
  required String label,
  required bool value,
  required ValueChanged<bool> onChanged,
}) {
  return GestureDetector(
    onTap: () => onChanged(!value),
    child: Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: value ? const Color(0xFF6366F1) : Colors.transparent,
            border: Border.all(
              color: value ? const Color(0xFF6366F1) : Colors.grey,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(
              4,
            ), // square, not circle — avoids shader
          ),
          child: value
              ? const Icon(Icons.check, size: 14, color: Colors.white)
              : null,
        ),
        const SizedBox(width: AppSpacing.s8),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    ),
  );
}

/// Shader-safe replacement for Card — plain bordered Container, zero elevation.
Widget _itemCard({required Widget child}) {
  return Container(
    margin: const EdgeInsets.only(bottom: AppSpacing.s16),
    padding: const EdgeInsets.all(AppSpacing.s16),
    decoration: BoxDecoration(
      border: Border.all(color: const Color(0xFFE5E7EB)),
      borderRadius: BorderRadius.circular(8),
    ),
    child: child,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 1 – Basic Info  (matches BasicInfoTab.tsx)
// ─────────────────────────────────────────────────────────────────────────────
class BasicInfoStep extends ConsumerWidget {
  const BasicInfoStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = ref.read(employeeFormProvider.notifier);
    final d = ref.watch(employeeFormProvider).formData;
    const sp = SizedBox(height: AppSpacing.s16);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Basic Information ───────────────────────────────────────────────
          _sectionTitle('Basic Information'),
          AppTextField(
            label: 'First Name *',
            initialValue: d['firstName']?.toString(),
            onChanged: (v) => n.updateField('firstName', v),
          ),
          sp,
          AppTextField(
            label: 'Last Name *',
            initialValue: d['lastName']?.toString(),
            onChanged: (v) => n.updateField('lastName', v),
          ),
          sp,
          AppTextField(
            label: 'Middle Name',
            initialValue: d['middleName']?.toString(),
            onChanged: (v) => n.updateField('middleName', v),
          ),
          sp,
          AppDatePicker(
            label: 'Date of Birth *',
            initialDate: _parseDate(d, 'dateOfBirth'),
            onChanged: (v) {
              if (v != null) n.updateField('dateOfBirth', _fmtDate(v));
            },
          ),
          sp,
          AppTextField(
            label: 'Work Email *',
            initialValue: d['workEmail']?.toString(),
            onChanged: (v) => n.updateField('workEmail', v),
          ),
          sp,
          AppPhoneField(
            label: 'Phone *',
            initialValue: d['phone']?.toString(),
            onChanged: (v) => n.updateField('phone', v),
          ),
          sp,
          AppPhoneField(
            label: 'Alternate Phone *',
            initialValue: d['alternatePhone']?.toString(),
            onChanged: (v) => n.updateField('alternatePhone', v),
          ),
          sp,
          AppSelect<String>(
            value: d['gender'] as String?,
            label: 'Gender *',
            placeholder: 'Select Gender',
            items: [
              'Male',
              'Female',
              'Other',
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => n.updateField('gender', v),
          ),
          sp,
          AppSelect<String>(
            value: d['maritalStatus'] as String?,
            label: 'Marital Status *',
            placeholder: 'Select',
            items: [
              'Single',
              'Married',
              'Divorced',
              'Widowed',
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => n.updateField('maritalStatus', v),
          ),
          sp,
          AppSelect<String>(
            value: d['bloodGroup'] as String?,
            label: 'Blood Group *',
            placeholder: 'Select',
            items: [
              'A+',
              'A-',
              'B+',
              'B-',
              'AB+',
              'AB-',
              'O+',
              'O-',
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => n.updateField('bloodGroup', v),
          ),
          sp,
          AppTextField(
            label: 'Nationality *',
            initialValue: d['nationality']?.toString(),
            onChanged: (v) => n.updateField('nationality', v),
          ),
          sp,
          _sectionTitle('Profile Photo *'),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF3F4F6),
              foregroundColor: const Color(0xFF4B5563),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
              if (result != null) {
                n.updateField('profilePhoto', result.files.single.path ?? 'uploaded_id');
              }
            },
            icon: const Icon(Icons.upload_file, size: 20),
            label: Text(d['profilePhoto'] != null ? 'Change Photo' : 'Upload Profile Photo'),
          ),
          if (d['profilePhoto'] != null) ...[
            const SizedBox(height: 4),
            const Text('Photo selected ✓', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600)),
          ],

          // ── Employment Details ──────────────────────────────────────────────
          _divider(),
          _sectionTitle('Employment Details'),
          AppDatePicker(
            label: 'Date of Joining *',
            initialDate: _parseDate(d, 'dateOfJoining'),
            onChanged: (v) {
              if (v != null) n.updateField('dateOfJoining', _fmtDate(v));
            },
          ),
          sp,
          AppSelect<String>(
            value: d['employmentType'] as String?,
            label: 'Employment Type *',
            placeholder: 'Select',
            items: [
              'Full Time',
              'Part Time',
              'Contract',
              'Intern',
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => n.updateField('employmentType', v),
          ),
          sp,
          AppTextField(
            label: 'Company / Legal Entity *',
            initialValue: d['companyId']?.toString(),
            onChanged: (v) => n.updateField('companyId', v),
          ),
          sp,
          AppTextField(
            label: 'Department *',
            initialValue: d['departmentId']?.toString(),
            onChanged: (v) => n.updateField('departmentId', v),
          ),
          sp,
          AppTextField(
            label: 'Designation *',
            initialValue: d['designationId']?.toString(),
            onChanged: (v) => n.updateField('designationId', v),
          ),
          sp,
          AppTextField(
            label: 'Location *',
            initialValue: d['location']?.toString(),
            onChanged: (v) => n.updateField('location', v),
          ),
          sp,
          AppTextField(
            label: 'Grade / Band *',
            initialValue: d['grade']?.toString(),
            onChanged: (v) => n.updateField('grade', v),
          ),
          sp,
          AppTextField(
            label: 'Reporting Manager *',
            initialValue: d['reportingManagerId']?.toString(),
            onChanged: (v) => n.updateField('reportingManagerId', v),
          ),
          sp,
          AppTextField(
            label: 'HR Manager *',
            initialValue: d['hrManagerId']?.toString(),
            onChanged: (v) => n.updateField('hrManagerId', v),
          ),
          sp,
          AppTextField(
            label: 'Weekly Off *',
            initialValue: d['weeklyOff']?.toString(),
            onChanged: (v) => n.updateField('weeklyOff', v),
          ),

          sp,
          AppTextField(
            label: "Father's Name",
            initialValue: d['fatherName']?.toString(),
            onChanged: (v) => n.updateField('fatherName', v),
          ),
          sp,
          AppTextField(
            label: 'Notice Period (Days) *',
            initialValue: d['noticePeriodDays']?.toString(),
            keyboardType: TextInputType.number,
            onChanged: (v) => n.updateField('noticePeriodDays', v),
          ),
          const SizedBox(height: AppSpacing.s24),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 2 – Address  (matches AddressTab.tsx – present + permanent address)
// ─────────────────────────────────────────────────────────────────────────────
class ContactInfoStep extends ConsumerWidget {
  const ContactInfoStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = ref.read(employeeFormProvider.notifier);
    final d = ref.watch(employeeFormProvider).formData;
    const sp = SizedBox(height: AppSpacing.s16);

    final sameAddress = d['sameAsPresentAddress'] == true;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Present Address ─────────────────────────────────────────────────
          _sectionTitle('Present Address'),
          AppTextField(
            label: 'Address Line 1',
            initialValue: d['presentAddressLine1']?.toString(),
            onChanged: (v) => n.updateField('presentAddressLine1', v),
          ),
          sp,
          AppTextField(
            label: 'Address Line 2',
            initialValue: d['presentAddressLine2']?.toString(),
            onChanged: (v) => n.updateField('presentAddressLine2', v),
          ),
          sp,
          AppTextField(
            label: 'City',
            initialValue: d['presentCity']?.toString(),
            onChanged: (v) => n.updateField('presentCity', v),
          ),
          sp,
          AppTextField(
            label: 'Pin Code',
            initialValue: d['presentPinCode']?.toString(),
            keyboardType: TextInputType.number,
            onChanged: (v) => n.updateField('presentPinCode', v),
          ),
          sp,
          AppCountryStatePicker(
            label: 'Country & State',
            initialCountry: d['presentCountry']?.toString(),
            initialState: d['presentState']?.toString(),
            onCountryChanged: (v) => n.updateField('presentCountry', v),
            onStateChanged: (v) => n.updateField('presentState', v),
          ),
          sp,
          AppPhoneField(
            label: 'Phone',
            initialValue: d['presentPhone']?.toString(),
            onChanged: (v) => n.updateField('presentPhone', v),
          ),

          // ── Same as Present ─────────────────────────────────────────────────
          _divider(),
          _appCheckTile(
            label: 'Same as Present Address',
            value: sameAddress,
            onChanged: (val) {
              n.updateField('sameAsPresentAddress', val);
              if (val) {
                n.updateField(
                  'permanentAddressLine1',
                  d['presentAddressLine1'],
                );
                n.updateField(
                  'permanentAddressLine2',
                  d['presentAddressLine2'],
                );
                n.updateField('permanentCity', d['presentCity']);
                n.updateField('permanentState', d['presentState']);
                n.updateField('permanentPinCode', d['presentPinCode']);
                n.updateField('permanentCountry', d['presentCountry']);
                n.updateField('permanentPhone', d['presentPhone']);
              }
            },
          ),

          // ── Permanent Address ───────────────────────────────────────────────
          _sectionTitle('Permanent Address'),
          AppTextField(
            label: 'Address Line 1',
            initialValue: d['permanentAddressLine1']?.toString(),
            onChanged: (v) => n.updateField('permanentAddressLine1', v),
          ),
          sp,
          AppTextField(
            label: 'Address Line 2',
            initialValue: d['permanentAddressLine2']?.toString(),
            onChanged: (v) => n.updateField('permanentAddressLine2', v),
          ),
          sp,
          AppTextField(
            label: 'City',
            initialValue: d['permanentCity']?.toString(),
            onChanged: (v) => n.updateField('permanentCity', v),
          ),
          sp,
          AppTextField(
            label: 'Pin Code',
            initialValue: d['permanentPinCode']?.toString(),
            keyboardType: TextInputType.number,
            onChanged: (v) => n.updateField('permanentPinCode', v),
          ),
          sp,
          AppCountryStatePicker(
            label: 'Country & State',
            initialCountry: d['permanentCountry']?.toString(),
            initialState: d['permanentState']?.toString(),
            onCountryChanged: (v) => n.updateField('permanentCountry', v),
            onStateChanged: (v) => n.updateField('permanentState', v),
          ),
          sp,
          AppPhoneField(
            label: 'Phone',
            initialValue: d['permanentPhone']?.toString(),
            onChanged: (v) => n.updateField('permanentPhone', v),
          ),
          const SizedBox(height: AppSpacing.s24),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 3 – Emergency Contact  (matches EmergencyContactTab.tsx)
// ─────────────────────────────────────────────────────────────────────────────
class EmergencyContactStep extends ConsumerWidget {
  const EmergencyContactStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = ref.read(employeeFormProvider.notifier);
    final d = ref.watch(employeeFormProvider).formData;
    const sp = SizedBox(height: AppSpacing.s16);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Emergency Contact'),
          AppTextField(
            label: 'Contact Name',
            initialValue: d['emergencyContactName']?.toString(),
            onChanged: (v) => n.updateField('emergencyContactName', v),
          ),
          sp,
          AppTextField(
            label: 'Relationship',
            initialValue: d['emergencyRelationship']?.toString(),
            onChanged: (v) => n.updateField('emergencyRelationship', v),
          ),
          sp,
          AppPhoneField(
            label: 'Phone',
            initialValue: d['emergencyPhone']?.toString(),
            onChanged: (v) => n.updateField('emergencyPhone', v),
          ),
          sp,
          AppPhoneField(
            label: 'Alternate Phone',
            initialValue: d['emergencyAlternatePhone']?.toString(),
            onChanged: (v) => n.updateField('emergencyAlternatePhone', v),
          ),
          sp,
          AppTextField(
            label: 'Email',
            initialValue: d['emergencyEmail']?.toString(),
            keyboardType: TextInputType.emailAddress,
            onChanged: (v) => n.updateField('emergencyEmail', v),
          ),
          sp,
          AppTextField(
            label: 'Address',
            initialValue: d['emergencyAddress']?.toString(),
            onChanged: (v) => n.updateField('emergencyAddress', v),
          ),
          sp,
          _appCheckTile(
            label: 'Is Primary Contact',
            value: d['emergencyPrimaryContact'] == true,
            onChanged: (val) => n.updateField('emergencyPrimaryContact', val),
          ),
          const SizedBox(height: AppSpacing.s24),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 4 – Employment Contract  (matches EmploymentContractTab.tsx)
// ─────────────────────────────────────────────────────────────────────────────
class EmploymentContractStep extends ConsumerWidget {
  const EmploymentContractStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = ref.read(employeeFormProvider.notifier);
    final d = ref.watch(employeeFormProvider).formData;
    const sp = SizedBox(height: AppSpacing.s16);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Employment Contract'),
          AppSelect<String>(
            value: d['contractType'] as String?,
            label: 'Contract Type',
            placeholder: 'Select Type',
            items: [
              'Permanent',
              'Fixed Term',
              'Consultant',
              'Internship',
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => n.updateField('contractType', v),
          ),
          sp,
          AppDatePicker(
            label: 'Start Date',
            initialDate: _parseDate(d, 'contractStartDate'),
            onChanged: (v) {
              if (v != null) n.updateField('contractStartDate', _fmtDate(v));
            },
          ),
          sp,
          AppDatePicker(
            label: 'End Date',
            initialDate: _parseDate(d, 'contractEndDate'),
            onChanged: (v) {
              if (v != null) n.updateField('contractEndDate', _fmtDate(v));
            },
          ),
          sp,
          AppTextField(
            label: 'Annual CTC',
            initialValue: d['contractAnnualCTC']?.toString(),
            keyboardType: TextInputType.number,
            onChanged: (v) => n.updateField('contractAnnualCTC', v),
          ),
          sp,
          AppTextField(
            label: 'Notice Period (Days)',
            initialValue: d['contractNoticePeriod']?.toString(),
            keyboardType: TextInputType.number,
            onChanged: (v) => n.updateField('contractNoticePeriod', v),
          ),
          sp,
          AppTextField(
            label: 'Contract Terms',
            initialValue: d['contractTerms']?.toString(),
            maxLines: 3,
            onChanged: (v) => n.updateField('contractTerms', v),
          ),
          sp,
          _buildFileUploader(
            context,
            ref,
            d,
            'Signed Contract Upload',
            'signedContract',
          ),
          const SizedBox(height: AppSpacing.s24),
        ],
      ),
    );
  }

  Widget _buildFileUploader(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> data,
    String label,
    String key,
  ) {
    final n = ref.read(employeeFormProvider.notifier);
    final fileName = data['${key}_name'] as String?;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: AppSpacing.s8),
        Container(
          padding: const EdgeInsets.all(AppSpacing.s12),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  fileName ?? 'No file selected',
                  style: TextStyle(
                    color: fileName != null ? Colors.green : Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: [
                        'jpg',
                        'jpeg',
                        'png',
                        'pdf',
                        'doc',
                        'docx',
                        'xls',
                        'xlsx',
                      ],
                    );
                    if (result != null) {
                      final f = result.files.single;
                      n.updateField('${key}_name', f.name);
                      if (f.path != null) n.updateField('${key}_path', f.path);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  }
                },
                child: const Text('Choose File'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 5 – Bank Details  (matches BankDetailsTab.tsx)
// ─────────────────────────────────────────────────────────────────────────────
class BankDetailsStep extends ConsumerWidget {
  const BankDetailsStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = ref.read(employeeFormProvider.notifier);
    final d = ref.watch(employeeFormProvider).formData;
    const sp = SizedBox(height: AppSpacing.s16);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Bank Details'),
          AppTextField(
            label: 'Bank Name',
            initialValue: d['bankName']?.toString(),
            onChanged: (v) => n.updateField('bankName', v),
          ),
          sp,
          AppTextField(
            label: 'Branch Name',
            initialValue: d['branchName']?.toString(),
            onChanged: (v) => n.updateField('branchName', v),
          ),
          sp,
          AppTextField(
            label: 'Account Number',
            initialValue: d['accountNumber']?.toString(),
            onChanged: (v) => n.updateField('accountNumber', v),
          ),
          sp,
          AppTextField(
            label: 'Confirm Account Number',
            initialValue: d['confirmAccountNumber']?.toString(),
            onChanged: (v) => n.updateField('confirmAccountNumber', v),
          ),
          sp,
          AppTextField(
            label: 'IFSC Code',
            initialValue: d['ifscCode']?.toString(),
            onChanged: (v) => n.updateField('ifscCode', v),
          ),
          sp,
          AppSelect<String>(
            value: d['accountType'] as String?,
            label: 'Account Type',
            placeholder: 'Select',
            items: [
              'Savings',
              'Current',
              'Salary',
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => n.updateField('accountType', v),
          ),
          sp,
          AppTextField(
            label: 'Account Holder Name',
            initialValue: d['accountHolderName']?.toString(),
            onChanged: (v) => n.updateField('accountHolderName', v),
          ),
          sp,
          AppSelect<String>(
            value: d['paymentMode'] as String?,
            label: 'Payment Mode',
            placeholder: 'Select',
            items: [
              'Bank Transfer',
              'Cheque',
              'Cash',
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => n.updateField('paymentMode', v),
          ),
          sp,
          _appCheckTile(
            label: 'Primary Account',
            value: d['primaryAccount'] == true,
            onChanged: (val) => n.updateField('primaryAccount', val),
          ),
          const SizedBox(height: AppSpacing.s24),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 6 – Statutory Details  (matches StatutoryDetailsTab.tsx)
// ─────────────────────────────────────────────────────────────────────────────
class StatutoryDetailsStep extends ConsumerWidget {
  const StatutoryDetailsStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = ref.read(employeeFormProvider.notifier);
    final d = ref.watch(employeeFormProvider).formData;
    const sp = SizedBox(height: AppSpacing.s16);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Statutory Details'),
          AppTextField(
            label: 'PAN Number',
            initialValue: d['panNumber']?.toString(),
            onChanged: (v) => n.updateField('panNumber', v),
          ),
          sp,
          AppTextField(
            label: 'Aadhaar Number',
            initialValue: d['aadhaarNumber']?.toString(),
            onChanged: (v) => n.updateField('aadhaarNumber', v),
          ),
          sp,
          AppTextField(
            label: 'UAN (PF)',
            initialValue: d['uan']?.toString(),
            onChanged: (v) => n.updateField('uan', v),
          ),
          sp,
          AppTextField(
            label: 'PF Number',
            initialValue: d['pfNumber']?.toString(),
            onChanged: (v) => n.updateField('pfNumber', v),
          ),
          sp,
          AppTextField(
            label: 'ESI Number',
            initialValue: d['esiNumber']?.toString(),
            onChanged: (v) => n.updateField('esiNumber', v),
          ),
          sp,
          AppSelect<String>(
            value: d['taxRegime'] as String?,
            label: 'Tax Regime',
            placeholder: 'Select',
            items: const [
              DropdownMenuItem(value: 'Old', child: Text('Old Regime')),
              DropdownMenuItem(value: 'New', child: Text('New Regime')),
            ],
            onChanged: (v) => n.updateField('taxRegime', v),
          ),
          sp,
          AppTextField(
            label: 'Passport Number',
            initialValue: d['passportNumber']?.toString(),
            onChanged: (v) => n.updateField('passportNumber', v),
          ),
          sp,
          AppDatePicker(
            label: 'Passport Expiry',
            initialDate: _parseDate(d, 'passportExpiry'),
            onChanged: (v) {
              if (v != null) n.updateField('passportExpiry', _fmtDate(v));
            },
          ),
          sp,
          AppTextField(
            label: 'Voter ID',
            initialValue: d['voterId']?.toString(),
            onChanged: (v) => n.updateField('voterId', v),
          ),
          sp,
          AppTextField(
            label: 'Driving License',
            initialValue: d['drivingLicense']?.toString(),
            onChanged: (v) => n.updateField('drivingLicense', v),
          ),
          sp,
          AppDatePicker(
            label: 'Driving License Expiry',
            initialDate: _parseDate(d, 'drivingLicenseExpiry'),
            onChanged: (v) {
              if (v != null) n.updateField('drivingLicenseExpiry', _fmtDate(v));
            },
          ),
          sp,
          Row(
            children: [
              _appCheckTile(
                label: 'PF Applicable',
                value: d['pfApplicable'] == true,
                onChanged: (val) => n.updateField('pfApplicable', val),
              ),
              const SizedBox(width: AppSpacing.s24),
              _appCheckTile(
                label: 'ESI Applicable',
                value: d['esiApplicable'] == true,
                onChanged: (val) => n.updateField('esiApplicable', val),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s24),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 7 – Family & Nominee  (matches FamilyNomineeTab.tsx – dynamic list)
// ─────────────────────────────────────────────────────────────────────────────
class FamilyNomineeStep extends ConsumerWidget {
  const FamilyNomineeStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = ref.read(employeeFormProvider.notifier);
    final d = ref.watch(employeeFormProvider).formData;
    final families = (d['families'] as List<dynamic>?) ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionTitle('Family & Nominee'),
              TextButton.icon(
                onPressed: () {
                  final updated = List<Map<String, dynamic>>.from(
                    families.map((e) => Map<String, dynamic>.from(e as Map)),
                  );
                  updated.add({
                    'name': '',
                    'relationship': '',
                    'dateOfBirth': '',
                    'gender': null,
                    'phone': '',
                    'nomineePercentage': 0,
                    'isDependent': false,
                    'isNominee': false,
                  });
                  n.updateField('families', updated);
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Member'),
              ),
            ],
          ),
          if (families.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.s24),
              margin: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  "No family members added yet. Tap 'Add Member' to include a record.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ...families.asMap().entries.map((entry) {
            final i = entry.key;
            final m = Map<String, dynamic>.from(entry.value as Map);
            const sp = SizedBox(height: AppSpacing.s12);

            return _itemCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Member ${i + 1}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      GestureDetector(
                        onTap: () {
                          final updated = List<Map<String, dynamic>>.from(
                            families.map(
                              (e) => Map<String, dynamic>.from(e as Map),
                            ),
                          );
                          updated.removeAt(i);
                          n.updateField('families', updated);
                        },
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  AppTextField(
                    label: 'Name',
                    initialValue: m['name']?.toString(),
                    onChanged: (v) {
                      final u = _updateList(families, i, 'name', v);
                      n.updateField('families', u);
                    },
                  ),
                  sp,
                  AppTextField(
                    label: 'Relationship',
                    initialValue: m['relationship']?.toString(),
                    onChanged: (v) {
                      final u = _updateList(families, i, 'relationship', v);
                      n.updateField('families', u);
                    },
                  ),
                  sp,
                  AppDatePicker(
                    label: 'Date of Birth',
                    initialDate:
                        m['dateOfBirth'] != null &&
                            m['dateOfBirth'].toString().isNotEmpty
                        ? DateTime.tryParse(m['dateOfBirth'].toString())
                        : null,
                    onChanged: (v) {
                      if (v != null) {
                        final u = _updateList(
                          families,
                          i,
                          'dateOfBirth',
                          _fmtDate(v),
                        );
                        n.updateField('families', u);
                      }
                    },
                  ),
                  sp,
                  AppSelect<String>(
                    value:
                        (m['gender'] == null || m['gender'].toString().isEmpty)
                        ? null
                        : m['gender'] as String?,
                    label: 'Gender',
                    placeholder: 'Select',
                    items: ['Male', 'Female', 'Other']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) {
                      final u = _updateList(families, i, 'gender', v);
                      n.updateField('families', u);
                    },
                  ),
                  sp,
                  AppTextField(
                    label: 'Phone',
                    initialValue: m['phone']?.toString(),
                    keyboardType: TextInputType.phone,
                    onChanged: (v) {
                      final u = _updateList(families, i, 'phone', v);
                      n.updateField('families', u);
                    },
                  ),
                  sp,
                  AppTextField(
                    label: 'Nominee %',
                    initialValue: m['nomineePercentage']?.toString(),
                    keyboardType: TextInputType.number,
                    onChanged: (v) {
                      final u = _updateList(
                        families,
                        i,
                        'nomineePercentage',
                        int.tryParse(v) ?? 0,
                      );
                      n.updateField('families', u);
                    },
                  ),
                  sp,
                  Row(
                    children: [
                      _appCheckTile(
                        label: 'Is Dependent',
                        value: m['isDependent'] == true,
                        onChanged: (v) {
                          final u = _updateList(families, i, 'isDependent', v);
                          n.updateField('families', u);
                        },
                      ),
                      const SizedBox(width: AppSpacing.s16),
                      _appCheckTile(
                        label: 'Is Nominee',
                        value: m['isNominee'] == true,
                        onChanged: (v) {
                          final u = _updateList(families, i, 'isNominee', v);
                          n.updateField('families', u);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: AppSpacing.s24),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _updateList(
    List<dynamic> list,
    int index,
    String key,
    dynamic value,
  ) {
    final updated = list
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    updated[index][key] = value;
    return updated;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 8 – Education  (matches EducationTab.tsx – dynamic list)
// ─────────────────────────────────────────────────────────────────────────────
class EducationStep extends ConsumerWidget {
  const EducationStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = ref.read(employeeFormProvider.notifier);
    final d = ref.watch(employeeFormProvider).formData;
    final educations = (d['educations'] as List<dynamic>?) ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionTitle('Education'),
              TextButton.icon(
                onPressed: () {
                  final updated = List<Map<String, dynamic>>.from(
                    educations.map((e) => Map<String, dynamic>.from(e as Map)),
                  );
                  updated.add({
                    'degree': '',
                    'qualification': '',
                    'institution': '',
                    'fieldOfStudy': '',
                    'startYear': '',
                    'endYear': '',
                    'grade': '',
                  });
                  n.updateField('educations', updated);
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Education'),
              ),
            ],
          ),
          if (educations.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.s24),
              margin: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  "No education records added yet.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ...educations.asMap().entries.map((entry) {
            final i = entry.key;
            final m = Map<String, dynamic>.from(entry.value as Map);
            const sp = SizedBox(height: AppSpacing.s12);

            return _itemCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Education ${i + 1}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      GestureDetector(
                        onTap: () {
                          final updated = List<Map<String, dynamic>>.from(
                            educations.map(
                              (e) => Map<String, dynamic>.from(e as Map),
                            ),
                          );
                          updated.removeAt(i);
                          n.updateField('educations', updated);
                        },
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  AppTextField(
                    label: 'Degree',
                    initialValue: m['degree']?.toString(),
                    onChanged: (v) {
                      n.updateField(
                        'educations',
                        _updateList(educations, i, 'degree', v),
                      );
                    },
                  ),
                  sp,
                  AppTextField(
                    label: 'Qualification',
                    initialValue: m['qualification']?.toString(),
                    onChanged: (v) {
                      n.updateField(
                        'educations',
                        _updateList(educations, i, 'qualification', v),
                      );
                    },
                  ),
                  sp,
                  AppTextField(
                    label: 'Institution',
                    initialValue: m['institution']?.toString(),
                    onChanged: (v) {
                      n.updateField(
                        'educations',
                        _updateList(educations, i, 'institution', v),
                      );
                    },
                  ),
                  sp,
                  AppTextField(
                    label: 'Field of Study',
                    initialValue: m['fieldOfStudy']?.toString(),
                    onChanged: (v) {
                      n.updateField(
                        'educations',
                        _updateList(educations, i, 'fieldOfStudy', v),
                      );
                    },
                  ),
                  sp,
                  AppTextField(
                    label: 'Start Year (YYYY)',
                    initialValue: m['startYear']?.toString(),
                    keyboardType: TextInputType.number,
                    onChanged: (v) {
                      n.updateField(
                        'educations',
                        _updateList(educations, i, 'startYear', v),
                      );
                    },
                  ),
                  sp,
                  AppTextField(
                    label: 'End Year (YYYY)',
                    initialValue: m['endYear']?.toString(),
                    keyboardType: TextInputType.number,
                    onChanged: (v) {
                      n.updateField(
                        'educations',
                        _updateList(educations, i, 'endYear', v),
                      );
                    },
                  ),
                  sp,
                  AppTextField(
                    label: 'Grade / Score',
                    initialValue: m['grade']?.toString(),
                    onChanged: (v) {
                      n.updateField(
                        'educations',
                        _updateList(educations, i, 'grade', v),
                      );
                    },
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: AppSpacing.s24),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _updateList(
    List<dynamic> list,
    int index,
    String key,
    dynamic value,
  ) {
    final updated = list
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    updated[index][key] = value;
    return updated;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 9 – Documents  (matches DocumentsTab.tsx – dynamic list)
// ─────────────────────────────────────────────────────────────────────────────
class DocumentsStep extends ConsumerWidget {
  const DocumentsStep({super.key});

  Future<void> _pickFile(
    BuildContext context,
    WidgetRef ref,
    List<dynamic> docs,
    int index,
  ) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'jpg',
          'jpeg',
          'png',
          'pdf',
          'doc',
          'docx',
          'xls',
          'xlsx',
        ],
      );
      if (result != null) {
        final f = result.files.single;
        final n = ref.read(employeeFormProvider.notifier);
        final updated = docs
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        updated[index]['fileName'] = f.name;
        if (f.path != null) updated[index]['filePath'] = f.path;
        n.updateField('documents', updated);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = ref.read(employeeFormProvider.notifier);
    final d = ref.watch(employeeFormProvider).formData;
    final docs = (d['documents'] as List<dynamic>?) ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionTitle('Documents'),
              TextButton.icon(
                onPressed: () {
                  final updated = List<Map<String, dynamic>>.from(
                    docs.map((e) => Map<String, dynamic>.from(e as Map)),
                  );
                  updated.add({
                    'documentCategory': null,
                    'documentName': '',
                    'fileName': null,
                    'filePath': null,
                    'expiryDate': '',
                  });
                  n.updateField('documents', updated);
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Document'),
              ),
            ],
          ),
          if (docs.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.s24),
              margin: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  "No documents added yet. Tap 'Add Document' to include a record.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ...docs.asMap().entries.map((entry) {
            final i = entry.key;
            final m = Map<String, dynamic>.from(entry.value as Map);
            const sp = SizedBox(height: AppSpacing.s12);

            return _itemCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Document ${i + 1}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      GestureDetector(
                        onTap: () {
                          final updated = List<Map<String, dynamic>>.from(
                            docs.map(
                              (e) => Map<String, dynamic>.from(e as Map),
                            ),
                          );
                          updated.removeAt(i);
                          n.updateField('documents', updated);
                        },
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  AppSelect<String>(
                    value:
                        (m['documentCategory'] == null ||
                            m['documentCategory'].toString().isEmpty)
                        ? null
                        : m['documentCategory'] as String?,
                    label: 'Document Category *',
                    placeholder: 'Select',
                    items:
                        [
                              'Identity Proof',
                              'Address Proof',
                              'Educational',
                              'Experience',
                              'Other',
                            ]
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                    onChanged: (v) {
                      final updated = docs
                          .map((e) => Map<String, dynamic>.from(e as Map))
                          .toList();
                      updated[i]['documentCategory'] = v;
                      n.updateField('documents', updated);
                    },
                  ),
                  sp,
                  AppTextField(
                    label: 'Document Name *',
                    initialValue: m['documentName']?.toString(),
                    onChanged: (v) {
                      final updated = docs
                          .map((e) => Map<String, dynamic>.from(e as Map))
                          .toList();
                      updated[i]['documentName'] = v;
                      n.updateField('documents', updated);
                    },
                  ),
                  sp,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'File Upload *',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.s12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                m['fileName'] as String? ?? 'No file selected',
                                style: TextStyle(
                                  color: m['fileName'] != null
                                      ? Colors.green
                                      : Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => _pickFile(context, ref, docs, i),
                              child: const Text('Choose File'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  sp,
                  AppDatePicker(
                    label: 'Expiry Date',
                    initialDate:
                        m['expiryDate'] != null &&
                            m['expiryDate'].toString().isNotEmpty
                        ? DateTime.tryParse(m['expiryDate'].toString())
                        : null,
                    onChanged: (v) {
                      if (v != null) {
                        final updated = docs
                            .map((e) => Map<String, dynamic>.from(e as Map))
                            .toList();
                        updated[i]['expiryDate'] = _fmtDate(v);
                        n.updateField('documents', updated);
                      }
                    },
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: AppSpacing.s24),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 10 – Position Change  (matches PositionChangeTab.tsx)
// ─────────────────────────────────────────────────────────────────────────────
class PositionChangeStep extends ConsumerWidget {
  const PositionChangeStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = ref.read(employeeFormProvider.notifier);
    final d = ref.watch(employeeFormProvider).formData;
    const sp = SizedBox(height: AppSpacing.s16);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Position Change'),
          AppSelect<String>(
            value: d['positionChangeType'] as String?,
            label: 'Change Type',
            placeholder: 'Select',
            items: [
              'Promotion',
              'Transfer',
              'Demotion',
              'Lateral Move',
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => n.updateField('positionChangeType', v),
          ),
          sp,
          AppDatePicker(
            label: 'Effective Date',
            initialDate: _parseDate(d, 'positionChangeEffectiveDate'),
            onChanged: (v) {
              if (v != null) {
                n.updateField('positionChangeEffectiveDate', _fmtDate(v));
              }
            },
          ),
          sp,
          AppTextField(
            label: 'New Department',
            initialValue: d['positionChangeDepartmentId']?.toString(),
            onChanged: (v) => n.updateField('positionChangeDepartmentId', v),
          ),
          sp,
          AppTextField(
            label: 'New Designation',
            initialValue: d['positionChangeDesignationId']?.toString(),
            onChanged: (v) => n.updateField('positionChangeDesignationId', v),
          ),
          sp,
          AppTextField(
            label: 'New Grade',
            initialValue: d['positionChangeGrade']?.toString(),
            onChanged: (v) => n.updateField('positionChangeGrade', v),
          ),
          sp,
          AppTextField(
            label: 'New Location',
            initialValue: d['positionChangeLocation']?.toString(),
            onChanged: (v) => n.updateField('positionChangeLocation', v),
          ),
          sp,
          AppTextField(
            label: 'New Reporting Manager',
            initialValue: d['positionChangeReportingManagerId']?.toString(),
            onChanged: (v) =>
                n.updateField('positionChangeReportingManagerId', v),
          ),
          sp,
          AppTextField(
            label: 'Remarks',
            initialValue: d['positionChangeRemarks']?.toString(),
            maxLines: 3,
            onChanged: (v) => n.updateField('positionChangeRemarks', v),
          ),
          const SizedBox(height: AppSpacing.s24),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 11 – Salary Revision  (matches SalaryRevisionTab.tsx)
// ─────────────────────────────────────────────────────────────────────────────
class SalaryRevisionStep extends ConsumerWidget {
  const SalaryRevisionStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = ref.read(employeeFormProvider.notifier);
    final d = ref.watch(employeeFormProvider).formData;
    const sp = SizedBox(height: AppSpacing.s16);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Salary Revision'),
          AppSelect<String>(
            value: d['revisionType'] as String?,
            label: 'Revision Type',
            placeholder: 'Select',
            items: [
              'Annual Increment',
              'Promotion',
              'Market Correction',
              'Special',
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => n.updateField('revisionType', v),
          ),
          sp,
          AppDatePicker(
            label: 'Effective Date',
            initialDate: _parseDate(d, 'revisionEffectiveDate'),
            onChanged: (v) {
              if (v != null) {
                n.updateField('revisionEffectiveDate', _fmtDate(v));
              }
            },
          ),
          sp,
          AppTextField(
            label: 'Annual CTC',
            initialValue: d['revisionAnnualCTC']?.toString(),
            keyboardType: TextInputType.number,
            onChanged: (v) => n.updateField('revisionAnnualCTC', v),
          ),
          sp,
          AppTextField(
            label: 'Increment %',
            initialValue: d['revisionIncrementPercentage']?.toString(),
            keyboardType: TextInputType.number,
            onChanged: (v) => n.updateField('revisionIncrementPercentage', v),
          ),
          sp,
          _sectionTitle('Pay Components'),
          _buildSalaryComponentsList(context, ref),
          sp,
          AppTextField(
            label: 'Reason',
            initialValue: d['revisionReason']?.toString(),
            onChanged: (v) => n.updateField('revisionReason', v),
          ),
          const SizedBox(height: AppSpacing.s24),
        ],
      ),
    );
  }

  Widget _buildSalaryComponentsList(BuildContext context, WidgetRef ref) {
    final n = ref.read(employeeFormProvider.notifier);
    final d = ref.watch(employeeFormProvider).formData;
    
    // Initialize list if null
    List<dynamic> components = [];
    if (d['revisionSalaryComponents'] is List) {
      components = List.from(d['revisionSalaryComponents']);
    }

    final ctc = double.tryParse(d['revisionAnnualCTC']?.toString() ?? '0') ?? 0;
    double totalEarnings = 0;
    for (var c in components) {
      if (c['type'] == 'EARNING') {
        final a = double.tryParse(c['amount']?.toString() ?? '0') ?? 0;
        if (a > 0) {
          totalEarnings += a;
        } else {
          final p = double.tryParse(c['percentage']?.toString() ?? '0') ?? 0;
          totalEarnings += (ctc * p / 100);
        }
      }
    }
    final bool exceedsCtc = ctc > 0 && totalEarnings > ctc;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (exceedsCtc)
          Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(4)),
            child: const Row(
              children: [
                Icon(Icons.warning, color: Colors.red, size: 16),
                SizedBox(width: 8),
                Expanded(child: Text('Total earnings cannot exceed Annual CTC', style: TextStyle(color: Colors.red, fontSize: 13))),
              ],
            ),
          ),
        if (components.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text('No components added.', style: TextStyle(color: Colors.grey, fontSize: 13)),
          ),
        ...List.generate(components.length, (index) {
          final comp = components[index] as Map<String, dynamic>;
          return _itemCard(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Component ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        components.removeAt(index);
                        n.updateField('revisionSalaryComponents', components);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                AppTextField(
                  label: 'Component Name (e.g. Basic, HRA)',
                  initialValue: comp['componentName']?.toString(),
                  onChanged: (v) {
                    components[index]['componentName'] = v;
                    n.updateField('revisionSalaryComponents', components);
                  },
                ),
                const SizedBox(height: 8),
                AppSelect<String>(
                  value: comp['type'] as String? ?? 'EARNING',
                  label: 'Type',
                  placeholder: 'Select Type',
                  items: const [
                    DropdownMenuItem(value: 'EARNING', child: Text('Earning')),
                    DropdownMenuItem(value: 'DEDUCTION', child: Text('Deduction')),
                    DropdownMenuItem(value: 'REIMBURSEMENT', child: Text('Reimbursement')),
                  ],
                  onChanged: (v) {
                    components[index]['type'] = v;
                    n.updateField('revisionSalaryComponents', components);
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        key: ValueKey('pct_${index}_${comp['percentage']}'),
                        label: 'Percentage (%)',
                        initialValue: comp['percentage']?.toString(),
                        keyboardType: TextInputType.number,
                        onChanged: (v) {
                          components[index]['percentage'] = v;
                          final ctc = double.tryParse(d['revisionAnnualCTC']?.toString() ?? '0') ?? 0;
                          final p = double.tryParse(v) ?? 0;
                          if (ctc > 0 && v.isNotEmpty) {
                            components[index]['amount'] = (ctc * p / 100).toStringAsFixed(2);
                          } else if (v.isEmpty) {
                            components[index]['amount'] = '';
                          }
                          n.updateField('revisionSalaryComponents', components);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppTextField(
                        key: ValueKey('amt_${index}_${comp['amount']}'),
                        label: 'Amount (Fixed)',
                        initialValue: comp['amount']?.toString(),
                        keyboardType: TextInputType.number,
                        onChanged: (v) {
                          components[index]['amount'] = v;
                          final ctc = double.tryParse(d['revisionAnnualCTC']?.toString() ?? '0') ?? 0;
                          final a = double.tryParse(v) ?? 0;
                          if (ctc > 0 && v.isNotEmpty) {
                            components[index]['percentage'] = (a / ctc * 100).toStringAsFixed(2);
                          } else if (v.isEmpty) {
                            components[index]['percentage'] = '';
                          }
                          n.updateField('revisionSalaryComponents', components);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () {
            components.add({'componentName': '', 'type': 'EARNING', 'percentage': '', 'amount': ''});
            n.updateField('revisionSalaryComponents', components);
          },
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Add Component'),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 12 – Separation & Exit  (matches SeparationExitTab.tsx)
// ─────────────────────────────────────────────────────────────────────────────
class SeparationExitStep extends ConsumerWidget {
  const SeparationExitStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = ref.read(employeeFormProvider.notifier);
    final d = ref.watch(employeeFormProvider).formData;
    const sp = SizedBox(height: AppSpacing.s16);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Separation & Exit'),
          AppSelect<String>(
            value: d['separationType'] as String?,
            label: 'Separation Type',
            placeholder: 'Select',
            items: [
              'Resignation',
              'Termination',
              'Retirement',
              'Absconding',
              'End of Contract',
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => n.updateField('separationType', v),
          ),
          sp,
          AppDatePicker(
            label: 'Resignation Date',
            initialDate: _parseDate(d, 'resignationDate'),
            onChanged: (v) {
              if (v != null) n.updateField('resignationDate', _fmtDate(v));
            },
          ),
          sp,
          AppDatePicker(
            label: 'Last Working Date',
            initialDate: _parseDate(d, 'lastWorkingDate'),
            onChanged: (v) {
              if (v != null) n.updateField('lastWorkingDate', _fmtDate(v));
            },
          ),
          sp,
          AppTextField(
            label: 'Notice Period (Days)',
            initialValue: d['exitNoticePeriod']?.toString(),
            keyboardType: TextInputType.number,
            onChanged: (v) => n.updateField('exitNoticePeriod', v),
          ),
          sp,
          AppTextField(
            label: 'Separation Reason',
            initialValue: d['separationReason']?.toString(),
            onChanged: (v) => n.updateField('separationReason', v),
          ),
          sp,
          AppTextField(
            label: 'Remarks',
            initialValue: d['separationRemarks']?.toString(),
            maxLines: 3,
            onChanged: (v) => n.updateField('separationRemarks', v),
          ),
          sp,
          _appCheckTile(
            label: 'Exit Interview Done',
            value: d['exitInterview'] == true,
            onChanged: (val) => n.updateField('exitInterview', val),
          ),
          const SizedBox(height: AppSpacing.s24),
        ],
      ),
    );
  }
}
