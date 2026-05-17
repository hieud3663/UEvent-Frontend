import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_theme.dart';

// Auth Flow
import 'package:frontend/features/auth/models/auth_failure.dart';
import 'package:frontend/features/auth/models/auth_method.dart';
import 'package:frontend/core/providers/service_providers.dart';
import 'package:frontend/features/auth/providers/auth_providers.dart';
import 'package:frontend/features/auth/providers/otp_providers.dart';
import 'package:frontend/features/auth/controller/otp_controller.dart';
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
import 'package:frontend/features/profile/views/settings_view.dart';
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
import 'package:frontend/features/profile/providers/profile_providers.dart';

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

/// Fetches the user profile and routes to ProfileSetupView or AppShell
/// depending on whether [isProfileComplete] is true.
///
/// Called after both a fresh sign-in and a session restore, ensuring the
/// check runs every time the app reaches an authenticated state.
Future<void> _routeAfterAuth(BuildContext context, WidgetRef ref) async {
  try {
    final profileService = ref.read(profileServiceProvider);
    final user = await profileService.getMyProfile();
    if (!context.mounted) return;

    if (user.isProfileComplete) {
      _navigateToAppShell(context);
    } else {
      _navigateToProfileSetup(context);
    }
  } catch (_) {
    // Nếu không lấy được profile (mạng lỗi, token hết hạn, v.v.),
    // vẫn cho vào Home — ApiClient interceptor sẽ xử lý 401 tự động.
    if (context.mounted) _navigateToAppShell(context);
  }
}

/// Triggers the Keycloak PKCE sign-in flow for the given [method],
/// then checks profile completion and navigates accordingly.
Future<void> _handleSignIn(
  BuildContext context,
  WidgetRef ref,
  AuthMethod method, {
  String? loginHint,
}) async {
  // Email method → native OTP flow (không dùng Keycloak browser)
  if (method == AuthMethod.email) {
    _navigateToOtp(context, ref, email: loginHint ?? '');
    return;
  }

  // Google / Passkey → PKCE browser flow như cũ
  final session =
      await ref.read(authControllerProvider.notifier).signIn(method, loginHint: loginHint);
  if (!context.mounted) return;

  if (session != null) {
    await _routeAfterAuth(context, ref);
  } else {
    final state = ref.read(authControllerProvider);
    final message = state.whenOrNull(
          error: (err, _) =>
              err is AuthFailure ? err.displayMessage : err.toString(),
        ) ??
        'Đăng nhập thất bại.';

    if (state.error is! AuthFailureCancelled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}

void _navigateToLogin(BuildContext context, WidgetRef ref) {
  Navigator.of(context).pushAndRemoveUntil(
    _fastRoute(
      builder: (ctx) => Consumer(
        builder: (ctx, loginRef, _) => LoginView(
          onLoginWithEmail: (email) => _handleSignIn(ctx, loginRef, AuthMethod.email, loginHint: email),
          onLoginWithGoogle: () => _handleSignIn(ctx, loginRef, AuthMethod.google),
          onLoginWithPasskey: () => _handleSignIn(ctx, loginRef, AuthMethod.passkey),
        ),
      ),
    ),
    (route) => false,
  );
}

/// Điều hướng đến OTP screen và wire toàn bộ luồng Send → Verify.
///
/// [email] là địa chỉ user đã nhập ở LoginView.
/// OtpController tự động gửi OTP khi push xong.
void _navigateToOtp(BuildContext context, WidgetRef ref, {required String email}) {
  // Reset controller trước khi bắt đầu flow mới
  ref.read(otpControllerProvider.notifier).reset();

  Navigator.of(context).push(_fastRoute(
    builder: (ctx) => Consumer(
      builder: (ctx, otpRef, _) {
        final otpState = otpRef.watch(otpControllerProvider);

        // Gửi OTP ngay khi màn hình mount
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (otpRef.read(otpControllerProvider) is OtpIdle) {
            otpRef.read(otpControllerProvider.notifier).sendOtp(email);
          }
        });

        // Lấy metadata từ state
        final sentEmail = switch (otpState) {
          OtpSent(email: final e) => e,
          OtpVerifying() => email,
          OtpVerified() => email,
          OtpError() => email,
          _ => email,
        };
        final canResendAt = otpState is OtpSent ? otpState.canResendAt : null;
        final isVerifying = otpState is OtpVerifying;

        // Điều hướng sau khi verify xong
        if (otpState is OtpVerified) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (ctx.mounted) await _routeAfterAuth(ctx, otpRef);
          });
        }

        // Hiển thị error snackbar nếu có
        if (otpState is OtpError) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (ctx.mounted) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(content: Text(otpState.message)),
              );
            }
          });
        }

        return OtpVerificationView(
          email: sentEmail,
          canResendAt: canResendAt,
          isVerifying: isVerifying,
          onCompleted: (code) =>
              otpRef.read(otpControllerProvider.notifier).verifyOtp(code),
          onResend: () =>
              otpRef.read(otpControllerProvider.notifier).sendOtp(sentEmail),
          onBack: () => Navigator.of(ctx).pop(),
        );
      },
    ),
  ));
}

