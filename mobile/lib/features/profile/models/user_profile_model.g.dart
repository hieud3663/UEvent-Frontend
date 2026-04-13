// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfileModel _$UserProfileModelFromJson(Map<String, dynamic> json) =>
    UserProfileModel(
      name: json['name'] as String,
      studentId: json['student_id'] as String,
      faculty: json['faculty'] as String,
      className: json['class_name'] as String,
      avatarUrl: json['avatar_url'] as String,
      eventCount: (json['event_count'] as num).toInt(),
      clubCount: (json['club_count'] as num).toInt(),
    );

Map<String, dynamic> _$UserProfileModelToJson(UserProfileModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'student_id': instance.studentId,
      'faculty': instance.faculty,
      'class_name': instance.className,
      'avatar_url': instance.avatarUrl,
      'event_count': instance.eventCount,
      'club_count': instance.clubCount,
    };
