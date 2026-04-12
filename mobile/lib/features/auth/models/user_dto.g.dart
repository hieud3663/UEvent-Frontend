// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserDTO _$UserDTOFromJson(Map<String, dynamic> json) => _UserDTO(
  id: json['id'] as String,
  fullName: json['full_name'] as String,
  email: json['email'] as String,
  accountStatus: json['account_status'] as String,
  primaryRole: json['primary_role'] as String,
  phoneNumber: json['phone_number'] as String?,
  studentCode: json['student_code'] as String?,
  faculty: json['faculty'] as String?,
  className: json['class_name'] as String?,
  avatarUrl: json['avatar_url'] as String?,
);

Map<String, dynamic> _$UserDTOToJson(_UserDTO instance) => <String, dynamic>{
  'id': instance.id,
  'full_name': instance.fullName,
  'email': instance.email,
  'account_status': instance.accountStatus,
  'primary_role': instance.primaryRole,
  'phone_number': instance.phoneNumber,
  'student_code': instance.studentCode,
  'faculty': instance.faculty,
  'class_name': instance.className,
  'avatar_url': instance.avatarUrl,
};

_AuthResponseDTO _$AuthResponseDTOFromJson(Map<String, dynamic> json) =>
    _AuthResponseDTO(
      accessToken: json['access_token'] as String,
      expiresIn: (json['expires_in'] as num).toInt(),
      user: UserDTO.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AuthResponseDTOToJson(_AuthResponseDTO instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'expires_in': instance.expiresIn,
      'user': instance.user.toJson(),
    };
