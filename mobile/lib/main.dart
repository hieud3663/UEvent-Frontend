import 'dart:io';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:frontend/core/providers/service_providers.dart';
import 'package:frontend/core/theme/app_theme.dart';

// Auth Flow
import 'package:frontend/features/auth/models/auth_failure.dart';
import 'package:frontend/features/auth/models/auth_method.dart';
import 'package:frontend/features/auth/models/user_model.dart';
import 'package:frontend/features/auth/providers/auth_providers.dart';
import 'package:frontend/features/auth/views/splash_view.dart';
import 'package:frontend/features/auth/views/login_view.dart';
import 'package:frontend/features/auth/views/otp_verification_view.dart';
import 'package:frontend/features/auth/views/profile_setup_view.dart';
import 'package:frontend/features/auth/views/passkey_setup_view.dart';

// Shell & Tabs
import 'package:frontend/features/events/views/home_view.dart';
import 'package:frontend/features/events/views/discovery_view.dart';
import 'package:frontend/features/events/views/invite_guests_view.dart';
import 'package:frontend/features/events/views/send_notification_view.dart';
import 'package:frontend/features/notifications/views/notifications_view.dart';
import 'package:frontend/features/notifications/providers/notification_providers.dart';
import 'package:frontend/features/profile/views/settings_view.dart';
import 'package:frontend/features/profile/providers/profile_providers.dart';
import 'package:frontend/features/ticketing/views/my_tickets_view.dart';
import 'package:frontend/features/events/views/empty_search_view.dart';

// Profile (push navigation from Settings)
import 'package:frontend/features/profile/views/user_profile_view.dart';
import 'package:frontend/features/profile/views/edit_profile_view.dart';
import 'package:frontend/features/profile/views/change_email_view.dart';
import 'package:frontend/features/profile/views/help_center_view.dart';
import 'package:frontend/features/profile/views/send_feedback_view.dart';
import 'package:frontend/features/profile/views/privacy_policy_view.dart';
import 'package:frontend/features/profile/views/sync_contacts_view.dart';

// Event Attendee & General
import 'package:frontend/features/events/views/event_detail_screen.dart';
import 'package:frontend/features/events/views/registration_confirmation_screen.dart';
import 'package:frontend/features/events/views/registration_success_screen.dart';
import 'package:frontend/features/events/views/ask_question_screen.dart';
import 'package:frontend/features/events/views/share_event_sheet.dart';

// Ticketing
import 'package:frontend/features/ticketing/models/ticket_model.dart';
import 'package:frontend/features/ticketing/views/ticket_detail_view.dart';
import 'package:frontend/features/ticketing/views/past_event_detail_view.dart';
import 'package:frontend/features/ticketing/views/cancel_confirmation_sheet.dart';
import 'package:frontend/features/ticketing/views/cancel_error_dialog.dart';
import 'package:frontend/features/ticketing/views/qr_scanner_view.dart';

// Event Organizer
import 'package:frontend/features/events/views/create_event_view.dart';
import 'package:frontend/features/events/views/event_detail_organizer_view.dart';
import 'package:frontend/features/events/views/manage_event_hub_view.dart';
import 'package:frontend/features/events/views/edit_event_details_view.dart';
import 'package:frontend/features/events/views/manage_team_view.dart';
import 'package:frontend/features/events/views/archive_event_view.dart';
import 'package:frontend/features/events/views/attendee_list_view.dart';
import 'package:frontend/features/events/views/export_attendee_list_view.dart';
import 'package:frontend/features/events/views/registration_questions_view.dart';
import 'package:frontend/features/events/views/question_detail_view.dart';
import 'package:frontend/features/events/models/event_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _configureDisplayMode();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const ProviderScope(child: UEventsApp()));
}

Future<void> _configureDisplayMode() async {
  if (kIsWeb || !Platform.isAndroid) return;
  try {
    await FlutterDisplayMode.setHighRefreshRate();
  } catch (_) {
    // Ignore device-specific failures and continue app startup.
  }
}

