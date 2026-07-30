import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/permission_model.dart';
import '../../data/repositories/attendance_repository.dart';

final permissionListProvider = AsyncNotifierProvider<PermissionListNotifier, List<PermissionModel>>(() {
  return PermissionListNotifier();
});

class PermissionListNotifier extends AsyncNotifier<List<PermissionModel>> {
  @override
  Future<List<PermissionModel>> build() async {
    return ref.read(attendanceRepositoryProvider).getPermissions();
  }

  void addPermissionLocally(PermissionModel model) {
    if (state.hasValue) {
      state = AsyncData([model, ...state.value!]);
    }
  }
}

final submitPermissionProvider = NotifierProvider<SubmitPermissionNotifier, AsyncValue<void>>(() {
  return SubmitPermissionNotifier();
});

class SubmitPermissionNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }

  Future<void> submit(PermissionModel model) async {
    state = const AsyncLoading();
    try {
      final saved = await ref.read(attendanceRepositoryProvider).submitPermission(model);
      ref.read(permissionListProvider.notifier).addPermissionLocally(saved);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
