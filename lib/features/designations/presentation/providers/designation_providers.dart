import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/designation_model.dart';
import '../../data/repositories/designation_repository.dart';
import '../../../authentication/presentation/auth_controller.dart';
import '../../../../core/network/api_client.dart';

final availableRolesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final dio = ref.read(dioProvider);
  final response = await dio.get('/admin/roles/available');
  final data = response.data as List;
  return data.map((e) => e as Map<String, dynamic>).toList();
});

final designationListProvider = AsyncNotifierProvider<DesignationListNotifier, List<DesignationModel>>(
  DesignationListNotifier.new,
);

class DesignationListNotifier extends AsyncNotifier<List<DesignationModel>> {
  @override
  Future<List<DesignationModel>> build() async {
    return _fetchDesignations();
  }

  Future<List<DesignationModel>> _fetchDesignations() async {
    final repo = ref.read(designationRepositoryProvider);
    final user = ref.read(authControllerProvider).user;
    return repo.getDesignations(companyId: user?.companyId);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final designations = await _fetchDesignations();
      state = AsyncValue.data(designations);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // Optimistic updates
  void addLocally(DesignationModel newDesig) {
    if (state.hasValue) {
      state = AsyncValue.data([...state.value!, newDesig]);
    }
  }

  void updateLocally(DesignationModel updatedDesig) {
    if (state.hasValue) {
      final list = state.value!.map((d) => d.id == updatedDesig.id ? updatedDesig : d).toList();
      state = AsyncValue.data(list);
    }
  }

  void deleteLocally(String id) {
    if (state.hasValue) {
      final list = state.value!.where((d) => d.id != id).toList();
      state = AsyncValue.data(list);
    }
  }
}

class DesignationActionState {
  final bool isLoading;
  final String? error;

  DesignationActionState({this.isLoading = false, this.error});
}

final designationActionProvider = NotifierProvider<DesignationActionNotifier, DesignationActionState>(
  DesignationActionNotifier.new,
);

class DesignationActionNotifier extends Notifier<DesignationActionState> {
  @override
  DesignationActionState build() {
    return DesignationActionState();
  }

  Future<void> createDesignation({
    required String designationCode,
    required String designationName,
    String? roleId,
    String? description,
  }) async {
    state = DesignationActionState(isLoading: true);
    try {
      final repo = ref.read(designationRepositoryProvider);
      final user = ref.read(authControllerProvider).user;
      
      final newDesig = await repo.createDesignation(
        designationCode: designationCode,
        designationName: designationName,
        roleId: roleId,
        description: description,
        companyId: user?.companyId,
      );

      ref.read(designationListProvider.notifier).addLocally(newDesig);
      state = DesignationActionState(isLoading: false);
    } catch (e) {
      state = DesignationActionState(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateDesignation({
    required String id,
    required String designationCode,
    required String designationName,
    String? roleId,
    String? description,
  }) async {
    state = DesignationActionState(isLoading: true);
    try {
      final repo = ref.read(designationRepositoryProvider);
      
      final updatedDesig = await repo.updateDesignation(
        id,
        designationCode: designationCode,
        designationName: designationName,
        roleId: roleId,
        description: description,
      );

      ref.read(designationListProvider.notifier).updateLocally(updatedDesig);
      state = DesignationActionState(isLoading: false);
    } catch (e) {
      state = DesignationActionState(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteDesignation(String id) async {
    state = DesignationActionState(isLoading: true);
    try {
      final repo = ref.read(designationRepositoryProvider);
      await repo.deleteDesignation(id);
      
      ref.read(designationListProvider.notifier).deleteLocally(id);
      state = DesignationActionState(isLoading: false);
    } catch (e) {
      state = DesignationActionState(isLoading: false, error: e.toString());
    }
  }
}