PageRoute<T> _fastRoute<T>({required WidgetBuilder builder}) {
  return MaterialPageRoute<T>(builder: builder);
}

// ════════════════════════════════════════════════════════════════════
// AUTH FLOW NAVIGATION
// Top-level functions reused by both initial auth flow AND sign-out.
// Each function captures the builder's `ctx` for subsequent navigation.
// ════════════════════════════════════════════════════════════════════

/// Triggers the Keycloak PKCE sign-in flow for the given [method],
/// then navigates to AppShell on success or shows a snackbar on failure.
Future<void> _handleSignIn(
  BuildContext context,
  WidgetRef ref,
  AuthMethod method, {
  String? loginHint,
}) async {
  final session = await ref
      .read(authControllerProvider.notifier)
      .signIn(method, loginHint: loginHint);
  if (!context.mounted) return;

  if (session != null) {
    await _bootstrapProfileAndNavigate(context, ref, fromSplash: false);
  } else {
    // Read the error from the controller state for the snackbar.
    final state = ref.read(authControllerProvider);
    final message =
        state.whenOrNull(
          error: (err, _) =>
              err is AuthFailure ? err.displayMessage : err.toString(),
        ) ??
        'Đăng nhập thất bại.';

    if (state.error is! AuthFailureCancelled || method == AuthMethod.google) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state.error is AuthFailureCancelled && method == AuthMethod.google
                ? 'Đăng nhập Google đã bị hủy hoặc cấu hình Google Sign-In chưa đúng.'
                : message,
          ),
        ),
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

  final sent = await ref
      .read(authControllerProvider.notifier)
      .requestEmailOtp(normalizedEmail);
  if (!context.mounted) return;

  if (sent) {
    _navigateToOtp(context, ref, normalizedEmail);
    return;
  }

  _showSnackBar(context, _authStateErrorMessage(ref));
}

Future<void> _handleEmailOtpVerify(
  BuildContext context,
  WidgetRef ref, {
  required String email,
  required String code,
}) async {
  final session = await ref
      .read(authControllerProvider.notifier)
      .verifyEmailOtp(email: email, code: code);
  if (!context.mounted) return;

  if (session != null) {
    await _bootstrapProfileAndNavigate(context, ref, fromSplash: false);
    return;
  }

  _showSnackBar(context, _authStateErrorMessage(ref));
}

Future<void> _handleEmailOtpResend(
  BuildContext context,
  WidgetRef ref,
  String email,
) async {
  final sent = await ref
      .read(authControllerProvider.notifier)
      .requestEmailOtp(email);
  if (!context.mounted) return;

  _showSnackBar(
    context,
    sent ? 'Mã OTP mới đã được gửi.' : _authStateErrorMessage(ref),
  );
}

bool _isValidEmail(String value) {
  return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
}

String _authStateErrorMessage(WidgetRef ref) {
  final state = ref.read(authControllerProvider);
  return state.whenOrNull(
        error: (err, _) =>
            err is AuthFailure ? err.displayMessage : err.toString(),
      ) ??
      'Đăng nhập thất bại. Vui lòng thử lại.';
}

Future<void> _handleInitialSession(BuildContext context, WidgetRef ref) async {
  final session = await ref.read(authControllerProvider.future);
  if (!context.mounted) return;

  if (session == null) {
    _navigateToLogin(context, ref);
    return;
  }

  await _bootstrapProfileAndNavigate(context, ref, fromSplash: true);
}

