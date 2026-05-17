import 'package:json_annotation/json_annotation.dart';

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
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

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

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseModelToJson(this);
}
