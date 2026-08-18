class DashboardKPIs {
  final int present;
  final int absent;
  final int lateArrivals;
  final int onLeave;
  final int pendingLeaveRequests;
  final int regularizationRequests;
  final int missingSwipes;
  final List<Map<String, dynamic>> upcomingHolidays;

  const DashboardKPIs({
    required this.present,
    required this.absent,
    required this.lateArrivals,
    required this.onLeave,
    required this.pendingLeaveRequests,
    required this.regularizationRequests,
    this.missingSwipes = 0,
    this.upcomingHolidays = const [],
  });
}

class TodayAttendanceSummary {
  final String employeeName;
  final String shift;
  final String checkInTime;
  final String checkOutTime;
  final String status;

  const TodayAttendanceSummary({
    required this.employeeName,
    required this.shift,
    required this.checkInTime,
    required this.checkOutTime,
    required this.status,
  });
}

class LeaveRequestSummary {
  final String employeeName;
  final String leaveType;
  final int days;
  final String status;

  const LeaveRequestSummary({
    required this.employeeName,
    required this.leaveType,
    required this.days,
    required this.status,
  });
}
