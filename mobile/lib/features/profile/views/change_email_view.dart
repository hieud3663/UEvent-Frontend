import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/app_snack_bar.dart';
import 'package:frontend/core/widgets/glass_input_field.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/core/widgets/primary_button.dart';
import 'package:frontend/features/auth/models/user_model.dart';
import 'package:frontend/features/profile/services/profile_service.dart';

class ChangeEmailView extends StatefulWidget {
  final String currentEmail;
  final ProfileService? profileService;
  final VoidCallback? onBack;
  final ValueChanged<UserModel>? onChanged;

  const ChangeEmailView({
    super.key,
    required this.currentEmail,
    this.profileService,
    this.onBack,
    this.onChanged,
  });

  @override
  State<ChangeEmailView> createState() => _ChangeEmailViewState();
}

class _ChangeEmailViewState extends State<ChangeEmailView> {
  static final _otpInputFormatters = [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(6),
  ];

  final _currentOtpCtrl = TextEditingController();
  final _newEmailCtrl = TextEditingController();
  final _newEmailOtpCtrl = TextEditingController();

  bool _isSendingCurrentOtp = false;
  bool _isConfirmingNewEmail = false;
  bool _isUpdatingEmail = false;
  bool _newEmailOtpStep = false;
  int _currentOtpCooldownSeconds = 0;
  Timer? _currentOtpCooldownTimer;
  String? _error;

  @override
  void initState() {
    super.initState();
    _newEmailCtrl.addListener(_refreshState);
    _currentOtpCtrl.addListener(_refreshState);
    _newEmailOtpCtrl.addListener(_refreshNewEmailOtpState);
  }

  @override
  void dispose() {
    _currentOtpCooldownTimer?.cancel();
    _currentOtpCtrl.dispose();
    _newEmailCtrl.dispose();
    _newEmailOtpCtrl.dispose();
    super.dispose();
  }

  String get _currentEmail => widget.currentEmail.trim().toLowerCase();
  String get _newEmail => _newEmailCtrl.text.trim().toLowerCase();
  String get _currentOtpCode => _currentOtpCtrl.text.trim();
  String get _newEmailOtpCode => _newEmailOtpCtrl.text.trim();
  String get _currentOtpButtonLabel {
    if (_isSendingCurrentOtp) return 'Đang gửi...';
    if (_currentOtpCooldownSeconds > 0) {
      return 'Gửi lại sau ${_currentOtpCooldownSeconds}s';
    }
    return 'Gửi OTP email hiện tại';
  }

  bool get _isNewEmailValid =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(_newEmail);

  bool get _canConfirmNewEmail =>
      widget.profileService != null &&
      !_isConfirmingNewEmail &&
      !_isSendingCurrentOtp &&
      _currentOtpCode.length == 6 &&
      _isNewEmailValid &&
      _newEmail != _currentEmail;

  bool get _canSendCurrentOtp =>
      widget.profileService != null &&
      !_isSendingCurrentOtp &&
      _currentOtpCooldownSeconds == 0;

  bool get _canUpdateEmail =>
      widget.profileService != null &&
      !_isUpdatingEmail &&
      _newEmailOtpStep &&
      _newEmailOtpCode.length == 6;

  void _refreshState() {
    if (!mounted) return;
    setState(() {
      if (_error != null) _error = null;
      if (_newEmailOtpStep) {
        _newEmailOtpStep = false;
        _newEmailOtpCtrl.clear();
      }
    });
  }

  void _refreshNewEmailOtpState() {
    if (!mounted) return;
    setState(() {
      if (_error != null) _error = null;
    });
  }

  Future<void> _sendCurrentEmailOtp() async {
    if (!_canSendCurrentOtp) return;

    setState(() {
      _isSendingCurrentOtp = true;
      _error = null;
    });

    try {
      await widget.profileService!.requestEmailChangeOtp();
      if (!mounted) return;
      showAppSnackBar(
        context,
        'Mã OTP đã được gửi đến email hiện tại.',
        backgroundColor: AppColors.primary,
      );
      _startCurrentOtpCooldown();
    } on DioException catch (error) {
      if (!mounted) return;
      final retryAfter = _cooldownRemaining(error);
      if (retryAfter != null) _startCurrentOtpCooldown(retryAfter);
      setState(() => _error = _apiErrorMessage(error));
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Không thể gửi OTP. Vui lòng thử lại.');
    } finally {
      if (mounted) setState(() => _isSendingCurrentOtp = false);
    }
  }

