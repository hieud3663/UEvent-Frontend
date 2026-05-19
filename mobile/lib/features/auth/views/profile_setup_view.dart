import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/providers/service_providers.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/glass_dropdown_field.dart';
import 'package:frontend/core/widgets/glass_input_field.dart';
import 'package:frontend/core/widgets/primary_button.dart';
import 'package:frontend/features/auth/models/user_model.dart';
import 'package:frontend/features/profile/providers/profile_providers.dart';
import 'package:frontend/features/profile/services/profile_service.dart';

class ProfileSetupView extends ConsumerStatefulWidget {
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
  ConsumerState<ProfileSetupView> createState() => _ProfileSetupViewState();
}

class _ProfileSetupViewState extends ConsumerState<ProfileSetupView> {
  final _fullNameController = TextEditingController();
  final _studentCodeController = TextEditingController();
  final _classNameController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedFaculty;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final user = widget.initialUser;
    if (user != null) {
      _fullNameController.text = user.fullName;
      _studentCodeController.text = user.studentCode ?? '';
      _classNameController.text = user.className ?? '';
      _phoneController.text = user.phoneNumber ?? '';
      _selectedFaculty = user.faculty;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _studentCodeController.dispose();
    _classNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  bool get _isFormValid =>
      _fullNameController.text.trim().isNotEmpty &&
      _studentCodeController.text.trim().isNotEmpty &&
      (_selectedFaculty?.trim().isNotEmpty ?? false);

  Future<void> _submitProfile() async {
    if (!_isFormValid || _isSubmitting) {
      _showMessage('Vui lòng nhập đầy đủ họ tên, mã số sinh viên và khoa.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final ProfileService profileService =
          widget.profileService ?? ref.read(profileServiceProvider);
      await profileService.updateProfile({
        'full_name': _fullNameController.text.trim(),
        'student_code': _studentCodeController.text.trim(),
        'faculty': _selectedFaculty!.trim(),
        'class_name': _classNameController.text.trim(),
        'phone_number': _phoneController.text.trim(),
      });

      ref.invalidate(userProfileProvider);
      ref.invalidate(profileOverviewProvider);
      widget.onComplete?.call();
    } on DioException catch (error) {
      _showMessage(_errorMessage(error));
    } catch (_) {
      _showMessage('Không thể cập nhật hồ sơ. Vui lòng thử lại.');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _errorMessage(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['detail'];
      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }
    }
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Không thể kết nối máy chủ. Vui lòng kiểm tra mạng.';
    }
    return 'Không thể cập nhật hồ sơ. Vui lòng thử lại.';
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 100, 24, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                  GlassInputField(
                    label: 'HỌ TÊN',
                    placeholder: 'Nhập họ và tên',
                    controller: _fullNameController,
                  ),
                  const SizedBox(height: 20),
                  GlassInputField(
                    label: 'MÃ SỐ SINH VIÊN (MSSV)',
                    placeholder: 'Nhập MSSV',
                    controller: _studentCodeController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  GlassInputField(
                    label: 'LỚP',
                    placeholder: 'Nhập lớp sinh hoạt',
                    controller: _classNameController,
                  ),
                  const SizedBox(height: 20),
                  GlassDropdownField<String>(
                    label: 'KHOA',
                    placeholder: 'Chọn khoa của bạn',
                    value: _selectedFaculty,
                    items: const [
                      GlassDropdownItem(
                        value: 'Công nghệ thông tin',
                        label: 'Công nghệ thông tin',
                      ),
                      GlassDropdownItem(value: 'Kinh tế', label: 'Kinh tế'),
                      GlassDropdownItem(value: 'Ngoại ngữ', label: 'Ngoại ngữ'),
                      GlassDropdownItem(value: 'Luật', label: 'Luật'),
                      GlassDropdownItem(value: 'Xây dựng', label: 'Xây dựng'),
                      GlassDropdownItem(
                        value: 'Điện - Điện tử',
                        label: 'Điện - Điện tử',
                      ),
                      GlassDropdownItem(value: 'Cơ khí', label: 'Cơ khí'),
                      GlassDropdownItem(
                        value: 'Mỹ thuật công nghiệp',
                        label: 'Mỹ thuật công nghiệp',
                      ),
                      GlassDropdownItem(
                        value: 'Môi trường & Tài nguyên',
                        label: 'Môi trường & Tài nguyên',
                      ),
                      GlassDropdownItem(
                        value: 'Khoa học ứng dụng',
                        label: 'Khoa học ứng dụng',
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _selectedFaculty = value),
                  ),
                  const SizedBox(height: 20),
                  GlassInputField(
                    label: 'SỐ ĐIỆN THOẠI',
                    placeholder: 'Nhập số điện thoại (nếu có)',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    labelTrailing: Text(
                      'Tùy chọn',
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.black.withValues(alpha: 0.05),
                      ),
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
                    label: _isSubmitting ? 'Đang lưu...' : 'Hoàn tất',
                    icon: _isSubmitting ? null : Icons.arrow_forward,
                    onPressed: _isSubmitting ? null : _submitProfile,
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
