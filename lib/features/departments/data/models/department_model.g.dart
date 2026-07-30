// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'department_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DepartmentModel _$DepartmentModelFromJson(Map<String, dynamic> json) =>
    _DepartmentModel(
      id: json['id'] as String,
      departmentCode: json['departmentCode'] as String,
      departmentName: json['departmentName'] as String,
      description: json['description'] as String?,
      parentDepartmentId: json['parentDepartmentId'] as String?,
      companyId: json['companyId'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );

Map<String, dynamic> _$DepartmentModelToJson(_DepartmentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'departmentCode': instance.departmentCode,
      'departmentName': instance.departmentName,
      'description': instance.description,
      'parentDepartmentId': instance.parentDepartmentId,
      'companyId': instance.companyId,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
