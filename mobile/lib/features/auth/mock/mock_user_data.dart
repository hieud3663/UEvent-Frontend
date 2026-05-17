import 'package:frontend/features/auth/models/user_model.dart';

class MockUserData {
  static const UserModel currentUser = UserModel(
    id: 'user-001',
    email: 'student@utc2.edu.vn',
    fullName: 'Nguyễn Văn A',
    accountStatus: 'active',
    primaryRole: 'student',
    isProfileComplete: true,
    phoneNumber: '0123456789',
    studentCode: '2024001',
    faculty: 'Khoa Công nghệ Thông tin',
    className: 'K61-CNTT1',
    avatarUrl: 'https://i.pravatar.cc/300',
  );

  /// Mock user chưa hoàn thiện hồ sơ — dùng để test ProfileSetupView.
  static const UserModel incompleteUser = UserModel(
    id: 'user-002',
    email: 'new@utc2.edu.vn',
    fullName: '',
    accountStatus: 'active',
    primaryRole: 'student',
    isProfileComplete: false,
  );

  static const AuthResponseModel mockAuthResponse = AuthResponseModel(
    accessToken: 'mock_jwt_token_12345',
    expiresIn: 3600,
    user: currentUser,
  );
}
