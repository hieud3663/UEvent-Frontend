// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String,
  email: json['email'] as String,
  fullName: json['full_name'] as String,
  accountStatus: json['account_status'] as String,
  primaryRole: json['primary_role'] as String,
  isProfileComplete: json['is_profile_complete'] as bool? ?? false,
  phoneNumber: json['phone_number'] as String?,
  studentCode: json['student_code'] as String?,
  faculty: json['faculty'] as String?,
  className: json['class_name'] as String?,
  avatarUrl: json['avatar_url'] as String?,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'full_name': instance.fullName,
  'account_status': instance.accountStatus,
  'primary_role': instance.primaryRole,
  'is_profile_complete': instance.isProfileComplete,
  'phone_number': instance.phoneNumber,
  'student_code': instance.studentCode,
  'faculty': instance.faculty,
  'class_name': instance.className,
  'avatar_url': instance.avatarUrl,
};

AuthResponseModel _$AuthResponseModelFromJson(Map<String, dynamic> json) =>
    AuthResponseModel(
      accessToken: json['access_token'] as String,
      expiresIn: (json['expires_in'] as num).toInt(),
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AuthResponseModelToJson(AuthResponseModel instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'expires_in': instance.expiresIn,
      'user': instance.user.toJson(),
    };
