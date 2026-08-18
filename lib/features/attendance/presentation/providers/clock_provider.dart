import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../authentication/presentation/auth_controller.dart';
import '../../data/repositories/attendance_repository.dart';
import '../../../../core/utils/location_service.dart';
import 'attendance_dashboard_providers.dart';

enum ClockStatus { notCheckedIn, checkedIn, checkedOut }

class AttendanceClockState {
  final ClockStatus status;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final Duration elapsed;
  final Duration accumulatedElapsed;
  final bool isLoading;
  final String? error;
  final bool isSyncPending;

  const AttendanceClockState({
    this.status = ClockStatus.notCheckedIn,
    this.checkInTime,
    this.checkOutTime,
    this.elapsed = Duration.zero,
    this.accumulatedElapsed = Duration.zero,
    this.isLoading = false,
    this.error,
    this.isSyncPending = false,
  });

  AttendanceClockState copyWith({
    ClockStatus? status,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    Duration? elapsed,
    Duration? accumulatedElapsed,
    bool? isLoading,
    String? error,
    bool? isSyncPending,
  }) {
    return AttendanceClockState(
      status: status ?? this.status,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      elapsed: elapsed ?? this.elapsed,
      accumulatedElapsed: accumulatedElapsed ?? this.accumulatedElapsed,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSyncPending: isSyncPending ?? this.isSyncPending,
    );
  }
}

class AttendanceClockNotifier extends Notifier<AttendanceClockState> {
  Timer? _timer;
  StreamSubscription? _connectivitySubscription;

