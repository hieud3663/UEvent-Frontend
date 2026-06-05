import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/app_routes.dart';
import 'package:frontend/app/app_shell.dart';
import 'package:frontend/core/localization/app_localizations.dart';
import 'package:frontend/core/providers/service_providers.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/app_snack_bar.dart';
import 'package:frontend/features/app_setting/providers/app_setting_providers.dart';
import 'package:frontend/features/app_setting/widgets/app_lock_gate.dart';
import 'package:frontend/features/auth/controller/otp_controller.dart';
import 'package:frontend/features/auth/models/auth_failure.dart';
import 'package:frontend/features/auth/models/auth_method.dart';
import 'package:frontend/features/auth/models/user_model.dart';
import 'package:frontend/features/auth/providers/auth_providers.dart';
import 'package:frontend/features/auth/providers/otp_providers.dart';
import 'package:frontend/features/auth/views/login_view.dart';
import 'package:frontend/features/auth/views/otp_verification_view.dart';
import 'package:frontend/features/auth/views/passkey_setup_view.dart';
import 'package:frontend/features/auth/views/profile_setup_view.dart';
import 'package:frontend/features/auth/views/splash_view.dart';
import 'package:frontend/features/event_shared/providers/shared_event_link_provider.dart';
import 'package:frontend/features/profile/providers/profile_providers.dart';

class UEventsApp extends ConsumerStatefulWidget {
  const UEventsApp({super.key});

  @override
  ConsumerState<UEventsApp> createState() => _UEventsAppState();
}

class _UEventsAppState extends ConsumerState<UEventsApp> {
  final AppLinks _appLinks = AppLinks();
  final ValueNotifier<SplashProgress> _splashProgress =
      ValueNotifier(SplashProgress.initial());
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    unawaited(_loadInitialDeepLink());
    _linkSubscription = _appLinks.uriLinkStream.listen(_handleDeepLink);
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    _splashProgress.dispose();
    super.dispose();
  }

  Future<void> _loadInitialDeepLink() async {
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) {
        _handleDeepLink(uri);
      }
    } catch (_) {
      // Deep links are optional; startup should continue if the OS plugin fails.
    }
  }

  void _handleDeepLink(Uri uri) {
    final slug = _extractSharedEventSlug(uri);
    if (slug == null) return;
    ref.read(sharedEventSlugProvider.notifier).setSlug(slug);
  }

  @override
  Widget build(BuildContext context) {
    final appSettings = ref.watch(appSettingControllerProvider).value;

    return MaterialApp(
      title: 'UEvents',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: appSettings?.themeMode ?? ThemeMode.system,
      locale: appSettings?.locale,
      supportedLocales: const [Locale('vi'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        final reduceMotion = appSettings?.reduceMotionEnabled ?? false;

        return MediaQuery(
          data: mediaQuery.copyWith(
            disableAnimations: reduceMotion || mediaQuery.disableAnimations,
          ),
          child: AppSnackBarHost(
            child: AppLockGate(child: child ?? const SizedBox.shrink()),
          ),
        );
      },
      home: Builder(
        builder: (context) => SplashView(
          progressListenable: _splashProgress,
          onInitializationComplete: () {
            unawaited(
              _handleInitialSession(
                context,
                ref,
                splashProgress: _splashProgress,
              ),
            );
          },
        ),
      ),
    );
  }
}

String? _extractSharedEventSlug(Uri uri) {
  final segments = uri.pathSegments
      .map((segment) => segment.trim())
      .where((segment) => segment.isNotEmpty)
      .toList(growable: false);

  if (uri.scheme == 'uevent' && uri.host == 'events') {
    if (segments.length >= 2 && segments.first == 'share') return segments[1];
    if (segments.isNotEmpty) return segments.first;
  }

  if ((uri.scheme == 'http' || uri.scheme == 'https') &&
      segments.length >= 3 &&
      segments[0] == 'events' &&
      segments[1] == 'share') {
    return segments[2];
  }

  return null;
}

