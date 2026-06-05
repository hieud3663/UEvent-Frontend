import 'package:json_annotation/json_annotation.dart';
import 'package:frontend/core/utils/image_cache_key.dart';

part 'user_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String accountStatus;
  final String primaryRole;
  @JsonKey(defaultValue: false)
  final bool isProfileComplete;
  final String? phoneNumber;
  final String? studentCode;
  final String? faculty;
  final String? className;
  final String? avatarUrl;
  final String? avatarCacheKey;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.accountStatus,
    required this.primaryRole,
    this.isProfileComplete = false,
    this.phoneNumber,
    this.studentCode,
    this.faculty,
    this.className,
    this.avatarUrl,
    this.avatarCacheKey,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(_normalizeUserJson(json));

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  String? get stableAvatarCacheKey => stableImageCacheKey(
    imageUrl: avatarUrl ?? '',
    explicitCacheKey: avatarCacheKey,
  );
}

Map<String, dynamic> _normalizeUserJson(Map<String, dynamic> json) {
  return <String, dynamic>{
    ...json,
    'id': _stringValue(json['id']),
    'email': _stringValue(json['email']),
    'full_name': _stringValue(json['full_name'] ?? json['name']),
    'account_status': _stringValue(json['account_status'], fallback: 'active'),
    'primary_role': _stringValue(
      json['primary_role'] ?? json['role'],
      fallback: 'student',
    ),
    'is_profile_complete': _boolValue(json['is_profile_complete']),
    'phone_number': _nullableStringValue(json['phone_number']),
    'student_code': _nullableStringValue(json['student_code']),
    'faculty': _nullableStringValue(json['faculty']),
    'class_name': _nullableStringValue(json['class_name']),
    'avatar_url': _nullableStringValue(json['avatar_url']),
    'avatar_cache_key': _nullableStringValue(
      json['avatar_cache_key'] ?? json['avatarCacheKey'],
    ),
  };
}

String _stringValue(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  final text = value.toString();
  return text.isEmpty ? fallback : text;
}

String? _nullableStringValue(dynamic value) {
  if (value == null) return null;
  return value.toString();
}

bool _boolValue(dynamic value) {
  if (value is bool) return value;
  if (value is String) return value.toLowerCase() == 'true';
  if (value is num) return value != 0;
  return false;
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AuthResponseModel {
  final String accessToken;
  final int expiresIn;
  final UserModel user;

  const AuthResponseModel({
    required this.accessToken,
    required this.expiresIn,
    required this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseModelToJson(this);
}
