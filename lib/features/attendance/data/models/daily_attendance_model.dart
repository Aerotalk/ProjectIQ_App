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
  final String? checkInLocation;
  final String? checkOutLocation;
  final double? checkInLat;
  final double? checkInLng;
  final double? checkOutLat;
  final double? checkOutLng;

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
    this.checkInLocation,
    this.checkOutLocation,
    this.checkInLat,
    this.checkInLng,
    this.checkOutLat,
    this.checkOutLng,
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
      checkInLocation: json['checkInLocation'] as String?,
      checkOutLocation: json['checkOutLocation'] as String?,
      checkInLat: json['checkInLat'] as double?,
      checkInLng: json['checkInLng'] as double?,
      checkOutLat: json['checkOutLat'] as double?,
      checkOutLng: json['checkOutLng'] as double?,
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
      'checkInLocation': checkInLocation,
      'checkOutLocation': checkOutLocation,
      'checkInLat': checkInLat,
      'checkInLng': checkInLng,
      'checkOutLat': checkOutLat,
      'checkOutLng': checkOutLng,
    };
  }
}
