import 'package:frontend/features/auth/models/user_dto.dart';

class MockUserData {
  static const UserDTO currentUser = UserDTO(
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

  static const AuthResponseDTO mockAuthResponse = AuthResponseDTO(
    accessToken: 'mock_jwt_token_12345',
    expiresIn: 3600,
    user: currentUser,
  );
}
