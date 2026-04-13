import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String accountStatus;
  final String primaryRole;
  final String? phoneNumber;
  final String? studentCode;
  final String? faculty;
  final String? className;
  final String? avatarUrl;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.accountStatus,
    required this.primaryRole,
    this.phoneNumber,
    this.studentCode,
    this.faculty,
    this.className,
    this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);
    normalized['full_name'] ??= normalized['fullName'];
    normalized['account_status'] ??= normalized['accountStatus'];
    normalized['primary_role'] ??= normalized['primaryRole'];
    normalized['phone_number'] ??= normalized['phoneNumber'];
    normalized['student_code'] ??= normalized['studentCode'];
    normalized['class_name'] ??= normalized['className'];
    normalized['avatar_url'] ??= normalized['avatarUrl'];

    return _$UserModelFromJson(normalized);
  }

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
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

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);
    normalized['access_token'] ??= normalized['accessToken'];
    normalized['expires_in'] ??= normalized['expiresIn'];
    return _$AuthResponseModelFromJson(normalized);
  }

  Map<String, dynamic> toJson() => _$AuthResponseModelToJson(this);
}
