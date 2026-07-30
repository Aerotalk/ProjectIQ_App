import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/regularization_model.dart';
import '../../data/repositories/attendance_repository.dart';

final regularizationListProvider = AsyncNotifierProvider<RegularizationListNotifier, List<RegularizationModel>>(() {
  return RegularizationListNotifier();
});

class RegularizationListNotifier extends AsyncNotifier<List<RegularizationModel>> {
  @override
  Future<List<RegularizationModel>> build() async {
    return ref.read(attendanceRepositoryProvider).getRegularizations();
  }

  void addRegularizationLocally(RegularizationModel model) {
    if (state.hasValue) {
      state = AsyncData([...state.value!, model]);
    }
  }
}

final submitRegularizationProvider = NotifierProvider<SubmitRegularizationNotifier, AsyncValue<void>>(() {
  return SubmitRegularizationNotifier();
});

class SubmitRegularizationNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> submit(RegularizationModel model) async {
    state = const AsyncLoading();
    try {
      final created = await ref.read(attendanceRepositoryProvider).submitRegularization(model);
      ref.read(regularizationListProvider.notifier).addRegularizationLocally(created);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