Future<void> _handleSignIn(
  BuildContext context,
  WidgetRef ref,
  AuthMethod method, {
  String? loginHint,
}) async {
  if (method == AuthMethod.email) {
    await _handleEmailOtpStart(context, ref, loginHint ?? '');
    return;
  }

  final effectiveLoginHint = method == AuthMethod.passkey ? null : loginHint;

  final session = await ref
      .read(authControllerProvider.notifier)
      .signIn(method, loginHint: effectiveLoginHint);
  if (!context.mounted) return;

  if (session != null) {
    final normalizedEmail = effectiveLoginHint?.trim().toLowerCase() ?? '';
    if (_isValidEmail(normalizedEmail)) {
      await ref
          .read(authLocalDataSourceProvider)
          .writeLastLoginEmail(normalizedEmail);
      ref.invalidate(lastLoginEmailProvider);
    }
    if (!context.mounted) return;
    await _bootstrapProfileAndNavigate(context, ref, fromSplash: false);
  } else {
    final state = ref.read(authControllerProvider);
    final message =
        state.whenOrNull(
          error: (err, _) =>
              err is AuthFailure ? err.displayMessage : err.toString(),
        ) ??
        'Đăng nhập thất bại.';

    if (state.error is! AuthFailureCancelled || method == AuthMethod.google) {
      _showSnackBar(
        context,
        state.error is AuthFailureCancelled && method == AuthMethod.google
            ? 'Đăng nhập Google đã bị hủy hoặc cấu hình Google Sign-In chưa đúng.'
            : message,
      );
    }
  }
}

Future<void> _handleEmailOtpStart(
  BuildContext context,
  WidgetRef ref,
  String email,
) async {
  final normalizedEmail = email.trim().toLowerCase();
  if (!_isValidEmail(normalizedEmail)) {
    _showSnackBar(context, 'Vui lòng nhập email hợp lệ.');
    return;
  }

  final otpController = ref.read(otpControllerProvider.notifier);
  otpController.reset();
  await otpController.sendOtp(normalizedEmail);
  if (!context.mounted) return;

  final otpState = ref.read(otpControllerProvider);
  switch (otpState) {
    case OtpSent():
      await ref
          .read(authLocalDataSourceProvider)
          .writeLastLoginEmail(normalizedEmail);
      ref.invalidate(lastLoginEmailProvider);
      if (!context.mounted) return;
      _navigateToOtp(context, ref, email: normalizedEmail, shouldReset: false);
    case OtpError(message: final message):
      _showSnackBar(context, message);
    default:
      _showSnackBar(context, 'Không gửi được mã OTP. Vui lòng thử lại.');
  }
}

bool _isValidEmail(String value) {
  return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
}

Future<void> _handleInitialSession(
  BuildContext context,
  WidgetRef ref, {
  ValueNotifier<SplashProgress>? splashProgress,
}) async {
  _setSplashProgress(
    splashProgress,
    0.2,
    'Đang kiểm tra phiên đăng nhập',
  );
  final session = await ref.read(authControllerProvider.future);
  if (!context.mounted) return;

  if (session == null) {
    _setSplashProgress(
      splashProgress,
      1.0,
      'Đang chuyển đến đăng nhập',
    );
    _navigateToLogin(context, ref);
    return;
  }

  await _bootstrapProfileAndNavigate(
    context,
    ref,
    fromSplash: true,
    splashProgress: splashProgress,
  );
}

