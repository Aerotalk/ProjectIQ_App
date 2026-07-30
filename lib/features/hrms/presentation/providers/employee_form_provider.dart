import 'package:flutter_riverpod/flutter_riverpod.dart';

class EmployeeFormState {
  final Map<String, dynamic> formData;
  final int currentStep;
  final bool isLoading;
  final String? error;

  EmployeeFormState({
    this.formData = const {},
    this.currentStep = 0,
    this.isLoading = false,
    this.error,
  });

  EmployeeFormState copyWith({
    Map<String, dynamic>? formData,
    int? currentStep,
    bool? isLoading,
    String? error,
  }) {
    return EmployeeFormState(
      formData: formData ?? this.formData,
      currentStep: currentStep ?? this.currentStep,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class EmployeeFormController extends Notifier<EmployeeFormState> {
  @override
  EmployeeFormState build() {
    return EmployeeFormState(
      formData: {
        'gender': 'Male',
        'employmentStatus': 'Active',
        'maritalStatus': 'Single',
        'bloodGroup': 'O+',
        'employmentType': 'Full Time',
      },
    );
  }

  void updateField(String key, dynamic value) {
    final newData = Map<String, dynamic>.from(state.formData);
    newData[key] = value;
    state = state.copyWith(formData: newData, error: null);
  }

  void nextStep() {
    if (state.currentStep < 11) {
      state = state.copyWith(currentStep: state.currentStep + 1, error: null);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1, error: null);
    }
  }

  void setStep(int step) {
    if (step >= 0 && step <= 11) {
      state = state.copyWith(currentStep: step, error: null);
    }
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  void reset() {
    state = build();
  }
}

final employeeFormProvider =
    NotifierProvider.autoDispose<EmployeeFormController, EmployeeFormState>(
      EmployeeFormController.new,
    );
