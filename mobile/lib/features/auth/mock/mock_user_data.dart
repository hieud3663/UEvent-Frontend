import 'package:frontend/features/auth/models/user_model.dart';

class MockUserData {
  static const UserModel currentUser = UserModel(
    id: 'user-001',
    email: 'student@utc2.edu.vn',
    fullName: 'Nguyễn Văn A',
    accountStatus: 'active',
    primaryRole: 'student',
    phoneNumber: '0123456789',
    studentCode: '2024001',
    faculty: 'Khoa Công nghệ Thông tin',
    className: 'K61-CNTT1',
    avatarUrl: 'https://i.pravatar.cc/300',
  );

  static const AuthResponseModel mockAuthResponse = AuthResponseModel(
    accessToken: 'mock_jwt_token_12345',
    expiresIn: 3600,
    user: currentUser,
  );
}
