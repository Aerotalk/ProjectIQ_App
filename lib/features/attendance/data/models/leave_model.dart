class LeaveModel {
  final String id;
  final String leaveType;
  final String? employeeId;
  final String employeeName;
  final String startDate;
  final String endDate;
  final int durationDays;
  final String reason;
  final String status;

  const LeaveModel({
    required this.id,
    required this.leaveType,
    this.employeeId,
    required this.employeeName,
    required this.startDate,
    required this.endDate,
    required this.durationDays,
    required this.reason,
    required this.status,
  });

  LeaveModel copyWith({
    String? id,
    String? leaveType,
    String? employeeId,
    String? employeeName,
    String? startDate,
    String? endDate,
    int? durationDays,
    String? reason,
    String? status,
  }) {
    return LeaveModel(
      id: id ?? this.id,
      leaveType: leaveType ?? this.leaveType,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      durationDays: durationDays ?? this.durationDays,
      reason: reason ?? this.reason,
      status: status ?? this.status,
    );
  }
}
