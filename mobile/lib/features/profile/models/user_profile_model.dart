// File: lib/models/user_profile_model.dart

import 'package:json_annotation/json_annotation.dart';

part 'user_profile_model.g.dart';

/// Data class representing a User Profile.
@JsonSerializable(fieldRename: FieldRename.snake)
class UserProfileModel {
  final String name;
  final String studentId;
  final String faculty;
  final String className;
  final String avatarUrl;
  final int eventCount;
  final int clubCount;

  const UserProfileModel({
    required this.name,
    required this.studentId,
    required this.faculty,
    required this.className,
    required this.avatarUrl,
    required this.eventCount,
    required this.clubCount,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) =>
      _$UserProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileModelToJson(this);
}
