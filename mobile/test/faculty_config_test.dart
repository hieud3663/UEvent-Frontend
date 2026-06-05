import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/config/faculty_config.dart';

void main() {
  test('FacultyConfig chứa danh sách khoa dùng chung', () {
    expect(FacultyConfig.values, contains('Công nghệ thông tin'));
    expect(FacultyConfig.values, contains('Kinh tế'));
    expect(FacultyConfig.values, contains('Khoa học ứng dụng'));
  });

  test('FacultyConfig normalize mã khoa cũ sang tên khoa chuẩn', () {
    expect(FacultyConfig.normalize('cntt'), 'Công nghệ thông tin');
    expect(FacultyConfig.normalize('kt'), 'Kinh tế');
    expect(FacultyConfig.normalize('moi-truong'), 'Môi trường & Tài nguyên');
  });
}
