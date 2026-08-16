import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/attendance_dashboard_models.dart';
import '../../data/repositories/attendance_repository.dart';

import '../../../authentication/presentation/auth_controller.dart';

class AttendanceDashboardState {
  final DashboardKPIs kpis;
  final List<TodayAttendanceSummary> myAttendance;
  final List<TodayAttendanceSummary> workforceAttendance;
  final List<LeaveRequestSummary> pendingLeaves;

  const AttendanceDashboardState({
    required this.kpis,
    required this.myAttendance,
    required this.workforceAttendance,
    required this.pendingLeaves,
  });
}

final attendanceDashboardProvider = FutureProvider<AttendanceDashboardState>((ref) async {
  final repo = ref.read(attendanceRepositoryProvider);
  final user = ref.watch(authControllerProvider).user;
  
  final isManagerOrHR = user?.hasRole('ROLE_SUPER_ADMIN') == true || 
                        user?.hasRole('ROLE_HR') == true || 
                        user?.hasRole('ROLE_COMPANY_ADMIN') == true || 
                        user?.hasRole('ROLE_MANAGER') == true;

  final myAttendance = await repo.getTodayAttendance(employeeId: user?.employeeId);

  if (isManagerOrHR) {
    final kpis = await repo.getDashboardKPIs();
    final workforceAttendance = await repo.getTodayAttendance();
    final pendingLeaves = await repo.getPendingLeaves();

    return AttendanceDashboardState(
      kpis: kpis,
      myAttendance: myAttendance,
      workforceAttendance: workforceAttendance,
      pendingLeaves: pendingLeaves,
    );
  } else {
    // Standard employee: fetch only their own today's attendance
    return AttendanceDashboardState(
      kpis: const DashboardKPIs(
        present: 0, 
        absent: 0, 
        lateArrivals: 0, 
        onLeave: 0,
        pendingLeaveRequests: 0,
        regularizationRequests: 0,
      ),
      myAttendance: myAttendance,
      workforceAttendance: [],
      pendingLeaves: [],
    );
  }
});
