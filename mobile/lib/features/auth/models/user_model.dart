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
    return UserModel(
      id: (json['id'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      fullName: (json['fullName'] ?? json['full_name'] ?? '').toString(),
      accountStatus: (json['accountStatus'] ?? json['account_status'] ?? '').toString(),
      primaryRole: (json['primaryRole'] ?? json['primary_role'] ?? '').toString(),
      phoneNumber: json['phoneNumber']?.toString(),
      studentCode: json['studentCode']?.toString(),
      faculty: json['faculty']?.toString(),
      className: json['className']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
    );
  }
}

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
    return AuthResponseModel(
      accessToken: (json['accessToken'] ?? json['access_token'] ?? '').toString(),
      expiresIn: (json['expiresIn'] ?? json['expires_in'] ?? 0) as int,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
