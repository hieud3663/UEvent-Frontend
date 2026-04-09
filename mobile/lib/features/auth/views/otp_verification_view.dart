import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/primary_button.dart';
import 'package:frontend/features/auth/widgets/otp_input_row.dart';

class OtpVerificationView extends StatelessWidget {
  final VoidCallback? onVerify;
  final VoidCallback? onResend;
  final VoidCallback? onBack;

  const OtpVerificationView({
    super.key,
    this.onVerify,
    this.onResend,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF5F7FA),
              Color(0xFFC3CFE2),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 450, minHeight: 640),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Column(
                      children: [
                        // Top App Bar inside Card
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: onBack,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.chevron_left,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                              ),
                              Text(
                                'XÁC THỰC',
                                style: AppTextStyles.labelSmall.copyWith(
                                  letterSpacing: 2.0,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(width: 40), // Spacer for center alignment
                            ],
                          ),
                        ),

                        // Content
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                                Text(
                                  'Mã xác nhận',
                                  style: AppTextStyles.headlineLarge.copyWith(
                                    fontSize: 32,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Chúng tôi vừa gửi mã OTP gồm 6 chữ số đến địa chỉ email của bạn.',
                                  style: AppTextStyles.bodyMedium,
                                ),
                                const SizedBox(height: 48),

                                // OTP Row
                                const OtpInputRow(length: 6),
                                
                                const SizedBox(height: 48),

                                PrimaryButton(
                                  label: 'Xác nhận',
                                  onPressed: onVerify,
                                ),

                                const SizedBox(height: 48),

                                // Resend & Timer
                                Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              value: 0.3, // Example value
                                              backgroundColor: AppColors.outlineVariant,
                                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                                              strokeWidth: 2.5,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            '02:59',
                                            style: AppTextStyles.labelMedium.copyWith(
                                              color: AppColors.onSurface,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    GestureDetector(
                                      onTap: onResend,
                                      child: Text(
                                        'Tôi không nhận được mã?',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 40),
                            ],
                          ),
                        ),

                        // Footer note
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'UEVENTS ENCRYPTED',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    letterSpacing: 2.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
