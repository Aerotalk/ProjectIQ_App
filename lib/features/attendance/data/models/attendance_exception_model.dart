class AttendanceExceptionModel {
  final String id;
  final String employeeName;
  final String employeeCode;
  final String date;
  final String exceptionType;
  final String severity; // High, Medium, Low
  final String description;
  final bool resolved;

  AttendanceExceptionModel({
    required this.id,
    required this.employeeName,
    required this.employeeCode,
    required this.date,
    required this.exceptionType,
    required this.severity,
    required this.description,
    required this.resolved,
  });

  factory AttendanceExceptionModel.fromJson(Map<String, dynamic> json) {
    return AttendanceExceptionModel(
      id: json['id'] as String,
      employeeName: json['employeeName'] as String,
      employeeCode: json['employeeCode'] as String,
      date: json['date'] as String,
      exceptionType: json['exceptionType'] as String,
      severity: json['severity'] as String,
      description: json['description'] as String,
      resolved: json['resolved'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeName': employeeName,
      'employeeCode': employeeCode,
      'date': date,
      'exceptionType': exceptionType,
      'severity': severity,
      'description': description,
      'resolved': resolved,
    };
  }
}
