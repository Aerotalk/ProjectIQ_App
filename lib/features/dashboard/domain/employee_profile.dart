class EmployeeProfile {
  final String id;
  final String employeeCode;
  final String firstName;
  final String lastName;
  final String? departmentName;
  final String? designationName;
  final String employmentStatus;

  const EmployeeProfile({
    required this.id,
    required this.employeeCode,
    required this.firstName,
    required this.lastName,
    this.departmentName,
    this.designationName,
    required this.employmentStatus,
  });

  factory EmployeeProfile.fromJson(Map<String, dynamic> json) {
    return EmployeeProfile(
      id: json['id'] ?? '',
      employeeCode: json['employeeCode'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      departmentName: json['department'] != null ? json['department']['departmentName'] : null,
      designationName: json['designation'] != null ? json['designation']['designationName'] : null,
      employmentStatus: json['employmentStatus'] ?? 'Unknown',
    );
  }

  String get fullName {
    if (firstName.isEmpty && lastName.isEmpty) return 'Unknown Employee';
    return '$firstName $lastName'.trim();
  }
}
