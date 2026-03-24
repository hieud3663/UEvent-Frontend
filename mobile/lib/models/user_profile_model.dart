// File: lib/models/user_profile_model.dart

/// Data class representing a User Profile.
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

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      name: json['name'] as String,
      studentId: json['studentId'] as String,
      faculty: json['faculty'] as String,
      className: json['className'] as String,
      avatarUrl: json['avatarUrl'] as String,
      eventCount: json['eventCount'] as int,
      clubCount: json['clubCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'studentId': studentId,
      'faculty': faculty,
      'className': className,
      'avatarUrl': avatarUrl,
      'eventCount': eventCount,
      'clubCount': clubCount,
    };
  }
}
