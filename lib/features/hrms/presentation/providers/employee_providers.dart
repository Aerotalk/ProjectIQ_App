import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/employee_repository.dart';
import '../../domain/employee.dart';

final employeeRepositoryProvider = Provider<EmployeeRepository>((ref) {
  return EmployeeRepository(ref.watch(dioProvider));
});

// Search and filter state
class EmployeeSearchQuery extends Notifier<String> {
  @override
  String build() => '';
  void updateState(String value) => state = value;
}
final employeeSearchQueryProvider = NotifierProvider<EmployeeSearchQuery, String>(EmployeeSearchQuery.new);

class EmployeeDepartmentFilter extends Notifier<String?> {
  @override
  String? build() => null;
  void updateState(String? value) => state = value;
}
final employeeDepartmentFilterProvider = NotifierProvider<EmployeeDepartmentFilter, String?>(EmployeeDepartmentFilter.new);

class EmployeeStatusFilter extends Notifier<String?> {
  @override
  String? build() => null;
  void updateState(String? value) => state = value;
}
final employeeStatusFilterProvider = NotifierProvider<EmployeeStatusFilter, String?>(EmployeeStatusFilter.new);
final employeeListProvider = FutureProvider.autoDispose<List<Employee>>((ref) async {
  final repo = ref.watch(employeeRepositoryProvider);
  final keyword = ref.watch(employeeSearchQueryProvider);
  final departmentId = ref.watch(employeeDepartmentFilterProvider);
  final status = ref.watch(employeeStatusFilterProvider);

  try {
    return await repo.getEmployees(
      keyword: keyword,
      departmentId: departmentId,
      status: status,
    );
  } catch (e) {
    // If it's a 400 or other API error, we can return empty list for now
    // The repository will log the actual response
    return [];
  }
});

final employeeDetailProvider = FutureProvider.family.autoDispose<Employee, String>((ref, id) async {
  final repo = ref.watch(employeeRepositoryProvider);
  return repo.getEmployeeById(id);
});