Future<void> _bootstrapProfileAndNavigate(
  BuildContext context,
  WidgetRef ref, {
  required bool fromSplash,
  ValueNotifier<SplashProgress>? splashProgress,
}) async {
  try {
    _setSplashProgress(
      splashProgress,
      0.55,
      'Đang tải hồ sơ người dùng',
    );
    final user = await ref.read(profileServiceProvider).getMyProfile();
    if (!context.mounted) return;

    unawaited(_rememberUserEmail(ref, user.email));
    ref.invalidate(userProfileProvider);
    ref.invalidate(profileOverviewProvider);

    _setSplashProgress(
      splashProgress,
      0.85,
      'Đang chuẩn bị không gian làm việc',
    );

    if (user.isProfileComplete) {
      _setSplashProgress(
        splashProgress,
        1.0,
        'Sẵn sàng',
      );
      _navigateToAppShell(context);
    } else {
      _setSplashProgress(
        splashProgress,
        1.0,
        'Đang chuyển đến hoàn tất hồ sơ',
      );
      _navigateToProfileSetup(context, initialUser: user);
    }
  } on DioException catch (error) {
    await _handleProfileBootstrapFailure(
      context,
      ref,
      error,
      fromSplash: fromSplash,
      splashProgress: splashProgress,
    );
  } catch (_) {
    if (!context.mounted) return;
    _showSnackBar(context, 'Không thể tải hồ sơ. Vui lòng thử lại.');
    if (fromSplash) {
      _setSplashProgress(
        splashProgress,
        1.0,
        'Đang chuyển đến đăng nhập',
      );
      _navigateToLogin(context, ref);
    }
  }
}

Future<void> _rememberUserEmail(WidgetRef ref, String email) async {
  final normalizedEmail = email.trim().toLowerCase();
  if (!_isValidEmail(normalizedEmail)) return;
  await ref
      .read(authLocalDataSourceProvider)
      .writeLastLoginEmail(normalizedEmail);
  ref.invalidate(lastLoginEmailProvider);
}

Future<void> _handleProfileBootstrapFailure(
  BuildContext context,
  WidgetRef ref,
  DioException error, {
  required bool fromSplash,
  ValueNotifier<SplashProgress>? splashProgress,
}) async {
  final statusCode = error.response?.statusCode;
  final message = _profileBootstrapErrorMessage(error);
  final shouldClearSession =
      statusCode == 401 || statusCode == 403 || statusCode == 409;

  if (shouldClearSession) {
    await ref.read(authControllerProvider.notifier).forceSignOut();
  }

  if (!context.mounted) return;
  _showSnackBar(context, message);

  if (fromSplash || shouldClearSession) {
    _setSplashProgress(
      splashProgress,
      1.0,
      'Đang chuyển đến đăng nhập',
    );
    _navigateToLogin(context, ref);
  }
}

void _setSplashProgress(
  ValueNotifier<SplashProgress>? notifier,
  double value,
  String label,
) {
  if (notifier == null) return;
  notifier.value = SplashProgress(
    value: value.clamp(0.0, 1.0),
    label: label,
  );
}

String _profileBootstrapErrorMessage(DioException error) {
  final rawMessage = _extractApiMessage(error.response?.data);
  final normalized = rawMessage.toLowerCase();

  if (normalized.contains('email') &&
      (normalized.contains('verified') || normalized.contains('xác thực'))) {
    return 'Email chưa được xác thực. Vui lòng xác thực email trước khi đăng nhập.';
  }
  if (error.response?.statusCode == 409 || normalized.contains('conflict')) {
    return 'Tài khoản đang bị trùng dữ liệu. Vui lòng liên hệ quản trị viên.';
  }
  if (error.response?.statusCode == 401 || error.response?.statusCode == 403) {
    return 'Phiên đăng nhập không hợp lệ. Vui lòng đăng nhập lại.';
  }
  if (error.type == DioExceptionType.connectionError ||
      error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.receiveTimeout) {
    return 'Không thể kết nối máy chủ. Vui lòng kiểm tra mạng và thử lại.';
  }

  return rawMessage.isNotEmpty
      ? rawMessage
      : 'Không thể tải hồ sơ. Vui lòng thử lại.';
}

String _extractApiMessage(dynamic data) {
  if (data is Map<String, dynamic>) {
    final message = data['message'] ?? data['detail'];
    if (message is String && message.trim().isNotEmpty) {
      return message.trim();
    }
    final errors = data['errors'];
    if (errors is Map<String, dynamic>) {
      final detail = errors['detail'];
      if (detail is String && detail.trim().isNotEmpty) {
        return detail.trim();
      }
    }
  }
  return '';
}

void _showSnackBar(BuildContext context, String message) {
  showAppSnackBar(context, message);
}

