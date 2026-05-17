import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/primary_button.dart';
import 'package:frontend/features/auth/widgets/otp_input_row.dart';

/// View xác thực OTP.
///
/// [email]         — địa chỉ email đã gửi OTP (hiển thị cho user).
/// [canResendAt]   — thời điểm cho phép gửi lại (null = có thể gửi ngay).
/// [isVerifying]   — true khi đang gọi API verify (disable nút).
/// [onCompleted]   — callback khi user nhập đủ 6 số, truyền code ra ngoài.
/// [onResend]      — callback khi user nhấn "Gửi lại".
/// [onBack]        — callback nút back.
class OtpVerificationView extends StatefulWidget {
  final String email;
  final DateTime? canResendAt;
  final bool isVerifying;
  final ValueChanged<String>? onCompleted;
  final VoidCallback? onResend;
  final VoidCallback? onBack;

  const OtpVerificationView({
    super.key,
    required this.email,
    this.canResendAt,
    this.isVerifying = false,
    this.onCompleted,
    this.onResend,
    this.onBack,
  });

  @override
  State<OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends State<OtpVerificationView> {
  Timer? _timer;
  int _remainingSeconds = 0;
  String _collectedCode = '';

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didUpdateWidget(OtpVerificationView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.canResendAt != widget.canResendAt) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    if (widget.canResendAt == null) {
      setState(() => _remainingSeconds = 0);
      return;
    }
    final diff = widget.canResendAt!.difference(DateTime.now()).inSeconds;
    setState(() => _remainingSeconds = diff.clamp(0, 9999));

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _remainingSeconds = (_remainingSeconds - 1).clamp(0, 9999);
      });
      if (_remainingSeconds <= 0) _timer?.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool get _canResend => _remainingSeconds <= 0;

  String get _timerLabel {
    final m = _remainingSeconds ~/ 60;
    final s = _remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  double get _timerProgress =>
      _remainingSeconds > 0 ? _remainingSeconds / 60.0 : 0.0;

  void _onOtpCompleted(String code) {
    setState(() => _collectedCode = code);
    widget.onCompleted?.call(code);
  }

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
                        // Top App Bar
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: widget.onBack,
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
                              const SizedBox(height: 12),
                              RichText(
                                text: TextSpan(
                                  style: AppTextStyles.bodyMedium,
                                  children: [
                                    const TextSpan(text: 'Chúng tôi đã gửi mã OTP đến '),
                                    TextSpan(
                                      text: widget.email,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 48),

                              // OTP Input
                              OtpInputRow(
                                length: 6,
                                onCompleted: _onOtpCompleted,
                              ),

                              const SizedBox(height: 48),

                              PrimaryButton(
                                label: widget.isVerifying ? 'Đang xác thực...' : 'Xác nhận',
                                onPressed: (widget.isVerifying || _collectedCode.length < 6)
                                    ? null
                                    : () => widget.onCompleted?.call(_collectedCode),
                              ),

                              const SizedBox(height: 48),

                              // Countdown + Resend
                              Column(
                                children: [
                                  if (!_canResend) ...[
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
                                              value: _timerProgress,
                                              backgroundColor: AppColors.outlineVariant,
                                              valueColor: const AlwaysStoppedAnimation<Color>(
                                                AppColors.primary,
                                              ),
                                              strokeWidth: 2.5,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            _timerLabel,
                                            style: AppTextStyles.labelMedium.copyWith(
                                              color: AppColors.onSurface,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                  GestureDetector(
                                    onTap: _canResend ? widget.onResend : null,
                                    child: Text(
                                      _canResend
                                          ? 'Gửi lại mã'
                                          : 'Tôi không nhận được mã?',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: _canResend
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

                        // Footer
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

