import 'package:flutter/material.dart';
import 'package:frontend/core/config/faculty_config.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/glass_dropdown_field.dart';
import 'package:frontend/core/widgets/glass_input_field.dart';

class EditProfileEmailSection extends StatelessWidget {
  final String? email;
  final VoidCallback? onChangeEmail;

  const EditProfileEmailSection({
    super.key,
    required this.email,
    required this.onChangeEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassInputField(
          label: 'Email đăng nhập',
          leadingIcon: Icons.mail,
          child: Row(
            children: [
              const Icon(Icons.mail, color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  email?.isNotEmpty == true ? email! : '---',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              TextButton(
                onPressed: onChangeEmail,
                child: const Text('Đổi email'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class EditProfileFormFields extends StatelessWidget {
  final TextEditingController fullNameController;
  final TextEditingController studentCodeController;
  final TextEditingController classNameController;
  final TextEditingController phoneController;
  final String? selectedFaculty;
  final ValueChanged<String?> onFacultyChanged;

  const EditProfileFormFields({
    super.key,
    required this.fullNameController,
    required this.studentCodeController,
    required this.classNameController,
    required this.phoneController,
    required this.selectedFaculty,
    required this.onFacultyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GlassInputField(
          label: 'Họ tên',
          placeholder: 'Nhập họ và tên',
          controller: fullNameController,
          leadingIcon: Icons.person,
        ),
        const SizedBox(height: 24),
        GlassInputField(
          label: 'Mã số sinh viên (MSSV)',
          placeholder: 'Nhập MSSV',
          controller: studentCodeController,
          leadingIcon: Icons.badge,
        ),
        const SizedBox(height: 24),
        GlassInputField(
          label: 'Lớp',
          placeholder: 'Nhập lớp sinh hoạt',
          controller: classNameController,
          leadingIcon: Icons.school,
        ),
        const SizedBox(height: 24),
        GlassDropdownField<String>(
          label: 'Khoa',
          placeholder: 'Chọn khoa của bạn',
          value: selectedFaculty,
          items: FacultyConfig.values
              .map(
                (faculty) => GlassDropdownItem(value: faculty, label: faculty),
              )
              .toList(growable: false),
          onChanged: onFacultyChanged,
        ),
        const SizedBox(height: 24),
        GlassInputField(
          label: 'Số điện thoại',
          placeholder: 'Nhập số điện thoại',
          controller: phoneController,
          leadingIcon: Icons.phone,
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }
}