void _navigateToLogin(BuildContext context, WidgetRef ref) {
  Navigator.of(context).pushAndRemoveUntil(
    appRoute(
      builder: (ctx) => Consumer(
        builder: (ctx, loginRef, _) {
          final passkeyAvailable =
              loginRef.watch(passkeyCapabilityProvider).value ?? false;
          final lastLoginEmail =
              loginRef.watch(lastLoginEmailProvider).value ?? '';

          return LoginView(
            initialEmail: lastLoginEmail,
            passkeyAvailable: passkeyAvailable,
            onLoginWithEmail: (email) =>
                _handleEmailOtpStart(ctx, loginRef, email),
            onLoginWithGoogle: () =>
                _handleSignIn(ctx, loginRef, AuthMethod.google),
            onLoginWithPasskey: (email) => _handleSignIn(
              ctx,
              loginRef,
              AuthMethod.passkey,
              loginHint: email,
            ),
          );
        },
      ),
    ),
    (route) => false,
  );
}

void _navigateToOtp(
  BuildContext context,
  WidgetRef ref, {
  required String email,
  bool shouldReset = true,
}) {
  if (shouldReset) {
    ref.read(otpControllerProvider.notifier).reset();
  }

  Navigator.of(context).push(
    appRoute(
      builder: (ctx) => Consumer(
        builder: (ctx, otpRef, _) {
          final otpState = otpRef.watch(otpControllerProvider);

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (otpRef.read(otpControllerProvider) is OtpIdle) {
              otpRef.read(otpControllerProvider.notifier).sendOtp(email);
            }
          });

          final sentEmail = switch (otpState) {
            OtpSent(email: final value) => value,
            OtpVerifying(email: final value) => value,
            OtpError(email: final value) => value,
            _ => email,
          };
          final canResendAt = switch (otpState) {
            OtpSent(canResendAt: final value) => value,
            OtpVerifying(canResendAt: final value) => value,
            OtpError(canResendAt: final value) => value,
            _ => null,
          };
          final isSending = otpState is OtpSending;
          final isVerifying = otpState is OtpVerifying;

          if (otpState is OtpVerified) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              if (ctx.mounted) {
                await _bootstrapProfileAndNavigate(
                  ctx,
                  otpRef,
                  fromSplash: false,
                );
              }
            });
          }

          if (otpState is OtpError) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (ctx.mounted) {
                _showSnackBar(ctx, otpState.message);
              }
            });
          }

          return OtpVerificationView(
            email: sentEmail,
            canResendAt: canResendAt,
            isSending: isSending,
            isVerifying: isVerifying,
            onCompleted: (code) =>
                otpRef.read(otpControllerProvider.notifier).verifyOtp(code),
            onResend: () =>
                otpRef.read(otpControllerProvider.notifier).sendOtp(sentEmail),
            onBack: () => Navigator.of(ctx).pop(),
          );
        },
      ),
    ),
  );
}

void _navigateToProfileSetup(BuildContext context, {UserModel? initialUser}) {
  Navigator.of(context).pushAndRemoveUntil(
    appRoute(
      builder: (ctx) => Consumer(
        builder: (ctx, setupRef, _) => ProfileSetupView(
          initialUser: initialUser,
          profileService: setupRef.read(profileServiceProvider),
          onComplete: (updatedUser) {
            setupRef.invalidate(userProfileProvider);
            setupRef.invalidate(profileOverviewProvider);

            if (updatedUser.isProfileComplete) {
              _navigateToAppShell(ctx);
              return;
            }

            unawaited(
              _bootstrapProfileAndNavigate(ctx, setupRef, fromSplash: false),
            );
          },
        ),
      ),
    ),
    (route) => false,
  );
}

// ignore: unused_element
void _navigateToPasskeySetup(BuildContext context) {
  Navigator.of(context).push(
    appRoute(
      builder: (ctx) => PasskeySetupView(
        onBack: () => Navigator.of(ctx).pop(),
        onPasskeyCreated: () => _navigateToAppShell(ctx),
      ),
    ),
  );
}

void _navigateToAppShell(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(
    appRoute(builder: (_) => const AppShell(onSignedOut: _navigateToLogin)),
    (route) => false,
  );
}
