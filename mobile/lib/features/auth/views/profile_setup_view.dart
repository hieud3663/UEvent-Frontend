// File: lib/features/auth/views/profile_setup_view.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/glass_input_field.dart';
import 'package:frontend/core/widgets/glass_dropdown_field.dart';
import 'package:frontend/core/widgets/primary_button.dart';
import 'package:frontend/features/auth/models/user_model.dart';
import 'package:frontend/features/profile/services/profile_service.dart';

/// Màn hình hoàn thiện hồ sơ — bắt buộc cho user mới.
///
/// [profileService] — dùng để gọi PATCH /auth/profile/
/// [initialUser]    — dữ liệu hiện tại từ backend (có thể null nếu chưa fetch được)
/// [onComplete]     — callback sau khi lưu thành công
/// [onBack]         — callback nút back (null = ẩn nút)
class ProfileSetupView extends StatefulWidget {
  final ProfileService? profileService;
  final UserModel? initialUser;
  final VoidCallback? onComplete;
  final VoidCallback? onBack;

  const ProfileSetupView({
    super.key,
    this.profileService,
    this.initialUser,
    this.onComplete,
    this.onBack,
  });

  @override
  State<ProfileSetupView> createState() => _ProfileSetupViewState();
}

class _ProfileSetupViewState extends State<ProfileSetupView> {
  late final TextEditingController _fullNameCtrl;
  late final TextEditingController _studentCodeCtrl;
  late final TextEditingController _classNameCtrl;
  late final TextEditingController _clubCtrl;
  String? _selectedFaculty;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = widget.initialUser;
    _fullNameCtrl = TextEditingController(text: user?.fullName ?? '');
    _studentCodeCtrl = TextEditingController(text: user?.studentCode ?? '');
    _classNameCtrl = TextEditingController(text: user?.className ?? '');
    _clubCtrl = TextEditingController();
    _selectedFaculty = user?.faculty;
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _studentCodeCtrl.dispose();
    _classNameCtrl.dispose();
    _clubCtrl.dispose();
    super.dispose();
  }

  bool get _isFormValid =>
      _fullNameCtrl.text.trim().isNotEmpty &&
      _studentCodeCtrl.text.trim().isNotEmpty &&
      _selectedFaculty != null;

  Future<void> _handleSubmit() async {
    if (!_isFormValid || _isSaving) return;

    setState(() => _isSaving = true);

    try {
      final updateData = <String, dynamic>{
        'full_name': _fullNameCtrl.text.trim(),
        'student_code': _studentCodeCtrl.text.trim(),
        'faculty': _selectedFaculty,
      };

      // Chỉ gửi class_name nếu có nhập
      final className = _classNameCtrl.text.trim();
      if (className.isNotEmpty) {
        updateData['class_name'] = className;
      }

      if (widget.profileService != null) {
        await widget.profileService!.updateProfile(updateData);
      }

      if (mounted) {
        widget.onComplete?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lưu thất bại: $e'),
            backgroundColor: Colors.red.shade400,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Scrollable Content
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 100, 24, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Titles
                  Text(
                    'Thông tin cá nhân',
                    style: AppTextStyles.headlineLarge.copyWith(fontSize: 32),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Vui lòng cung cấp thông tin chính xác để tham gia các sự kiện tại UEvents.',
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Form Fields
                  GlassInputField(
                    label: 'HỌ TÊN',
                    placeholder: 'Nhập họ và tên',
                    controller: _fullNameCtrl,
                  ),
                  const SizedBox(height: 20),

                  GlassInputField(
                    label: 'MÃ SỐ SINH VIÊN (MSSV)',
                    placeholder: 'Nhập MSSV',
                    controller: _studentCodeCtrl,
                  ),
                  const SizedBox(height: 20),

                  GlassInputField(
                    label: 'LỚP',
                    placeholder: 'Nhập lớp sinh hoạt',
                    controller: _classNameCtrl,
                  ),
                  const SizedBox(height: 20),

                  GlassDropdownField<String>(
                    label: 'KHOA',
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
                      GlassDropdownItem(value: 'moi-truong', label: 'Môi trường & Tài nguyên'),
                      GlassDropdownItem(value: 'khoa-hoc', label: 'Khoa học ứng dụng'),
                    ],
                    onChanged: (val) => setState(() => _selectedFaculty = val),
                  ),
                  const SizedBox(height: 20),

                  GlassInputField(
                    label: 'CÂU LẠC BỘ ĐANG THAM GIA',
                    placeholder: 'Tên câu lạc bộ (nếu có)',
                    controller: _clubCtrl,
                    labelTrailing: Text(
                      'Tùy chọn',
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Privacy Notice
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.verified_user,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Thông tin của bạn sẽ được bảo mật và chỉ sử dụng cho mục đích đăng ký tham gia các hoạt động tại trường.',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Glass App Bar Fixed
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  color: AppColors.background.withValues(alpha: 0.8),
                  child: SafeArea(
                    bottom: false,
                    child: Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.black.withValues(alpha: 0.05),
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (widget.onBack != null)
                            GestureDetector(
                              onTap: widget.onBack,
                              child: const SizedBox(
                                width: 40,
                                height: 40,
                                child: Icon(Icons.chevron_left),
                              ),
                            )
                          else
                            const SizedBox(width: 40),
                          Text(
                            'Hoàn thiện hồ sơ',
                            style: AppTextStyles.titleMedium,
                          ),
                          const SizedBox(width: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Glass Bottom Action Fixed
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: EdgeInsets.only(
                    left: 24,
                    right: 24,
                    top: 24,
                    bottom: MediaQuery.of(context).padding.bottom + 24,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background.withValues(alpha: 0.8),
                    border: Border(
                      top: BorderSide(
                        color: Colors.black.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                  child: PrimaryButton(
                    label: _isSaving ? 'Đang lưu...' : 'Hoàn tất',
                    icon: _isSaving ? null : Icons.arrow_forward,
                    onPressed: (_isFormValid && !_isSaving) ? _handleSubmit : null,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