void _navigateToProfileSetup(BuildContext context) {
  // pushAndRemoveUntil: user không thể back về Login sau khi đã xác thực.
  Navigator.of(context).pushAndRemoveUntil(
    _fastRoute(
      builder: (ctx) => Consumer(
        builder: (ctx, ref, _) => ProfileSetupView(
          profileService: ref.read(profileServiceProvider),
          onComplete: () async {
            // Sau khi lưu profile, invalidate cache và về Home.
            ref.invalidate(profileServiceProvider);
            if (ctx.mounted) _navigateToAppShell(ctx);
          },
          // Không có onBack — user bắt buộc phải hoàn thiện hồ sơ
        ),
      ),
    ),
    (route) => false,
  );
}

void _navigateToPasskeySetup(BuildContext context) {
  Navigator.of(context).push(_fastRoute(
    builder: (ctx) => PasskeySetupView(
      onBack: () => Navigator.of(ctx).pop(),
      onCreatePasskey: () => _navigateToAppShell(ctx),
    ),
  ));
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
      // Splash → check stored session → Login, ProfileSetup, or AppShell
      home: Builder(
        builder: (context) => SplashView(
          onInitializationComplete: () async {
            // Check if a valid session exists from a previous run.
            final authState = ref.read(authControllerProvider);
            final session = authState.whenData((s) => s).value;
            final hasSession = session != null && !session.isExpired;
            if (!context.mounted) return;

            if (hasSession) {
              // Session còn hạn → check profile trước khi vào Home.
              await _routeAfterAuth(context, ref);
            } else {
              _navigateToLogin(context, ref);
            }
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
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
  }

  // ── Push Navigation (General) ──

  void _pushNotifications() {
    Navigator.of(context).push(_fastRoute(
      builder: (_) => NotificationsView(
        currentNavIndex: _currentIndex,
        onNavTap: (i) {
          Navigator.of(context).pop();
          _onNavTap(i);
        },
        onBack: () => Navigator.of(context).pop(),
      ),
    ));
  }

  void _pushProfile() {
    Navigator.of(context).push(_fastRoute(
      builder: (_) => UserProfileView(
        onBack: () => Navigator.of(context).pop(),
      ),
    ));
  }

  void _pushEmptySearch() {
    Navigator.of(context).push(_fastRoute(
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
    ));
  }

  // ── Attendee Flow ──

  void _pushEventDetail(EventModel event) {
    if (event.isOrganizer) {
      // User is the organizer - show organizer view
      Navigator.of(context).push(_fastRoute(
        builder: (ctx) => EventDetailOrganizerView(
          onBack: () => Navigator.of(ctx).pop(),
          onCheckIn: _pushQrScanner,
          onInvite: () => _pushInviteGuests(event), // TODO: Navigate to invite screen
          onNotify: () => _pushSendNotification(event), // TODO: Navigate to send notification screen
          onManage: _pushManageEventHub,
          onShare: () => ShareEventSheet.show(ctx),
        ),
      ));
    } else {
      // User is attendee/discovering - show attendee view
      Navigator.of(context).push(_fastRoute(
        builder: (ctx) => EventDetailScreen(
          onBack: () => Navigator.of(ctx).pop(),
          onShare: () => ShareEventSheet.show(ctx),
          onRegister: () => _pushRegistrationConfirmation(ctx),
          onAskQuestion: () => _pushAskQuestion(ctx),
        ),
      ));
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
    Navigator.of(ctx).push(_fastRoute(
      builder: (_) => RegistrationSuccessScreen(
        eventName: 'Global Developer Summit 2024',
        ticketId: '#UE-98210',
        onViewTicket: () => Navigator.of(ctx).pop(),
        onAddToWallet: () {},
      ),
    ));
  }

  void _pushAskQuestion(BuildContext ctx) {
    Navigator.of(ctx).push(_fastRoute(
      builder: (_) => AskQuestionScreen(
        onBack: () => Navigator.of(ctx).pop(),
        onSend: (q, anon, notify) {},
      ),
    ));
  }

  // ── Ticketing Flow ──

  void _pushTicketDetail(TicketModel ticket) {
    Navigator.of(context).push(_fastRoute(
      builder: (ctx) => TicketDetailView(
        ticket: ticket,
        onBack: () => Navigator.of(ctx).pop(),
        onCancelTap: () => _showCancelConfirmation(ctx, ticket),
      ),
    ));
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
    Navigator.of(context).push(_fastRoute(
      builder: (ctx) => PastEventDetailView(
        ticket: ticket,
        onBack: () => Navigator.of(ctx).pop(),
      ),
    ));
  }

  // ── Organizer Flow ──

  void _pushCreateEvent() {
    Navigator.of(context).push(_fastRoute(
      builder: (_) => CreateEventView(
        onBack: () => Navigator.of(context).pop(),
      ),
    ));
  }

  void _pushInviteGuests(EventModel event) {
    Navigator.of(context).push(_fastRoute(
      builder: (_) => InviteGuestsView(
        onBack: () => Navigator.of(context).pop(),
      ),
    ));
  }

  void _pushSendNotification(EventModel event) {
    Navigator.of(context).push(_fastRoute(
      builder: (_) => SendNotificationView(
        onBack: () => Navigator.of(context).pop(),
      ),
    ));
  }


  void _pushManageEventHub() {
    Navigator.of(context).push(_fastRoute(
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
    ));
  }

  void _pushEditEventDetails() {
    Navigator.of(context).push(_fastRoute(
      builder: (ctx) => EditEventDetailsView(
        onBack: () => Navigator.of(ctx).pop(),
      ),
    ));
  }

  void _pushManageTeam() {
    Navigator.of(context).push(_fastRoute(
      builder: (ctx) => ManageTeamView(
        onBack: () => Navigator.of(ctx).pop(),
      ),
    ));
  }

  void _pushArchiveEvent() {
    Navigator.of(context).push(_fastRoute(
      builder: (ctx) => ArchiveEventView(
        onBack: () => Navigator.of(ctx).pop(),
      ),
    ));
  }

  void _pushAttendeeList() {
    Navigator.of(context).push(_fastRoute(
      builder: (ctx) => AttendeeListView(
        onBack: () => Navigator.of(ctx).pop(),
      ),
    ));
  }

  void _pushExportAttendeeList() {
    Navigator.of(context).push(_fastRoute(
      builder: (ctx) => ExportAttendeeListView(
        onClose: () => Navigator.of(ctx).pop(),
      ),
    ));
  }

  void _pushRegistrationQuestions() {
    Navigator.of(context).push(_fastRoute(
      builder: (ctx) => RegistrationQuestionsView(
        onBack: () => Navigator.of(ctx).pop(),
        onQuestionTap: () => _pushQuestionDetail(),
      ),
    ));
  }

  void _pushQuestionDetail() {
    Navigator.of(context).push(_fastRoute(
      builder: (ctx) => QuestionDetailView(
        onBack: () => Navigator.of(ctx).pop(),
      ),
    ));
  }

  void _pushQrScanner() {
    Navigator.of(context).push(_fastRoute(
      builder: (ctx) => QrScannerView(
        onBack: () => Navigator.of(ctx).pop(),
      ),
    ));
  }

  // ── Profile / Settings Sub-Navigation ──

  void _pushEditProfile() {
    Navigator.of(context).push(_fastRoute(
      builder: (ctx) => Consumer(
        builder: (ctx, ref, _) {
          final currentUser = ref.read(userProfileProvider).value;
          return EditProfileView(
            user: currentUser,
            profileService: ref.read(profileServiceProvider),
            onBack: () => Navigator.of(ctx).pop(),
            onSaved: () {
              // Invalidate cache để Settings + Profile views refresh data mới
              ref.invalidate(userProfileProvider);
              ref.invalidate(profileOverviewProvider);
              Navigator.of(ctx).pop();
            },
          );
        },
      ),
    ));
  }

  void _pushChangeEmail() {
    Navigator.of(context).push(_fastRoute(
      builder: (ctx) => ChangeEmailView(
        onBack: () => Navigator.of(ctx).pop(),
        onSave: () => Navigator.of(ctx).pop(),
      ),
    ));
  }

  void _pushPasskeyLogin() {
    Navigator.of(context).push(_fastRoute(
      builder: (ctx) => PasskeySetupView(
        onBack: () => Navigator.of(ctx).pop(),
        onCreatePasskey: () => Navigator.of(ctx).pop(),
      ),
    ));
  }

  void _pushHelpCenter() {
    Navigator.of(context).push(_fastRoute(
      builder: (ctx) => HelpCenterView(
        onBack: () => Navigator.of(ctx).pop(),
      ),
    ));
  }

  void _pushSendFeedback() {
    Navigator.of(context).push(_fastRoute(
      builder: (ctx) => SendFeedbackView(
        onBack: () => Navigator.of(ctx).pop(),
        onSubmit: () => Navigator.of(ctx).pop(),
      ),
    ));
  }

  void _pushPrivacyPolicy() {
    Navigator.of(context).push(_fastRoute(
      builder: (ctx) => PrivacyPolicyView(
        onBack: () => Navigator.of(ctx).pop(),
      ),
    ));
  }

  void _pushSyncContacts() {
    Navigator.of(context).push(_fastRoute(
      builder: (ctx) => SyncContactsView(
        onBack: () => Navigator.of(ctx).pop(),
        onSync: () => Navigator.of(ctx).pop(),
      ),
    ));
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

