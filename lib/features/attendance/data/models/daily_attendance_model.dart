class DailyAttendanceModel {
  final String id;
  final String employeeName;
  final String employeeCode;
  final String department;
  final String shiftName;
  final String checkIn;
  final String checkOut;
  final String workingHours;
  final String status; // Present, Absent, Leave, Half Day
  final String? exceptionType; // e.g. Late In, Early Out
  final bool isRegularized;

  DailyAttendanceModel({
    required this.id,
    required this.employeeName,
    required this.employeeCode,
    required this.department,
    required this.shiftName,
    required this.checkIn,
    required this.checkOut,
    required this.workingHours,
    required this.status,
    this.exceptionType,
    this.isRegularized = false,
  });

  factory DailyAttendanceModel.fromJson(Map<String, dynamic> json) {
    return DailyAttendanceModel(
      id: json['id'] as String,
      employeeName: json['employeeName'] as String,
      employeeCode: json['employeeCode'] as String,
      department: json['department'] as String,
      shiftName: json['shiftName'] as String,
      checkIn: json['checkIn'] as String,
      checkOut: json['checkOut'] as String,
      workingHours: json['workingHours'] as String,
      status: json['status'] as String,
      exceptionType: json['exceptionType'] as String?,
      isRegularized: json['isRegularized'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeName': employeeName,
      'employeeCode': employeeCode,
      'department': department,
      'shiftName': shiftName,
      'checkIn': checkIn,
      'checkOut': checkOut,
      'workingHours': workingHours,
      'status': status,
      'exceptionType': exceptionType,
      'isRegularized': isRegularized,
    };
  }
}
