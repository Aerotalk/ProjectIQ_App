import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import 'dart:convert';
import 'providers/employee_form_provider.dart';
import 'providers/employee_providers.dart';
import 'widgets/employee_form_steps/form_steps.dart';

class AddEmployeeScreen extends ConsumerStatefulWidget {
  const AddEmployeeScreen({super.key});

  @override
  ConsumerState<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends ConsumerState<AddEmployeeScreen> {
  late PageController _pageController;
  late ScrollController _tabScrollController;
  // Order matches frontend STEPS array in EmployeeDrawer/index.tsx
  final List<String> _stepTitles = [
    'Basic Info', // 0  basic
    'Address', // 1  address
    'Emergency', // 2  emergency
    'Statutory', // 3  statutory
    'Bank Details', // 4  bank
    'Documents', // 5  documents
    'Position', // 6  position
    'Separation', // 7  separation
    'Salary', // 8  salary
    'Education', // 9  education
    'Family', // 10 family
    'Contract', // 11 contract
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _tabScrollController = ScrollController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabScrollController.dispose();
    super.dispose();
  }

  void _submit() async {
    final state = ref.read(employeeFormProvider);
    final data = state.formData;

    final requiredKeys = {
      'firstName': 'First Name',
      'lastName': 'Last Name',
      'dateOfBirth': 'Date of Birth',
      'workEmail': 'Work Email',
      'phone': 'Phone',
      'alternatePhone': 'Alternate Phone',
      'gender': 'Gender',
      'maritalStatus': 'Marital Status',
      'bloodGroup': 'Blood Group',
      'nationality': 'Nationality',
      'dateOfJoining': 'Date of Joining',
      'employmentType': 'Employment Type',
      'companyId': 'Company / Legal Entity',
      'departmentId': 'Department',
      'designationId': 'Designation',
      'location': 'Location',
      'grade': 'Grade / Band',
      'reportingManagerId': 'Reporting Manager',
      'hrManagerId': 'HR Manager',
      'weeklyOff': 'Weekly Off',
      'noticePeriodDays': 'Notice Period (Days)'
    };

    for (final entry in requiredKeys.entries) {
      if (data[entry.key] == null || data[entry.key].toString().trim().isEmpty) {
        ref.read(employeeFormProvider.notifier).setError('${entry.value} is required (Basic Info)');
        return;
      }
    }

    // Validate CTC limit
    final ctcStr = data['revisionAnnualCTC']?.toString() ?? '';
    final ctc = double.tryParse(ctcStr) ?? 0;
    if (ctcStr.isNotEmpty && data['revisionSalaryComponents'] is List) {
      final components = data['revisionSalaryComponents'] as List;
      double totalEarnings = 0;
      for (final comp in components) {
        if (comp is Map) {
           final amount = double.tryParse(comp['amount']?.toString() ?? '0') ?? 0;
           totalEarnings += amount;
        }
      }
      if (totalEarnings > ctc + 0.01) {
        ref.read(employeeFormProvider.notifier).setError('Total earnings in salary components cannot exceed Annual CTC.');
        return;
      }
    }

    ref.read(employeeFormProvider.notifier).setLoading(true);

    try {
      final repo = ref.read(employeeRepositoryProvider);

      // 1. Create User
      final userPayload = {
        'username': data['workEmail'],
        'email': data['workEmail'],
        'mobile': data['phone'],
        'password': 'Password@123',
        'status': 'ACTIVE',
        'role': 'ROLE_EMPLOYEE',
        'companyId': data['companyId'],
      };
      final userRes = await repo.createUser(userPayload);

      // 2. Create Employee Profile
      final empPayload = {'userId': userRes['id'], ...data};
      final empRes = await repo.createEmployee(empPayload);
      final employeeId = empRes.id;

      // 3. Save Sub-Resources (in parallel as much as possible)
      
      // Salary needs special serialization for dynamic components
      dynamic rawComponents = data['revisionSalaryComponents'];
      String salaryComponentsStr = '';
      if (rawComponents is List) {
        salaryComponentsStr = jsonEncode(rawComponents);
      } else if (rawComponents != null) {
        salaryComponentsStr = rawComponents.toString();
      }

      await Future.wait([
        repo.saveAddress(employeeId, {
          'presentAddressLine1': data['presentAddressLine1'],
          'presentAddressLine2': data['presentAddressLine2'],
          'presentCity': data['presentCity'],
          'presentState': data['presentState'],
          'presentPinCode': data['presentPinCode'],
          'presentCountry': data['presentCountry'],
          'presentPhone': data['presentPhone'],
          'permanentAddressLine1': data['permanentAddressLine1'],
          'permanentAddressLine2': data['permanentAddressLine2'],
          'permanentCity': data['permanentCity'],
          'permanentState': data['permanentState'],
          'permanentPinCode': data['permanentPinCode'],
          'permanentCountry': data['permanentCountry'],
          'permanentPhone': data['permanentPhone'],
        }),
        repo.saveEmergencyContact(employeeId, {
          'name': data['emergencyContactName'],
          'relationship': data['emergencyRelationship'],
          'phone': data['emergencyPhone'],
          'alternatePhone': data['emergencyAlternatePhone'],
          'email': data['emergencyEmail'],
          'address': data['emergencyAddress'],
          'isPrimary': data['emergencyPrimaryContact'],
        }),
        repo.saveStatutory(employeeId, {
          'panNumber': data['panNumber'],
          'aadhaarNumber': data['aadhaarNumber'],
          'uan': data['uan'],
          'pfNumber': data['pfNumber'],
          'esiNumber': data['esiNumber'],
          'taxRegime': data['taxRegime'],
          'passportNumber': data['passportNumber'],
          'passportExpiry': data['passportExpiry'],
        }),
        repo.saveBankAccount(employeeId, {
          'bankName': data['bankName'],
          'branchName': data['branchName'],
          'accountNumber': data['accountNumber'],
          'ifscCode': data['ifscCode'],
          'accountType': data['accountType'],
          'accountHolderName': data['accountHolderName'],
          'paymentMode': data['paymentMode'],
          'isPrimary': data['primaryAccount'],
        }),
        repo.saveSalaryRevision(employeeId, {
          'revisionType': data['revisionType'],
          'effectiveDate': data['revisionEffectiveDate'],
          'annualCTC': data['revisionAnnualCTC'],
          'incrementPercentage': data['revisionIncrementPercentage'],
          'salaryComponents': salaryComponentsStr,
          'reason': data['revisionReason'],
        }),
        repo.saveContract(employeeId, {
          'contractType': data['contractType'],
          'startDate': data['contractStartDate'],
          'endDate': data['contractEndDate'],
          'annualCTC': data['contractAnnualCTC'],
          'noticePeriodDays': data['contractNoticePeriod'],
          'terms': data['contractTerms'],
        }),
        repo.savePositionChange(employeeId, {
          'type': data['positionChangeType'],
          'effectiveDate': data['positionChangeEffectiveDate'],
          'departmentId': data['positionChangeDepartmentId'],
          'designationId': data['positionChangeDesignationId'],
          'grade': data['positionChangeGrade'],
          'location': data['positionChangeLocation'],
          'reportingManagerId': data['positionChangeReportingManagerId'],
          'remarks': data['positionChangeRemarks'],
        }),
        repo.saveSeparation(employeeId, {
          'type': data['separationType'],
          'resignationDate': data['resignationDate'],
          'lastWorkingDate': data['lastWorkingDate'],
          'noticePeriod': data['exitNoticePeriod'],
          'reason': data['separationReason'],
          'exitInterviewDone': data['exitInterview'],
          'remarks': data['separationRemarks'],
        }),
      ]);

      ref.invalidate(employeeListProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Employee created successfully')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ref
            .read(employeeFormProvider.notifier)
            .setError('Failed to create employee: $e');
      }
    } finally {
      if (mounted) {
        ref.read(employeeFormProvider.notifier).setLoading(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formState = ref.watch(employeeFormProvider);
    final formNotifier = ref.read(employeeFormProvider.notifier);

    // Sync PageView with state
    if (_pageController.hasClients &&
        _pageController.page?.round() != formState.currentStep) {
      _pageController.animateToPage(
        formState.currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Employee',
          style: AppTypography.title.copyWith(fontWeight: FontWeight.w700),
        ),
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Error Banner
          if (formState.error != null)
            Container(
              padding: const EdgeInsets.all(AppSpacing.s12),
              color: AppColors.destructiveLight.withValues(
                alpha: isDark ? 0.2 : 0.1,
              ),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.alertCircle,
                    color: AppColors.destructiveLight,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  Expanded(
                    child: Text(
                      formState.error!,
                      style: const TextStyle(color: AppColors.destructiveLight),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 16),
                    onPressed: () => formNotifier.setError(null),
                  ),
                ],
              ),
            ),

          // Tab Header
          Container(
            height: 50,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
            ),
            child: ListView.builder(
              controller: _tabScrollController,
              scrollDirection: Axis.horizontal,
              itemCount: _stepTitles.length,
              itemBuilder: (context, index) {
                final isActive = formState.currentStep == index;
                // Auto scroll to active tab
                if (isActive && _tabScrollController.hasClients) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    final target = index * 100.0; // Approximation of tab width
                    final maxScroll =
                        _tabScrollController.position.maxScrollExtent;
                    final scrollOffset = target.clamp(0.0, maxScroll);
                    _tabScrollController.animateTo(
                      scrollOffset,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  });
                }

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => formNotifier.setStep(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s16,
                    ),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isActive
                              ? AppColors.primaryLight
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      _stepTitles[index],
                      style: TextStyle(
                        fontWeight: isActive
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isActive
                            ? (isDark ? Colors.white : Colors.black)
                            : (isDark
                                  ? AppColors.mutedForegroundDark
                                  : AppColors.mutedForegroundLight),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Form Pages
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: formNotifier.setStep,
              children: const [
                BasicInfoStep(), // 0  basic
                ContactInfoStep(), // 1  address
                EmergencyContactStep(), // 2  emergency
                StatutoryDetailsStep(), // 3  statutory
                BankDetailsStep(), // 4  bank
                DocumentsStep(), // 5  documents
                PositionChangeStep(), // 6  position
                SeparationExitStep(), // 7  separation
                SalaryRevisionStep(), // 8  salary
                EducationStep(), // 9  education
                FamilyNomineeStep(), // 10 family
                EmploymentContractStep(), // 11 contract
              ],
            ),
          ),

          // Navigation Footer
          Container(
            padding: const EdgeInsets.all(AppSpacing.s16),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.backgroundDark
                  : AppColors.backgroundLight,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: formState.currentStep > 0
                      ? formNotifier.previousStep
                      : null,
                  child: const Text('Previous'),
                ),
                ElevatedButton(
                  onPressed: formState.isLoading
                      ? null
                      : (formState.currentStep < _stepTitles.length - 1
                            ? formNotifier.nextStep
                            : _submit),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    foregroundColor: Colors.white,
                  ),
                  child:
                      formState.isLoading &&
                          formState.currentStep == _stepTitles.length - 1
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          formState.currentStep < _stepTitles.length - 1
                              ? 'Save & Next'
                              : 'Submit',
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
