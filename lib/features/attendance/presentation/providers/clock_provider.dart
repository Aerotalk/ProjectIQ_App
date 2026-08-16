import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../authentication/presentation/auth_controller.dart';
import '../../data/repositories/attendance_repository.dart';
import '../../../../core/utils/location_service.dart';

enum ClockStatus { notCheckedIn, checkedIn, checkedOut }

class AttendanceClockState {
  final ClockStatus status;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final Duration elapsed;
  final bool isLoading;
  final String? error;

  const AttendanceClockState({
    this.status = ClockStatus.notCheckedIn,
    this.checkInTime,
    this.checkOutTime,
    this.elapsed = Duration.zero,
    this.isLoading = false,
    this.error,
  });

  AttendanceClockState copyWith({
    ClockStatus? status,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    Duration? elapsed,
    bool? isLoading,
    String? error,
  }) {
    return AttendanceClockState(
      status: status ?? this.status,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      elapsed: elapsed ?? this.elapsed,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AttendanceClockNotifier extends Notifier<AttendanceClockState> {
  Timer? _timer;

  @override
  AttendanceClockState build() {
    ref.onDispose(() => _timer?.cancel());
    _restoreStateFromServer(); // fire-and-forget on build
    return const AttendanceClockState(isLoading: true);
  }

  Future<void> _restoreStateFromServer() async {
    final user = ref.read(authControllerProvider).user;
    if (user?.employeeId == null) {
      state = const AttendanceClockState();
      return;
    }
    final repo = ref.read(attendanceRepositoryProvider);
    final status = await repo.getCheckInStatus(user!.employeeId!);

    final bool currentlyIn = status['currentlyCheckedIn'] == true;
    final DateTime? firstIn = status['firstCheckIn'] != null
        ? DateTime.tryParse(status['firstCheckIn'].toString())
        : null;

    state = AttendanceClockState(
      status: currentlyIn ? ClockStatus.checkedIn : ClockStatus.notCheckedIn,
      checkInTime: firstIn,
      elapsed: firstIn != null && currentlyIn
          ? DateTime.now().difference(firstIn)
          : Duration.zero,
      isLoading: false,
    );
    if (currentlyIn) _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.checkInTime != null) {
        state = state.copyWith(
            elapsed: DateTime.now().difference(state.checkInTime!));
      }
    });
  }

  Future<void> checkIn() async {
    final user = ref.read(authControllerProvider).user;
    if (user?.employeeId == null) {
      state = state.copyWith(
        isLoading: false,
        error: 'Employee profile not linked to your account. Please contact HR.',
      );
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      // 1. Capture GPS (best-effort, non-blocking on failure)
      final position = await LocationService.getCurrentPosition();
      final repo = ref.read(attendanceRepositoryProvider);

      // 2. Call API
      await repo.checkIn(
        user!.employeeId!,
        lat: position?.latitude,
        lng: position?.longitude,
      );

      final now = DateTime.now();
      final firstIn = state.checkInTime ?? now; // preserve first punch of day
      state = state.copyWith(
        status: ClockStatus.checkedIn,
        checkInTime: firstIn,
        elapsed: Duration.zero,
        isLoading: false,
      );
      _startTimer();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> checkOut() async {
    final user = ref.read(authControllerProvider).user;
    if (user?.employeeId == null) {
      state = state.copyWith(
        isLoading: false,
        error: 'Employee profile not linked to your account. Please contact HR.',
      );
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      // 1. Capture GPS
      final position = await LocationService.getCurrentPosition();
      final repo = ref.read(attendanceRepositoryProvider);

      // 2. Call API
      await repo.checkOut(
        user!.employeeId!,
        lat: position?.latitude,
        lng: position?.longitude,
      );

      _timer?.cancel();
      state = state.copyWith(
        status: ClockStatus.checkedOut,
        checkOutTime: DateTime.now(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final attendanceClockProvider =
    NotifierProvider<AttendanceClockNotifier, AttendanceClockState>(
  AttendanceClockNotifier.new,
);
