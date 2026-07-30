class DepartmentModel {
  final String id;
  final String departmentCode;
  final String departmentName;
  final String? description;
  final String? parentDepartmentId;
  final String? companyId;
  final String? createdAt;
  final String? updatedAt;

  const DepartmentModel({
    required this.id,
    required this.departmentCode,
    required this.departmentName,
    this.description,
    this.parentDepartmentId,
    this.companyId,
    this.createdAt,
    this.updatedAt,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      id: json['id'] as String? ?? '',
      departmentCode: json['departmentCode'] as String? ?? '',
      departmentName: json['departmentName'] as String? ?? '',
      description: json['description'] as String?,
      parentDepartmentId: json['parentDepartmentId'] as String?,
      companyId: json['companyId'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'departmentCode': departmentCode,
      'departmentName': departmentName,
      'description': description,
      'parentDepartmentId': parentDepartmentId,
      'companyId': companyId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  DepartmentModel copyWith({
    String? id,
    String? departmentCode,
    String? departmentName,
    String? description,
    String? parentDepartmentId,
    String? companyId,
    String? createdAt,
    String? updatedAt,
  }) {
    return DepartmentModel(
      id: id ?? this.id,
      departmentCode: departmentCode ?? this.departmentCode,
      departmentName: departmentName ?? this.departmentName,
      description: description ?? this.description,
      parentDepartmentId: parentDepartmentId ?? this.parentDepartmentId,
      companyId: companyId ?? this.companyId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
