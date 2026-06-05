import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/auth/views/profile_setup_view.dart';

void main() {
  test('ProfileSetup payload luôn gửi faculty đã chọn lên backend', () {
    final payload = buildProfileSetupPayload(
      fullName: ' Nguyễn Văn A ',
      studentCode: ' 22123456 ',
      faculty: ' Công nghệ thông tin ',
      className: ' 22DTHA1 ',
      phoneNumber: ' 0901234567 ',
    );

    expect(payload['full_name'], 'Nguyễn Văn A');
    expect(payload['student_code'], '22123456');
    expect(payload['faculty'], 'Công nghệ thông tin');
    expect(payload['class_name'], '22DTHA1');
    expect(payload['phone_number'], '0901234567');
  });

  test('ProfileSetup payload không gửi class_name và phone_number rỗng', () {
    final payload = buildProfileSetupPayload(
      fullName: 'Nguyễn Văn A',
      studentCode: '22123456',
      faculty: 'Kinh tế',
      className: '   ',
      phoneNumber: '',
    );

    expect(payload['faculty'], 'Kinh tế');
    expect(payload.containsKey('class_name'), isFalse);
    expect(payload.containsKey('phone_number'), isFalse);
  });

  test('ProfileSetup payload normalize mã khoa cũ trước khi gửi', () {
    final payload = buildProfileSetupPayload(
      fullName: 'Nguyễn Văn A',
      studentCode: '22123456',
      faculty: 'cntt',
    );

    expect(payload['faculty'], 'Công nghệ thông tin');
  });
}
