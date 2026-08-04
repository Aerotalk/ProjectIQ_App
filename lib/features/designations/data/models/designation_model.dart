class DesignationModel {
  final String id;
  final String designationCode;
  final String designationName;
  final String? roleId;
  final Map<String, dynamic>? role;
  final String? description;
  final String? companyId;
  final String? createdAt;
  final String? updatedAt;

  const DesignationModel({
    required this.id,
    required this.designationCode,
    required this.designationName,
    this.roleId,
    this.role,
    this.description,
    this.companyId,
    this.createdAt,
    this.updatedAt,
  });

  factory DesignationModel.fromJson(Map<String, dynamic> json) {
    return DesignationModel(
      id: json['id'] as String? ?? '',
      designationCode: json['designationCode'] as String? ?? '',
      designationName: json['designationName'] as String? ?? '',
      roleId: json['roleId'] as String?,
      role: json['role'] as Map<String, dynamic>?,
      description: json['description'] as String?,
      companyId: json['companyId'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'designationCode': designationCode,
      'designationName': designationName,
      'roleId': roleId,
      'role': role,
      'description': description,
      'companyId': companyId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  DesignationModel copyWith({
    String? id,
    String? designationCode,
    String? designationName,
    String? roleId,
    Map<String, dynamic>? role,
    String? description,
    String? companyId,
    String? createdAt,
    String? updatedAt,
  }) {
    return DesignationModel(
      id: id ?? this.id,
      designationCode: designationCode ?? this.designationCode,
      designationName: designationName ?? this.designationName,
      roleId: roleId ?? this.roleId,
      role: role ?? this.role,
      description: description ?? this.description,
      companyId: companyId ?? this.companyId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