  @override
  AttendanceClockState build() {
    ref.onDispose(() {
      _timer?.cancel();
      _connectivitySubscription?.cancel();
    });
    
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        _syncOfflinePunches();
      }
    });

    _restoreStateFromServer(); // fire-and-forget on build
    return const AttendanceClockState(isLoading: true);
  }

  Future<void> _restoreStateFromServer() async {
    final user = ref.read(authControllerProvider).user;
    if (user?.employeeId == null) {
      state = const AttendanceClockState();
      return;
    }
    
    await _syncOfflinePunches();

    final repo = ref.read(attendanceRepositoryProvider);
    final status = await repo.getCheckInStatus(user!.employeeId!);

    final bool currentlyIn = status['currentlyCheckedIn'] == true;
    final DateTime? lastPunchTime = status['lastPunchTime'] != null
        ? DateTime.tryParse(status['lastPunchTime'].toString())
        : null;
        
    final double workingHours = double.tryParse(status['workingHours']?.toString() ?? '0') ?? 0.0;
    final Duration accumulated = Duration(seconds: (workingHours * 3600).toInt());

    final prefs = await SharedPreferences.getInstance();
    final String? offlineData = prefs.getString('offline_punches');
    final bool hasPending = offlineData != null && jsonDecode(offlineData).isNotEmpty;

    state = AttendanceClockState(
      status: currentlyIn ? ClockStatus.checkedIn : ClockStatus.notCheckedIn,
      checkInTime: currentlyIn ? lastPunchTime : null,
      elapsed: currentlyIn && lastPunchTime != null ? accumulated + DateTime.now().difference(lastPunchTime) : accumulated,
      accumulatedElapsed: accumulated,
      isLoading: false,
      isSyncPending: hasPending,
    );
    if (currentlyIn) _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.checkInTime != null) {
        state = state.copyWith(
            elapsed: state.accumulatedElapsed + DateTime.now().difference(state.checkInTime!));
      }
    });
  }

  Future<void> checkIn() async {
    final user = ref.read(authControllerProvider).user;
    if (user == null || user.employeeId == null) {
      state = state.copyWith(error: 'No employee profile linked to your account.', isLoading: false);
      return;
    }
    
    final effectiveEmployeeId = user.employeeId!;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final locResult = await LocationService.getSecureLocation();
      if (locResult.isMocked) throw Exception(locResult.error);

      final repo = ref.read(attendanceRepositoryProvider);
      final now = DateTime.now();

      try {
        await repo.checkIn(
          effectiveEmployeeId,
          lat: locResult.position?.latitude,
          lng: locResult.position?.longitude,
          locationLabel: locResult.locationLabel,
        );
      } on Exception catch (e) {
        bool isNetworkError = true;
        if (e.runtimeType.toString() == 'DioException') {
          final dioError = e as dynamic;
          if (dioError.response != null && dioError.response.statusCode >= 400 && dioError.response.statusCode < 500) {
            isNetworkError = false;
            throw Exception(dioError.response.data['message'] ?? dioError.response.data['error'] ?? 'API Error ${dioError.response.statusCode}');
          }
        }
        if (isNetworkError) {
          // Cache offline
          await _cachePunchOffline({
            'type': 'In',
            'employeeId': effectiveEmployeeId,
            'lat': locResult.position?.latitude,
            'lng': locResult.position?.longitude,
            'locationLabel': locResult.locationLabel,
            'timestamp': now.toIso8601String(),
          });
        }
      }

      state = state.copyWith(
        status: ClockStatus.checkedIn,
        checkInTime: now,
        elapsed: state.accumulatedElapsed,
        isLoading: false,
        isSyncPending: await _hasOfflinePunches(),
      );
      _startTimer();
      ref.invalidate(attendanceDashboardProvider);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> checkOut() async {
    final user = ref.read(authControllerProvider).user;
    if (user == null || user.employeeId == null) {
      state = state.copyWith(error: 'No employee profile linked to your account.', isLoading: false);
      return;
    }

    final effectiveEmployeeId = user.employeeId!;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final locResult = await LocationService.getSecureLocation();
      if (locResult.isMocked) throw Exception(locResult.error);

      final repo = ref.read(attendanceRepositoryProvider);
      
      try {
        await repo.checkOut(
          effectiveEmployeeId,
          lat: locResult.position?.latitude,
          lng: locResult.position?.longitude,
          locationLabel: locResult.locationLabel,
        );
      } on Exception catch (e) {
        bool isNetworkError = true;
        if (e.runtimeType.toString() == 'DioException') {
          final dioError = e as dynamic;
          if (dioError.response != null && dioError.response.statusCode >= 400 && dioError.response.statusCode < 500) {
            isNetworkError = false;
            throw Exception(dioError.response.data['message'] ?? dioError.response.data['error'] ?? 'API Error ${dioError.response.statusCode}');
          }
        }
        if (isNetworkError) {
          // Cache offline
          await _cachePunchOffline({
            'type': 'Out',
            'employeeId': effectiveEmployeeId,
            'lat': locResult.position?.latitude,
            'lng': locResult.position?.longitude,
            'locationLabel': locResult.locationLabel,
            'timestamp': DateTime.now().toIso8601String(),
          });
        }
      }

      _timer?.cancel();
      state = state.copyWith(
        status: ClockStatus.checkedOut,
        checkOutTime: DateTime.now(),
        accumulatedElapsed: state.elapsed,
        isLoading: false,
        isSyncPending: await _hasOfflinePunches(),
      );
      ref.invalidate(attendanceDashboardProvider);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> _cachePunchOffline(Map<String, dynamic> punch) async {
    final prefs = await SharedPreferences.getInstance();
    final String? offlineData = prefs.getString('offline_punches');
    List<dynamic> punches = offlineData != null ? jsonDecode(offlineData) : [];
    punches.add(punch);
    await prefs.setString('offline_punches', jsonEncode(punches));
  }

  Future<bool> _hasOfflinePunches() async {
    final prefs = await SharedPreferences.getInstance();
    final String? offlineData = prefs.getString('offline_punches');
    return offlineData != null && jsonDecode(offlineData).isNotEmpty;
  }

  Future<void> _syncOfflinePunches() async {
    final prefs = await SharedPreferences.getInstance();
    final String? offlineData = prefs.getString('offline_punches');
    if (offlineData != null) {
      final List<dynamic> punches = jsonDecode(offlineData);
      if (punches.isEmpty) return;
      
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) return;

      final repo = ref.read(attendanceRepositoryProvider);
      List<dynamic> failedPunches = [];
      
      for (var p in punches) {
        try {
          if (p['type'] == 'In') {
             await repo.checkIn(
               p['employeeId'], 
               lat: p['lat'], 
               lng: p['lng'], 
               locationLabel: p['locationLabel']
             );
          } else {
             await repo.checkOut(
               p['employeeId'], 
               lat: p['lat'], 
               lng: p['lng'], 
               locationLabel: p['locationLabel']
             );
          }
        } catch (e) {
          failedPunches.add(p);
        }
      }
      
      if (failedPunches.isEmpty) {
        await prefs.remove('offline_punches');
        if (state.isSyncPending) {
          state = state.copyWith(isSyncPending: false);
          ref.invalidate(attendanceDashboardProvider);
        }
      } else {
        await prefs.setString('offline_punches', jsonEncode(failedPunches));
        if (!state.isSyncPending) {
          state = state.copyWith(isSyncPending: true);
        }
      }
    }
  }
}

final attendanceClockProvider = NotifierProvider<AttendanceClockNotifier, AttendanceClockState>(
  AttendanceClockNotifier.new,
);
