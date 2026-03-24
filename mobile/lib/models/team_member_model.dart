// File: lib/models/team_member_model.dart

/// Data class representing a BTC/Organizer team member.
class TeamMemberModel {
  final String id;
  final String name;
  final String role;
  final String avatarUrl;

  const TeamMemberModel({
    required this.id,
    required this.name,
    required this.role,
    required this.avatarUrl,
  });

  factory TeamMemberModel.fromJson(Map<String, dynamic> json) {
    return TeamMemberModel(
      id: json['id'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      avatarUrl: json['avatarUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'avatarUrl': avatarUrl,
    };
  }
}