Future<void> _bootstrapProfileAndNavigate(
  BuildContext context,
  WidgetRef ref, {
  required bool fromSplash,
}) async {
  try {
    final user = await ref.read(profileServiceProvider).getMyProfile();
    if (!context.mounted) return;

    ref.invalidate(userProfileProvider);
    ref.invalidate(profileOverviewProvider);

    if (user.isProfileComplete) {
      _navigateToAppShell(context);
    } else {
      _navigateToProfileSetup(context, ref: ref, initialUser: user);
    }
  } on DioException catch (error) {
    await _handleProfileBootstrapFailure(
      context,
      ref,
      error,
      fromSplash: fromSplash,
    );
  } catch (_) {
    if (!context.mounted) return;
    _showSnackBar(context, 'Không thể tải hồ sơ. Vui lòng thử lại.');
    if (fromSplash) {
      _navigateToLogin(context, ref);
    }
  }
}

Future<void> _handleProfileBootstrapFailure(
  BuildContext context,
  WidgetRef ref,
  DioException error, {
  required bool fromSplash,
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
    _navigateToLogin(context, ref);
  }
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
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

void _navigateToLogin(BuildContext context, WidgetRef ref) {
  Navigator.of(context).pushAndRemoveUntil(
    _fastRoute(
      builder: (ctx) => Consumer(
        builder: (ctx, loginRef, _) => LoginView(
          onLoginWithEmail: (email) =>
              _handleEmailOtpStart(ctx, loginRef, email),
          onLoginWithGoogle: () =>
              _handleSignIn(ctx, loginRef, AuthMethod.google),
          onLoginWithPasskey: () =>
              _handleSignIn(ctx, loginRef, AuthMethod.passkey),
        ),
      ),
    ),
    (route) => false,
  );
}

void _navigateToOtp(BuildContext context, WidgetRef ref, String email) {
  Navigator.of(context).push(
    _fastRoute(
      builder: (ctx) => OtpVerificationView(
        email: email,
        onVerify: (code) =>
            _handleEmailOtpVerify(ctx, ref, email: email, code: code),
        onBack: () => Navigator.of(ctx).pop(),
        onResend: () => _handleEmailOtpResend(ctx, ref, email),
      ),
    ),
  );
}

void _navigateToProfileSetup(
  BuildContext context, {
  WidgetRef? ref,
  UserModel? initialUser,
}) {
  Navigator.of(context).push(
    _fastRoute(
      builder: (ctx) => ProfileSetupView(
        initialUser: initialUser,
        onComplete: () {
          if (ref == null) {
            _navigateToAppShell(ctx);
            return;
          }
          unawaited(_bootstrapProfileAndNavigate(ctx, ref, fromSplash: false));
        },
        onBack: () => Navigator.of(ctx).pop(),
      ),
    ),
  );
}

// ignore: unused_element
void _navigateToPasskeySetup(BuildContext context) {
  Navigator.of(context).push(
    _fastRoute(
      builder: (ctx) => PasskeySetupView(
        onBack: () => Navigator.of(ctx).pop(),
        onCreatePasskey: () => _navigateToAppShell(ctx),
      ),
    ),
  );
}

void _navigateToAppShell(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(
    _fastRoute(builder: (_) => const AppShell()),
    (route) => false,
  );
}

// ════════════════════════════════════════════════════════════════════
// APP ROOT
// ════════════════════════════════════════════════════════════════════

class UEventsApp extends ConsumerWidget {
  const UEventsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'UEvents',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // Splash → check stored session → Login or AppShell
      home: Builder(
        builder: (context) => SplashView(
          onInitializationComplete: () {
            unawaited(_handleInitialSession(context, ref));
          },
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// APP SHELL – Bottom Nav Tabs + Push Navigation
// ════════════════════════════════════════════════════════════════════

/// App shell that manages bottom nav tab switching + push navigation.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(
        ref
            .read(pushNotificationControllerProvider.notifier)
            .registerCurrentDevice(),
      );
    });
  }

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
  }

  // ── Push Navigation (General) ──

  void _pushNotifications() {
    Navigator.of(context).push(
      _fastRoute(
        builder: (_) => NotificationsView(
          currentNavIndex: _currentIndex,
          onNavTap: (i) {
            Navigator.of(context).pop();
            _onNavTap(i);
          },
          onBack: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  void _pushProfile() {
    Navigator.of(context).push(
      _fastRoute(
        builder: (_) =>
            UserProfileView(onBack: () => Navigator.of(context).pop()),
      ),
    );
  }

  void _pushEmptySearch() {
    Navigator.of(context).push(
      _fastRoute(
        builder: (_) => EmptySearchView(
          currentNavIndex: _currentIndex,
          onNavTap: (i) {
            Navigator.of(context).pop();
            _onNavTap(i);
          },
          onBack: () => Navigator.of(context).pop(),
          onGoHome: () {
            Navigator.of(context).pop();
            _onNavTap(0);
          },
        ),
      ),
    );
  }

  // ── Attendee Flow ──

  void _pushEventDetail(EventModel event) {
    if (event.isOrganizer) {
      // User is the organizer - show organizer view
      Navigator.of(context).push(
        _fastRoute(
          builder: (ctx) => EventDetailOrganizerView(
            onBack: () => Navigator.of(ctx).pop(),
            onCheckIn: _pushQrScanner,
            onInvite: () =>
                _pushInviteGuests(event), // TODO: Navigate to invite screen
            onNotify: () => _pushSendNotification(
              event,
            ), // TODO: Navigate to send notification screen
            onManage: _pushManageEventHub,
            onShare: () => ShareEventSheet.show(ctx),
          ),
        ),
      );
    } else {
      // User is attendee/discovering - show attendee view
      Navigator.of(context).push(
        _fastRoute(
          builder: (ctx) => EventDetailScreen(
            onBack: () => Navigator.of(ctx).pop(),
            onShare: () => ShareEventSheet.show(ctx),
            onRegister: () => _pushRegistrationConfirmation(ctx),
            onAskQuestion: () => _pushAskQuestion(ctx),
          ),
        ),
      );
    }
  }

  void _pushRegistrationConfirmation(BuildContext ctx) {
    RegistrationConfirmationScreen.show(
      ctx,
      eventName: 'Global Developer Summit 2024',
      onConfirm: () {
        Navigator.of(ctx).pop(); // close sheet
        _pushRegistrationSuccess(ctx);
      },
    );
  }

  void _pushRegistrationSuccess(BuildContext ctx) {
    Navigator.of(ctx).push(
      _fastRoute(
        builder: (_) => RegistrationSuccessScreen(
          eventName: 'Global Developer Summit 2024',
          ticketId: '#UE-98210',
          onViewTicket: () => Navigator.of(ctx).pop(),
          onAddToWallet: () {},
        ),
      ),
    );
  }

  void _pushAskQuestion(BuildContext ctx) {
    Navigator.of(ctx).push(
      _fastRoute(
        builder: (_) => AskQuestionScreen(
          onBack: () => Navigator.of(ctx).pop(),
          onSend: (q, anon, notify) {},
        ),
      ),
    );
  }

  // ── Ticketing Flow ──

  void _pushTicketDetail(TicketModel ticket) {
    Navigator.of(context).push(
      _fastRoute(
        builder: (ctx) => TicketDetailView(
          ticket: ticket,
          onBack: () => Navigator.of(ctx).pop(),
          onCancelTap: () => _showCancelConfirmation(ctx, ticket),
        ),
      ),
    );
  }

  void _showCancelConfirmation(BuildContext ctx, TicketModel ticket) {
    CancelConfirmationSheet.show(
      ctx,
      eventName: ticket.eventName,
      onConfirm: () {
        Navigator.of(ctx).pop(); // close sheet
        CancelErrorDialog.show(ctx);
      },
    );
  }

  void _pushPastEventDetail(TicketModel ticket) {
    Navigator.of(context).push(
      _fastRoute(
        builder: (ctx) => PastEventDetailView(
          ticket: ticket,
          onBack: () => Navigator.of(ctx).pop(),
        ),
      ),
    );
  }

  // ── Organizer Flow ──

  void _pushCreateEvent() {
    Navigator.of(context).push(
      _fastRoute(
        builder: (_) =>
            CreateEventView(onBack: () => Navigator.of(context).pop()),
      ),
    );
  }

  void _pushInviteGuests(EventModel event) {
    Navigator.of(context).push(
      _fastRoute(
        builder: (_) =>
            InviteGuestsView(onBack: () => Navigator.of(context).pop()),
      ),
    );
  }

  void _pushSendNotification(EventModel event) {
    Navigator.of(context).push(
      _fastRoute(
        builder: (_) =>
            SendNotificationView(onBack: () => Navigator.of(context).pop()),
      ),
    );
  }

  void _pushManageEventHub() {
    Navigator.of(context).push(
      _fastRoute(
        builder: (_) => ManageEventHubView(
          onBack: () => Navigator.of(context).pop(),
          onEditDetailsTap: _pushEditEventDetails,
          onManageTeamTap: _pushManageTeam,
          onArchiveTap: _pushArchiveEvent,
          onAttendeeListTap: _pushAttendeeList,
          onRegistrationQuestionsTap: _pushRegistrationQuestions,
          onParticipantCheckInTap: _pushQrScanner,
          onExportAttendeeListTap: _pushExportAttendeeList,
        ),
      ),
    );
  }

  void _pushEditEventDetails() {
    Navigator.of(context).push(
      _fastRoute(
        builder: (ctx) =>
            EditEventDetailsView(onBack: () => Navigator.of(ctx).pop()),
      ),
    );
  }

  void _pushManageTeam() {
    Navigator.of(context).push(
      _fastRoute(
        builder: (ctx) => ManageTeamView(onBack: () => Navigator.of(ctx).pop()),
      ),
    );
  }

  void _pushArchiveEvent() {
    Navigator.of(context).push(
      _fastRoute(
        builder: (ctx) =>
            ArchiveEventView(onBack: () => Navigator.of(ctx).pop()),
      ),
    );
  }

  void _pushAttendeeList() {
    Navigator.of(context).push(
      _fastRoute(
        builder: (ctx) =>
            AttendeeListView(onBack: () => Navigator.of(ctx).pop()),
      ),
    );
  }

  void _pushExportAttendeeList() {
    Navigator.of(context).push(
      _fastRoute(
        builder: (ctx) =>
            ExportAttendeeListView(onClose: () => Navigator.of(ctx).pop()),
      ),
    );
  }

  void _pushRegistrationQuestions() {
    Navigator.of(context).push(
      _fastRoute(
        builder: (ctx) => RegistrationQuestionsView(
          onBack: () => Navigator.of(ctx).pop(),
          onQuestionTap: () => _pushQuestionDetail(),
        ),
      ),
    );
  }

  void _pushQuestionDetail() {
    Navigator.of(context).push(
      _fastRoute(
        builder: (ctx) =>
            QuestionDetailView(onBack: () => Navigator.of(ctx).pop()),
      ),
    );
  }

  void _pushQrScanner() {
    Navigator.of(context).push(
      _fastRoute(
        builder: (ctx) => QrScannerView(onBack: () => Navigator.of(ctx).pop()),
      ),
    );
  }

  // ── Profile / Settings Sub-Navigation ──

  void _pushEditProfile() {
    Navigator.of(context).push(
      _fastRoute(
        builder: (ctx) => EditProfileView(
          onBack: () => Navigator.of(ctx).pop(),
          onSave: () => Navigator.of(ctx).pop(),
        ),
      ),
    );
  }

  void _pushChangeEmail() {
    Navigator.of(context).push(
      _fastRoute(
        builder: (ctx) => ChangeEmailView(
          onBack: () => Navigator.of(ctx).pop(),
          onSave: () => Navigator.of(ctx).pop(),
        ),
      ),
    );
  }

  void _pushPasskeyLogin() {
    Navigator.of(context).push(
      _fastRoute(
        builder: (ctx) => PasskeySetupView(
          onBack: () => Navigator.of(ctx).pop(),
          onCreatePasskey: () => Navigator.of(ctx).pop(),
        ),
      ),
    );
  }

  void _pushHelpCenter() {
    Navigator.of(context).push(
      _fastRoute(
        builder: (ctx) => HelpCenterView(onBack: () => Navigator.of(ctx).pop()),
      ),
    );
  }

  void _pushSendFeedback() {
    Navigator.of(context).push(
      _fastRoute(
        builder: (ctx) => SendFeedbackView(
          onBack: () => Navigator.of(ctx).pop(),
          onSubmit: () => Navigator.of(ctx).pop(),
        ),
      ),
    );
  }

  void _pushPrivacyPolicy() {
    Navigator.of(context).push(
      _fastRoute(
        builder: (ctx) =>
            PrivacyPolicyView(onBack: () => Navigator.of(ctx).pop()),
      ),
    );
  }

  void _pushSyncContacts() {
    Navigator.of(context).push(
      _fastRoute(
        builder: (ctx) => SyncContactsView(
          onBack: () => Navigator.of(ctx).pop(),
          onSync: () => Navigator.of(ctx).pop(),
        ),
      ),
    );
  }

  void _signOut() {
    // Sign out is handled in _AppShellState which doesn't have WidgetRef.
    // We navigate to a transient route that triggers sign-out via Consumer.
    Navigator.of(context).pushAndRemoveUntil(
      _fastRoute(
        builder: (_) => Consumer(
          builder: (ctx, ref, _) {
            // Fire sign-out and navigate to login.
            Future.microtask(() async {
              await ref
                  .read(pushNotificationControllerProvider.notifier)
                  .unregisterCurrentDevice();
              await ref.read(authControllerProvider.notifier).signOut();
              if (ctx.mounted) _navigateToLogin(ctx, ref);
            });
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          },
        ),
      ),
      (route) => false,
    );
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: _currentIndex,
      children: [
        // Tab 0: HOME
        HomeView(
          currentNavIndex: _currentIndex,
          onNavTap: _onNavTap,
          onNotificationsTap: _pushNotifications,
          onProfileTap: _pushProfile,
          onCreateEventTap: _pushCreateEvent,
          onEventTap: _pushEventDetail,
        ),
        // Tab 1: DISCOVER
        DiscoveryView(
          currentNavIndex: _currentIndex,
          onNavTap: _onNavTap,
          onNotificationsTap: _pushNotifications,
          onProfileTap: _pushProfile,
          onSearchEmpty: _pushEmptySearch,
          onEventTap: _pushEventDetail,
        ),
        // Tab 2: TICKETS
        MyTicketsView(
          currentNavIndex: _currentIndex,
          onNavTap: _onNavTap,
          onTicketTap: _pushTicketDetail,
          onPastTicketTap: _pushPastEventDetail,
          onScanTap: _pushQrScanner,
        ),
        // Tab 3: SETTINGS
        SettingsView(
          currentNavIndex: _currentIndex,
          onNavTap: _onNavTap,
          onBack: () => _onNavTap(0), // Close → go Home
          onEditProfile: _pushEditProfile,
          onChangeEmail: _pushChangeEmail,
          onPasskeyLogin: _pushPasskeyLogin,
          onTwoFactorAuth: () {}, // TODO: Navigate to 2FA screen
          onHelpCenter: _pushHelpCenter,
          onSendFeedback: _pushSendFeedback,
          onPrivacyPolicy: _pushPrivacyPolicy,
          onSyncContacts: _pushSyncContacts,
          onSignOut: _signOut,
        ),
      ],
    );
  }
}
