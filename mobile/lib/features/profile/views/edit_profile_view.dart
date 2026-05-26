import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/app_snack_bar.dart';
import 'package:frontend/core/widgets/glass_dropdown_field.dart';
import 'package:frontend/core/widgets/glass_input_field.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/core/widgets/primary_button.dart';
import 'package:frontend/features/auth/models/user_model.dart';
import 'package:frontend/features/profile/services/profile_service.dart';

class EditProfileView extends StatefulWidget {
  final UserModel? user;
  final ProfileService? profileService;
  final VoidCallback? onBack;
  final VoidCallback? onSaved;
  final VoidCallback? onChangeEmail;

  const EditProfileView({
    super.key,
    this.user,
    this.profileService,
    this.onBack,
    this.onSaved,
    this.onChangeEmail,
  });

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  late final TextEditingController _fullNameCtrl;
  late final TextEditingController _studentCodeCtrl;
  late final TextEditingController _classNameCtrl;
  late final TextEditingController _phoneCtrl;

  String? _selectedFaculty;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = widget.user;
    _fullNameCtrl = TextEditingController(text: user?.fullName ?? '');
    _studentCodeCtrl = TextEditingController(text: user?.studentCode ?? '');
    _classNameCtrl = TextEditingController(text: user?.className ?? '');
    _phoneCtrl = TextEditingController(text: user?.phoneNumber ?? '');
    _selectedFaculty = user?.faculty;

    for (final controller in [_fullNameCtrl, _studentCodeCtrl]) {
      controller.addListener(_refreshFormState);
    }
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _studentCodeCtrl.dispose();
    _classNameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  bool get _isFormValid =>
      _fullNameCtrl.text.trim().isNotEmpty &&
      _studentCodeCtrl.text.trim().isNotEmpty;

  void _refreshFormState() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _handleSave() async {
    if (!_isFormValid || _isSaving) return;

    setState(() => _isSaving = true);

    try {
      final updateData = <String, dynamic>{
        'full_name': _fullNameCtrl.text.trim(),
        'student_code': _studentCodeCtrl.text.trim(),
      };

      final className = _classNameCtrl.text.trim();
      if (className.isNotEmpty) updateData['class_name'] = className;

      if (_selectedFaculty != null) updateData['faculty'] = _selectedFaculty;

      final phone = _phoneCtrl.text.trim();
      if (phone.isNotEmpty) updateData['phone_number'] = phone;

      await widget.profileService?.updateProfile(updateData);

      if (mounted) {
        showAppSnackBar(
          context,
          'Cập nhật thành công!',
          backgroundColor: AppColors.primary,
        );
        widget.onSaved?.call();
      }
    } on DioException catch (error) {
      if (mounted) {
        showAppSnackBar(
          context,
          _apiErrorMessage(error),
          backgroundColor: Colors.red,
        );
      }
    } catch (_) {
      if (mounted) {
        showAppSnackBar(
          context,
          'Lưu thất bại. Vui lòng thử lại.',
          backgroundColor: Colors.red,
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _apiErrorMessage(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['detail'];
      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }
      final errors = data['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final firstValue = errors.values.first;
        if (firstValue is List && firstValue.isNotEmpty) {
          return firstValue.first.toString();
        }
        return firstValue.toString();
      }
    }

    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Không thể kết nối máy chủ. Vui lòng kiểm tra mạng.';
    }

    return 'Không thể hoàn tất yêu cầu. Vui lòng thử lại.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      _AvatarEditor(user: widget.user),
                      const SizedBox(height: 48),
                      _buildEmailSection(),
                      const SizedBox(height: 32),
                      _buildProfileFields(),
                      const SizedBox(height: 48),
                      PrimaryButton(
                        label: _isSaving ? 'Đang lưu...' : 'Lưu thay đổi',
                        isLoading: _isSaving,
                        onPressed: (_isFormValid && !_isSaving)
                            ? _handleSave
                            : null,
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GlassTopBar(
              title: 'Chỉnh sửa hồ sơ',
              leadingIcon: Icons.chevron_left,
              onLeadingTap: widget.onBack,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailSection() {
    final email = widget.user?.email;

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
                onPressed: widget.onChangeEmail,
                child: const Text('Đổi email'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileFields() {
    return Column(
      children: [
        GlassInputField(
          label: 'Họ tên',
          placeholder: 'Nhập họ và tên',
          controller: _fullNameCtrl,
          leadingIcon: Icons.person,
        ),
        const SizedBox(height: 24),
        GlassInputField(
          label: 'Mã số sinh viên (MSSV)',
          placeholder: 'Nhập MSSV',
          controller: _studentCodeCtrl,
          leadingIcon: Icons.badge,
        ),
        const SizedBox(height: 24),
        GlassInputField(
          label: 'Lớp',
          placeholder: 'Nhập lớp sinh hoạt',
          controller: _classNameCtrl,
          leadingIcon: Icons.school,
        ),
        const SizedBox(height: 24),
        GlassDropdownField<String>(
          label: 'Khoa',
          placeholder: 'Chọn khoa của bạn',
          value: _selectedFaculty,
          items: const [
            GlassDropdownItem(value: 'cntt', label: 'Công nghệ thông tin'),
            GlassDropdownItem(value: 'kt', label: 'Kinh tế'),
            GlassDropdownItem(value: 'nn', label: 'Ngoại ngữ'),
            GlassDropdownItem(value: 'luat', label: 'Luật'),
            GlassDropdownItem(value: 'xd', label: 'Xây dựng'),
            GlassDropdownItem(value: 'dien', label: 'Điện - Điện tử'),
            GlassDropdownItem(value: 'co-khi', label: 'Cơ khí'),
            GlassDropdownItem(value: 'mt', label: 'Mỹ thuật công nghiệp'),
            GlassDropdownItem(
              value: 'moi-truong',
              label: 'Môi trường & Tài nguyên',
            ),
            GlassDropdownItem(value: 'khoa-hoc', label: 'Khoa học ứng dụng'),
          ],
          onChanged: (value) => setState(() => _selectedFaculty = value),
        ),
        const SizedBox(height: 24),
        GlassInputField(
          label: 'Số điện thoại',
          placeholder: 'Nhập số điện thoại',
          controller: _phoneCtrl,
          leadingIcon: Icons.phone,
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }
}

class _AvatarEditor extends StatelessWidget {
  const _AvatarEditor({required this.user});

  final UserModel? user;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                color: AppColors.outlineVariant,
              ),
              child: ClipOval(
                child: user?.avatarUrl != null
                    ? Image.network(
                        user!.avatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.person,
                          size: 64,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.person, size: 64, color: Colors.white),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.edit,
                  color: AppColors.onPrimaryContainer,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Đổi ảnh',
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
