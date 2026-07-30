import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/leave_model.dart';
import '../../data/repositories/attendance_repository.dart';

final leaveListProvider = AsyncNotifierProvider<LeaveListNotifier, List<LeaveModel>>(() {
  return LeaveListNotifier();
});

class LeaveListNotifier extends AsyncNotifier<List<LeaveModel>> {
  @override
  Future<List<LeaveModel>> build() async {
    return ref.read(attendanceRepositoryProvider).getLeaves();
  }

  void addLeaveLocally(LeaveModel model) {
    if (state.hasValue) {
      state = AsyncData([...state.value!, model]);
    }
  }
}

final submitLeaveProvider = NotifierProvider<SubmitLeaveNotifier, AsyncValue<void>>(() {
  return SubmitLeaveNotifier();
});

class SubmitLeaveNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> submit(LeaveModel model) async {
    state = const AsyncLoading();
    try {
      final created = await ref.read(attendanceRepositoryProvider).submitLeave(model);
      ref.read(leaveListProvider.notifier).addLeaveLocally(created);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
