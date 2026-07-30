class AttendanceDayModel {
  final DateTime date;
  final String status; // Present, Absent, Leave, Holiday, Weekend
  final String? inTime;
  final String? outTime;
  final String? shiftCode;

  const AttendanceDayModel({
    required this.date,
    required this.status,
    this.inTime,
    this.outTime,
    this.shiftCode,
  });
}
