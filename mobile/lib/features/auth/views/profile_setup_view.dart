import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/glass_input_field.dart';
import 'package:frontend/core/widgets/primary_button.dart';

class ProfileSetupView extends StatelessWidget {
  final VoidCallback? onComplete;
  final VoidCallback? onBack;

  const ProfileSetupView({
    super.key,
    this.onComplete,
    this.onBack,
  });

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
                  const GlassInputField(
                    label: 'HỌ TÊN',
                    placeholder: 'Nhập họ và tên',
                  ),
                  const SizedBox(height: 20),

                  const GlassInputField(
                    label: 'MÃ SỐ SINH VIÊN (MSSV)',
                    placeholder: 'Nhập MSSV',
                  ),
                  const SizedBox(height: 20),

                  const GlassInputField(
                    label: 'LỚP',
                    placeholder: 'Nhập lớp sinh hoạt',
                  ),
                  const SizedBox(height: 20),

                  GlassInputField(
                    label: 'KHOA',
                    placeholder: 'Chọn khoa của bạn',
                    trailing: const Icon(Icons.expand_more, color: AppColors.outline),
                  ),
                  const SizedBox(height: 20),

                  GlassInputField(
                    label: 'CÂU LẠC BỘ ĐANG THAM GIA',
                    placeholder: 'Tên câu lạc bộ (nếu có)',
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
                          GestureDetector(
                            onTap: onBack,
                            child: const SizedBox(
                              width: 40,
                              height: 40,
                              child: Icon(Icons.chevron_left),
                            ),
                          ),
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
                  color: AppColors.background.withValues(alpha: 0.8),
                  padding: EdgeInsets.only(
                    left: 24,
                    right: 24,
                    top: 24,
                    bottom: MediaQuery.of(context).padding.bottom + 24,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.black.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                  child: PrimaryButton(
                    label: 'Hoàn tất',
                    icon: Icons.arrow_forward,
                    onPressed: onComplete,
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
