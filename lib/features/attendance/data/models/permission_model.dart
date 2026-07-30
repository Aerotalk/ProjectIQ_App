class PermissionModel {
  final String id;
  final String permissionNumber;
  final String employeeName;
  final String department;
  final String permissionDate;
  final String permissionType;
  final String startTime;
  final String endTime;
  final String totalHours;
  final String reason;
  final String status;

  PermissionModel({
    required this.id,
    required this.permissionNumber,
    required this.employeeName,
    required this.department,
    required this.permissionDate,
    required this.permissionType,
    required this.startTime,
    required this.endTime,
    required this.totalHours,
    required this.reason,
    required this.status,
  });

  factory PermissionModel.fromJson(Map<String, dynamic> json) {
    return PermissionModel(
      id: json['id'] as String,
      permissionNumber: json['permissionNumber'] as String,
      employeeName: json['employeeName'] as String,
      department: json['department'] as String,
      permissionDate: json['permissionDate'] as String,
      permissionType: json['permissionType'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      totalHours: json['totalHours'] as String,
      reason: json['reason'] as String,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'permissionNumber': permissionNumber,
      'employeeName': employeeName,
      'department': department,
      'permissionDate': permissionDate,
      'permissionType': permissionType,
      'startTime': startTime,
      'endTime': endTime,
      'totalHours': totalHours,
      'reason': reason,
      'status': status,
    };
  }
}
