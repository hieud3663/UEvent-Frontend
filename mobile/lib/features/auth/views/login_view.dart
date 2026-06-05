import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:frontend/core/localization/app_localizations.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/primary_button.dart';
import 'package:frontend/core/widgets/social_login_button.dart';
import 'package:frontend/core/widgets/text_action_button.dart';
import 'package:url_launcher/url_launcher.dart';

final Uri _termsAndPoliciesUrl = Uri.parse(
  'https://uevent.u-code.dev/terms',
);

class LoginView extends StatefulWidget {
  final FutureOr<void> Function(String email)? onLoginWithEmail;
  final FutureOr<void> Function()? onLoginWithGoogle;
  final FutureOr<void> Function(String email)? onLoginWithPasskey;
  final String initialEmail;
  final bool preferPasskey;
  final bool passkeyAvailable;

  const LoginView({
    super.key,
    this.onLoginWithEmail,
    this.onLoginWithGoogle,
    this.onLoginWithPasskey,
    this.initialEmail = '',
    this.preferPasskey = false,
    this.passkeyAvailable = true,
  });

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _emailController;
  bool _isSubmittingEmail = false;
  bool _isSubmittingGoogle = false;
  bool _isSubmittingPasskey = false;

  bool get _isBusy =>
      _isSubmittingEmail || _isSubmittingGoogle || _isSubmittingPasskey;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void didUpdateWidget(covariant LoginView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_emailController.text.trim().isEmpty &&
        widget.initialEmail != oldWidget.initialEmail) {
      _emailController.text = widget.initialEmail;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitEmail() async {
    if (_isBusy || widget.onLoginWithEmail == null) return;

    setState(() => _isSubmittingEmail = true);
    try {
      await Future.sync(
        () => widget.onLoginWithEmail!(_emailController.text.trim()),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmittingEmail = false);
      }
    }
  }

  Future<void> _submitGoogle() async {
    if (_isBusy || widget.onLoginWithGoogle == null) return;

    setState(() => _isSubmittingGoogle = true);
    try {
      await Future.sync(widget.onLoginWithGoogle!);
    } finally {
      if (mounted) {
        setState(() => _isSubmittingGoogle = false);
      }
    }
  }

  Future<void> _submitPasskey() async {
    if (_isBusy || widget.onLoginWithPasskey == null) return;

    setState(() => _isSubmittingPasskey = true);
    try {
      await Future.sync(
        () => widget.onLoginWithPasskey!(_emailController.text.trim()),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmittingPasskey = false);
      }
    }
  }

  Future<void> _openTermsAndPolicies() async {
    await launchUrl(_termsAndPoliciesUrl, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final canUsePasskey =
        widget.passkeyAvailable && widget.onLoginWithPasskey != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.35,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/auth_header_bg.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(color: AppColors.primaryContainer);
                      },
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppColors.background.withValues(alpha: 0.8),
                            AppColors.background,
                          ],
                          stops: const [0.5, 0.8, 1],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -48),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(48),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(48),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(32, 40, 32, 40),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'UEvents',
                                style: AppTextStyles.headlineLarge,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                strings.loginSubtitle,
                                style: AppTextStyles.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 40),
                              if (widget.preferPasskey && canUsePasskey) ...[
                                PrimaryButton(
                                  label: strings.passkeyLogin,
                                  icon: Icons.fingerprint,
                                  isLoading: _isSubmittingPasskey,
                                  onPressed: _isBusy ? null : _submitPasskey,
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  strings.studentEmail,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(
                                    AppConstants.radiusMd,
                                  ),
                                  border: Border.all(
                                    color: AppColors.outlineVariant.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ),
                                child: TextField(
                                  controller: _emailController,
                                  enabled: !_isBusy,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: (_) => _submitEmail(),
                                  decoration: InputDecoration(
                                    hintText: 'yourname@university.edu',
                                    hintStyle: AppTextStyles.bodyMedium
                                        .copyWith(color: AppColors.outline),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 16,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              PrimaryButton(
                                label: _isSubmittingEmail
                                    ? strings.sendingCode
                                    : strings.emailContinue,
                                isLoading: _isSubmittingEmail,
                                onPressed: _isBusy ? null : _submitEmail,
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: AppColors.outlineVariant
                                          .withValues(alpha: 0.5),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Text(
                                      strings.or,
                                      style: AppTextStyles.labelSmall,
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: AppColors.outlineVariant
                                          .withValues(alpha: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              SocialLoginButton(
                                label: _isSubmittingGoogle
                                    ? strings.openingGoogle
                                    : strings.googleContinue,
                                iconPath: 'assets/images/google_icon.png',
                                isLoading: _isSubmittingGoogle,
                                onPressed: _isBusy ? null : _submitGoogle,
                              ),
                              if (!widget.preferPasskey && canUsePasskey) ...[
                                const SizedBox(height: 16),
                                TextActionButton(
                                  label: strings.passkeyLogin,
                                  height: 48,
                                  isLoading: _isSubmittingPasskey,
                                  onPressed: _isBusy ? null : _submitPasskey,
                                  foregroundColor: AppColors.onSurfaceVariant,
                                  icon: const Icon(Icons.fingerprint, size: 20),
                                  textStyle: AppTextStyles.titleSmall.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                              if (widget.preferPasskey && !canUsePasskey) ...[
                                const SizedBox(height: 16),
                                Text(
                                  strings.passkeyUnavailable,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                              // const SizedBox(height: 32),
                              // Row(
                              //   mainAxisAlignment: MainAxisAlignment.center,
                              //   children: [
                              //     Text(
                              //       'Chưa có tài khoản? ',
                              //       style: AppTextStyles.bodySmall.copyWith(
                              //         fontSize: 13,
                              //       ),
                              //     ),
                              //     TextActionButton(
                              //       label: 'Đăng ký ngay',
                              //       onPressed: _isBusy ? null : () {},
                              //       foregroundColor: AppColors.primary,
                              //       textStyle: AppTextStyles.bodySmall.copyWith(
                              //         fontSize: 13,
                              //         color: AppColors.primary,
                              //         fontWeight: FontWeight.w700,
                              //       ),
                              //     ),
                              //   ],
                              // ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -24),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: TextActionButton(
                    label: 'Điều khoản và chính sách của ứng dụng',
                    height: 44,
                    onPressed: _openTermsAndPolicies,
                    foregroundColor: AppColors.onSurfaceVariant,
                    textStyle: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
