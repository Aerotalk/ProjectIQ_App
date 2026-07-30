import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
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

    // Basic validation
    if (data['workEmail'] == null || data['workEmail'].toString().isEmpty) {
      ref
          .read(employeeFormProvider.notifier)
          .setError('Work Email is required (Basic Info)');
      return;
    }
    if (data['phone'] == null || data['phone'].toString().isEmpty) {
      ref
          .read(employeeFormProvider.notifier)
          .setError('Phone is required (Basic Info)');
      return;
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
      await repo.createEmployee(empPayload);

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