  void _startCurrentOtpCooldown([int seconds = 60]) {
    _currentOtpCooldownTimer?.cancel();
    setState(() => _currentOtpCooldownSeconds = seconds);
    _currentOtpCooldownTimer = Timer.periodic(const Duration(seconds: 1), (
      timer,
    ) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_currentOtpCooldownSeconds <= 1) {
        timer.cancel();
        setState(() => _currentOtpCooldownSeconds = 0);
        return;
      }

      setState(() => _currentOtpCooldownSeconds--);
    });
  }

  Future<void> _confirmNewEmail() async {
    if (!_canConfirmNewEmail) {
      setState(() {
        if (_currentOtpCode.length != 6) {
          _error = 'Vui lòng nhập OTP email hiện tại gồm 6 số.';
        } else if (!_isNewEmailValid) {
          _error = 'Vui lòng nhập email mới hợp lệ.';
        } else {
          _error = 'Email mới phải khác email hiện tại.';
        }
      });
      return;
    }

    setState(() {
      _isConfirmingNewEmail = true;
      _error = null;
    });

    try {
      await widget.profileService!.requestNewEmailChangeOtp(
        newEmail: _newEmail,
        currentOtpCode: _currentOtpCode,
      );
      if (!mounted) return;
      setState(() => _newEmailOtpStep = true);
      showAppSnackBar(
        context,
        'Mã OTP đã được gửi đến email mới.',
        backgroundColor: AppColors.primary,
      );
    } on DioException catch (error) {
      if (!mounted) return;
      setState(() => _error = _apiErrorMessage(error));
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Không thể xác nhận email mới. Vui lòng thử lại.';
      });
    } finally {
      if (mounted) setState(() => _isConfirmingNewEmail = false);
    }
  }

  Future<void> _confirmEmailChange() async {
    if (!_canUpdateEmail) {
      setState(() => _error = 'Vui lòng nhập OTP email mới gồm 6 số.');
      return;
    }

    setState(() {
      _isUpdatingEmail = true;
      _error = null;
    });

    try {
      final user = await widget.profileService!.confirmEmailChange(
        newEmail: _newEmail,
        currentOtpCode: _currentOtpCode,
        newEmailOtpCode: _newEmailOtpCode,
      );
      if (!mounted) return;
      widget.onChanged?.call(user);
      showAppSnackBar(
        context,
        'Cập nhật email thành công.',
        backgroundColor: AppColors.primary,
      );
      widget.onBack?.call();
    } on DioException catch (error) {
      if (!mounted) return;
      setState(() => _error = _apiErrorMessage(error));
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Không thể cập nhật email. Vui lòng thử lại.');
    } finally {
      if (mounted) setState(() => _isUpdatingEmail = false);
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

  int? _cooldownRemaining(DioException error) {
    final data = error.response?.data;
    if (data is! Map<String, dynamic>) return null;
    final errors = data['errors'];
    if (errors is! Map) return null;
    final remaining = errors['cooldown_remaining'];
    if (remaining is int && remaining > 0) return remaining;
    if (remaining is num && remaining > 0) return remaining.ceil();
    return null;
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
                  child: _newEmailOtpStep
                      ? _buildNewEmailOtpStep()
                      : _buildCurrentEmailStep(),
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GlassTopBar(
              title: 'Đổi email',
              leadingIcon: Icons.chevron_left,
              onLeadingTap: _newEmailOtpStep
                  ? () => setState(() => _newEmailOtpStep = false)
                  : widget.onBack,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentEmailStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Xác nhận email hiện tại', style: AppTextStyles.headlineLarge),
        const SizedBox(height: 8),
        Text(
          'Gửi OTP đến $_currentEmail, nhập mã OTP rồi nhập email mới ở bên dưới.',
          style: AppTextStyles.bodyMedium,
        ),
        const SizedBox(height: 32),
        PrimaryButton(
          label: _currentOtpButtonLabel,
          isLoading: _isSendingCurrentOtp,
          onPressed: _canSendCurrentOtp ? _sendCurrentEmailOtp : null,
        ),
        const SizedBox(height: 24),
        GlassInputField(
          label: 'OTP email hiện tại',
          placeholder: 'Nhập mã OTP 6 số',
          leadingIcon: Icons.verified_user_outlined,
          controller: _currentOtpCtrl,
          keyboardType: TextInputType.number,
          inputFormatters: _otpInputFormatters,
        ),
        const SizedBox(height: 24),
        GlassInputField(
          label: 'Email mới',
          placeholder: 'Nhập email mới',
          leadingIcon: Icons.mail_outline,
          controller: _newEmailCtrl,
          keyboardType: TextInputType.emailAddress,
        ),
        if (_error != null) _buildError(),
        const SizedBox(height: 40),
        PrimaryButton(
          label: _isConfirmingNewEmail
              ? 'Đang xác nhận...'
              : 'Xác nhận email mới',
          isLoading: _isConfirmingNewEmail,
          onPressed: _canConfirmNewEmail ? _confirmNewEmail : null,
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildNewEmailOtpStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Xác nhận email mới', style: AppTextStyles.headlineLarge),
        const SizedBox(height: 8),
        Text(
          'Nhập OTP đã gửi đến $_newEmail để hoàn tất đổi email đăng nhập.',
          style: AppTextStyles.bodyMedium,
        ),
        const SizedBox(height: 32),
        GlassInputField(
          label: 'OTP email mới',
          placeholder: 'Nhập mã OTP 6 số',
          leadingIcon: Icons.mark_email_read_outlined,
          controller: _newEmailOtpCtrl,
          keyboardType: TextInputType.number,
          inputFormatters: _otpInputFormatters,
        ),
        if (_error != null) _buildError(),
        const SizedBox(height: 40),
        PrimaryButton(
          label: _isUpdatingEmail ? 'Đang cập nhật...' : 'Xác nhận đổi email',
          isLoading: _isUpdatingEmail,
          onPressed: _canUpdateEmail ? _confirmEmailChange : null,
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(
        _error!,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.error,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
      ),
    );
  }
}
