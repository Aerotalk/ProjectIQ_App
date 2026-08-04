import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    ref.onDispose(() {
      _timer?.cancel();
    });
    return const AttendanceClockState();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.checkInTime != null) {
        state = state.copyWith(
          elapsed: DateTime.now().difference(state.checkInTime!),
        );
      }
    });
  }

  Future<void> checkIn() async {
    state = state.copyWith(isLoading: true, error: null);
    
    // Simulate API Call
    await Future.delayed(const Duration(seconds: 1));
    
    final now = DateTime.now();
    state = state.copyWith(
      status: ClockStatus.checkedIn,
      checkInTime: now,
      elapsed: Duration.zero,
      isLoading: false,
    );
    _startTimer();
  }

  Future<void> checkOut() async {
    state = state.copyWith(isLoading: true, error: null);
    
    // Simulate API Call
    await Future.delayed(const Duration(seconds: 1));
    
    _timer?.cancel();
    final now = DateTime.now();
    state = state.copyWith(
      status: ClockStatus.checkedOut,
      checkOutTime: now,
      isLoading: false,
    );
  }
}

final attendanceClockProvider =
    NotifierProvider<AttendanceClockNotifier, AttendanceClockState>(
  AttendanceClockNotifier.new,
);
