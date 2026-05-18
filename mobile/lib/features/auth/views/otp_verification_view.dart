import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/primary_button.dart';
import 'package:frontend/features/auth/widgets/otp_input_row.dart';

class OtpVerificationView extends StatefulWidget {
  final String email;
  final Future<void> Function(String code)? onVerify;
  final Future<void> Function()? onResend;
  final VoidCallback? onBack;

  const OtpVerificationView({
    super.key,
    required this.email,
    this.onVerify,
    this.onResend,
    this.onBack,
  });

  @override
  State<OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends State<OtpVerificationView> {
  String _code = '';
  bool _isSubmitting = false;
  bool _isResending = false;
  int _cooldownSeconds = 60;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    setState(() => _cooldownSeconds = 60);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldownSeconds <= 1) {
        timer.cancel();
        if (mounted) setState(() => _cooldownSeconds = 0);
        return;
      }
      if (mounted) setState(() => _cooldownSeconds -= 1);
    });
  }

  Future<void> _submit() async {
    if (_code.length != 6 || _isSubmitting || widget.onVerify == null) return;
    setState(() => _isSubmitting = true);
    try {
      await widget.onVerify!(_code);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _resend() async {
    if (_cooldownSeconds > 0 || _isResending || widget.onResend == null) return;
    setState(() => _isResending = true);
    try {
      await widget.onResend!();
      if (mounted) _startCooldown();
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _code.length == 6 && !_isSubmitting;
    final resendLabel = _cooldownSeconds > 0
        ? 'Gửi lại sau ${_cooldownSeconds}s'
        : _isResending
        ? 'Đang gửi lại...'
        : 'Gửi lại mã';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF5F7FA), Color(0xFFC3CFE2)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(
                  maxWidth: 450,
                  minHeight: 620,
                ),
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
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: _isSubmitting ? null : widget.onBack,
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
                              const SizedBox(width: 40),
                            ],
                          ),
                        ),
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
                                'Chúng tôi vừa gửi mã OTP gồm 6 chữ số đến ${widget.email}.',
                                style: AppTextStyles.bodyMedium,
                              ),
                              const SizedBox(height: 44),
                              OtpInputRow(
                                length: 6,
                                onChanged: (value) =>
                                    setState(() => _code = value),
                                onCompleted: (_) => _submit(),
                              ),
                              const SizedBox(height: 40),
                              Opacity(
                                opacity: canSubmit ? 1 : 0.55,
                                child: PrimaryButton(
                                  label: _isSubmitting
                                      ? 'Đang xác nhận...'
                                      : 'Xác nhận',
                                  onPressed: canSubmit ? _submit : null,
                                ),
                              ),
                              const SizedBox(height: 40),
                              Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(
                                        alpha: 0.05,
                                      ),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      _cooldownSeconds > 0
                                          ? 'Mã có hiệu lực trong ${_cooldownSeconds}s'
                                          : 'Bạn có thể yêu cầu mã mới',
                                      style: AppTextStyles.labelMedium.copyWith(
                                        color: AppColors.onSurface,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  GestureDetector(
                                    onTap:
                                        _cooldownSeconds == 0 && !_isResending
                                        ? _resend
                                        : null,
                                    child: Text(
                                      resendLabel,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: _cooldownSeconds == 0
                                            ? AppColors.primary
                                            : AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
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
                            child: Text(
                              'MÃ HÓA BỞI UEVENTS',
                              style: AppTextStyles.labelSmall.copyWith(
                                letterSpacing: 2.0,
                              ),
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
