import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/shift_model.dart';
import '../../data/repositories/attendance_repository.dart';

final shiftListProvider = AsyncNotifierProvider<ShiftListNotifier, List<ShiftModel>>(() {
  return ShiftListNotifier();
});

class ShiftListNotifier extends AsyncNotifier<List<ShiftModel>> {
  @override
  Future<List<ShiftModel>> build() async {
    return ref.read(attendanceRepositoryProvider).getShifts();
  }

  void addShiftLocally(ShiftModel model) {
    if (state.hasValue) {
      state = AsyncData([...state.value!, model]);
    }
  }
}

final submitShiftProvider = NotifierProvider<SubmitShiftNotifier, AsyncValue<void>>(() {
  return SubmitShiftNotifier();
});

class SubmitShiftNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> submit(ShiftModel model) async {
    state = const AsyncLoading();
    try {
      final created = await ref.read(attendanceRepositoryProvider).submitShift(model);
      ref.read(shiftListProvider.notifier).addShiftLocally(created);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
