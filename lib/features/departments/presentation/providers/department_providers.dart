import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/department_model.dart';
import '../../data/repositories/department_repository.dart';
import '../../../authentication/presentation/auth_controller.dart';

final departmentListProvider = AsyncNotifierProvider<DepartmentListNotifier, List<DepartmentModel>>(
  DepartmentListNotifier.new,
);

class DepartmentListNotifier extends AsyncNotifier<List<DepartmentModel>> {
  @override
  Future<List<DepartmentModel>> build() async {
    return _fetchDepartments();
  }

  Future<List<DepartmentModel>> _fetchDepartments() async {
    final repo = ref.read(departmentRepositoryProvider);
    final user = ref.read(authControllerProvider).user;
    // If the user is scoped to a company, pass it, otherwise null.
    // In our backend, passing null is fine if the user is org-admin.
    return repo.getDepartments(companyId: user?.companyId);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchDepartments());
  }

  Future<void> addDepartment(DepartmentModel newDept) async {
    if (state.value != null) {
      state = AsyncValue.data([...state.value!, newDept]);
    } else {
      await refresh();
    }
  }

  Future<void> updateDepartment(DepartmentModel updatedDept) async {
    if (state.value != null) {
      final list = state.value!.map((d) {
        return d.id == updatedDept.id ? updatedDept : d;
      }).toList();
      state = AsyncValue.data(list);
    }
  }

  Future<void> removeDepartmentLocally(String id) async {
    if (state.value != null) {
      state = AsyncValue.data(state.value!.where((d) => d.id != id).toList());
    }
  }
}

final departmentActionProvider = AsyncNotifierProvider<DepartmentActionNotifier, void>(
  DepartmentActionNotifier.new,
);

class DepartmentActionNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> createDepartment({
    required String departmentCode,
    required String departmentName,
    String? description,
    String? companyId,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(departmentRepositoryProvider);
      final newDept = await repo.createDepartment(
        departmentCode: departmentCode,
        departmentName: departmentName,
        description: description,
        companyId: companyId,
      );
      await ref.read(departmentListProvider.notifier).addDepartment(newDept);
    });
  }

  Future<void> updateDepartment({
    required String id,
    required String departmentCode,
    required String departmentName,
    String? description,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(departmentRepositoryProvider);
      final updatedDept = await repo.updateDepartment(
        id,
        departmentCode: departmentCode,
        departmentName: departmentName,
        description: description,
      );
      await ref.read(departmentListProvider.notifier).updateDepartment(updatedDept);
    });
  }

  Future<void> deleteDepartment(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(departmentRepositoryProvider);
      await repo.deleteDepartment(id);
      await ref.read(departmentListProvider.notifier).removeDepartmentLocally(id);
    });
  }
}
