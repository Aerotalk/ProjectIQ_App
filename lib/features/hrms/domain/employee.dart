class Employee {
  final String id;
  final String employeeCode;
  final String firstName;
  final String lastName;
  final String? departmentName;
  final String? designationName;
  final String? departmentId;
  final String? designationId;
  final String employmentStatus;
  final String? email;
  final String? profilePhotoId;
  final String? joiningDate;
  final String? reportingManagerName;
  final String? reportingManagerId;
  final String? gender;
  final String? dateOfBirth;

  const Employee({
    required this.id,
    required this.employeeCode,
    required this.firstName,
    required this.lastName,
    this.departmentName,
    this.designationName,
    this.departmentId,
    this.designationId,
    required this.employmentStatus,
    this.email,
    this.profilePhotoId,
    this.joiningDate,
    this.reportingManagerName,
    this.reportingManagerId,
    this.gender,
    this.dateOfBirth,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] ?? '',
      employeeCode: json['employeeCode'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      departmentName: json['department'] != null ? json['department']['departmentName'] : null,
      departmentId: json['department'] != null ? json['department']['id'] : null,
      designationName: json['designation'] != null ? json['designation']['designationName'] : null,
      designationId: json['designation'] != null ? json['designation']['id'] : null,
      employmentStatus: json['employmentStatus'] ?? 'Unknown',
      email: json['workEmail'] ?? (json['user'] != null ? json['user']['email'] : null),
      profilePhotoId: json['profilePicture'],
      joiningDate: json['joiningDate'],
      gender: json['gender'],
      dateOfBirth: json['dateOfBirth'],
      reportingManagerName: json['reportingManager'] != null 
          ? '${json['reportingManager']['firstName']} ${json['reportingManager']['lastName']}'.trim() 
          : null,
      reportingManagerId: json['reportingManager'] != null ? json['reportingManager']['id'] : null,
    );
  }

  String get fullName {
    if (firstName.isEmpty && lastName.isEmpty) return 'Unknown Employee';
    return '$firstName $lastName'.trim();
  }
}
