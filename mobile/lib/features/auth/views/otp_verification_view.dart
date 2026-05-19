import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/glass_icon_button.dart';
import 'package:frontend/core/widgets/primary_button.dart';
import 'package:frontend/core/widgets/text_action_button.dart';
import 'package:frontend/features/auth/widgets/otp_input_row.dart';

class OtpVerificationView extends StatefulWidget {
  final String email;
  final DateTime? canResendAt;
  final bool isSending;
  final bool isVerifying;
  final ValueChanged<String>? onCompleted;
  final VoidCallback? onResend;
  final VoidCallback? onBack;

  const OtpVerificationView({
    super.key,
    required this.email,
    this.canResendAt,
    this.isSending = false,
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
  String _code = '';

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

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool get _canSubmit =>
      _code.length == 6 && !widget.isSending && !widget.isVerifying;

  bool get _canResend =>
      _remainingSeconds <= 0 && !widget.isSending && widget.onResend != null;

  String get _timerLabel {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get _timerProgress {
    if (_remainingSeconds <= 0) return 0;
    return (_remainingSeconds / 60).clamp(0, 1).toDouble();
  }

  void _startTimer() {
    _timer?.cancel();
    final canResendAt = widget.canResendAt;
    if (canResendAt == null) {
      if (mounted) setState(() => _remainingSeconds = 0);
      return;
    }

    void tick() {
      final seconds = canResendAt.difference(DateTime.now()).inSeconds;
      if (!mounted) return;
      setState(() => _remainingSeconds = seconds.clamp(0, 9999));
      if (_remainingSeconds <= 0) {
        _timer?.cancel();
      }
    }

    tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => tick());
  }

  void _submit() {
    if (!_canSubmit) return;
    widget.onCompleted?.call(_code);
  }

  @override
  Widget build(BuildContext context) {
    final actionLabel = widget.isVerifying
        ? 'Đang xác nhận...'
        : widget.isSending
        ? 'Đang gửi mã...'
        : 'Xác nhận';
    final resendLabel = widget.isSending
        ? 'Đang gửi lại...'
        : _canResend
        ? 'Gửi lại mã'
        : 'Gửi lại sau $_timerLabel';

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
                  minHeight: 640,
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
                              GlassIconButton(
                                icon: Icons.chevron_left,
                                onPressed: widget.isVerifying
                                    ? null
                                    : widget.onBack,
                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                              Text(
                                'XÁC THỰC',
                                style: AppTextStyles.labelSmall.copyWith(
                                  letterSpacing: 2,
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
                              const SizedBox(height: 12),
                              RichText(
                                text: TextSpan(
                                  style: AppTextStyles.bodyMedium,
                                  children: [
                                    const TextSpan(
                                      text:
                                          'Chúng tôi vừa gửi mã OTP gồm 6 chữ số đến ',
                                    ),
                                    TextSpan(
                                      text: widget.email,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const TextSpan(text: '.'),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 44),
                              OtpInputRow(
                                length: 6,
                                onChanged: (value) =>
                                    setState(() => _code = value),
                                onCompleted: (code) {
                                  setState(() => _code = code);
                                  _submit();
                                },
                              ),
                              const SizedBox(height: 40),
                              Opacity(
                                opacity: _canSubmit ? 1 : 0.55,
                                child: PrimaryButton(
                                  label: actionLabel,
                                  onPressed: _canSubmit ? _submit : null,
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
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (_remainingSeconds > 0) ...[
                                          SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              value: _timerProgress,
                                              backgroundColor:
                                                  AppColors.outlineVariant,
                                              valueColor:
                                                  const AlwaysStoppedAnimation<
                                                    Color
                                                  >(AppColors.primary),
                                              strokeWidth: 2.5,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                        ],
                                        Text(
                                          _remainingSeconds > 0
                                              ? 'Mã có hiệu lực trong $_timerLabel'
                                              : 'Bạn có thể yêu cầu mã mới',
                                          style: AppTextStyles.labelMedium
                                              .copyWith(
                                                color: AppColors.onSurface,
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  TextActionButton(
                                    label: resendLabel,
                                    onPressed: _canResend
                                        ? widget.onResend
                                        : null,
                                    foregroundColor: _canResend
                                        ? AppColors.primary
                                        : AppColors.onSurfaceVariant,
                                    textStyle: AppTextStyles.bodySmall.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: _canResend
                                          ? AppColors.primary
                                          : AppColors.onSurfaceVariant,
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
                                letterSpacing: 2,
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
