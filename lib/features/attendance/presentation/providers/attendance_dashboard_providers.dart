import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/attendance_dashboard_models.dart';
import '../../data/repositories/attendance_repository.dart';

class AttendanceDashboardState {
  final DashboardKPIs kpis;
  final List<TodayAttendanceSummary> todayAttendance;
  final List<LeaveRequestSummary> pendingLeaves;

  const AttendanceDashboardState({
    required this.kpis,
    required this.todayAttendance,
    required this.pendingLeaves,
  });
}

final attendanceDashboardProvider = FutureProvider<AttendanceDashboardState>((ref) async {
  final repo = ref.read(attendanceRepositoryProvider);

  final kpis = await repo.getDashboardKPIs();
  final todayAttendance = await repo.getTodayAttendance();
  final pendingLeaves = await repo.getPendingLeaves();

  return AttendanceDashboardState(
    kpis: kpis,
    todayAttendance: todayAttendance,
    pendingLeaves: pendingLeaves,
  );
});
