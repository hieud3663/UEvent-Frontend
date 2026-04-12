// File: lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_theme.dart';

// Auth Flow
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

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const ProviderScope(child: UEventsApp()));
}

// ════════════════════════════════════════════════════════════════════
// AUTH FLOW NAVIGATION
// Top-level functions reused by both initial auth flow AND sign-out.
// Each function captures the builder's `ctx` for subsequent navigation.
// ════════════════════════════════════════════════════════════════════

void _navigateToLogin(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (ctx) => LoginView(
        onLoginWithEmail: () => _navigateToOtp(ctx),
        onLoginWithGoogle: () => _navigateToAppShell(ctx),
        onLoginWithPasskey: () => _navigateToPasskeySetup(ctx),
      ),
    ),
    (route) => false,
  );
}

void _navigateToOtp(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (ctx) => OtpVerificationView(
      onVerify: () => _navigateToProfileSetup(ctx),
      onBack: () => Navigator.of(ctx).pop(),
      onResend: () {}, // TODO: Implement OTP resend logic
    ),
  ));
}

void _navigateToProfileSetup(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (ctx) => ProfileSetupView(
      onComplete: () => _navigateToAppShell(ctx),
      onBack: () => Navigator.of(ctx).pop(),
    ),
  ));
}

void _navigateToPasskeySetup(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (ctx) => PasskeySetupView(
      onBack: () => Navigator.of(ctx).pop(),
      onCreatePasskey: () => _navigateToAppShell(ctx),
    ),
  ));
}

void _navigateToAppShell(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const AppShell()),
    (route) => false,
  );
}

// ════════════════════════════════════════════════════════════════════
// APP ROOT
// ════════════════════════════════════════════════════════════════════

class UEventsApp extends StatelessWidget {
  const UEventsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UEvents',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // Splash → Login → OTP → ProfileSetup → AppShell
      home: Builder(
        builder: (context) => SplashView(
          onInitializationComplete: () => _navigateToLogin(context),
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
    Navigator.of(context).push(MaterialPageRoute(
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
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => UserProfileView(
        onBack: () => Navigator.of(context).pop(),
      ),
    ));
  }

  void _pushEmptySearch() {
    Navigator.of(context).push(MaterialPageRoute(
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
      Navigator.of(context).push(MaterialPageRoute(
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
      Navigator.of(context).push(MaterialPageRoute(
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
    Navigator.of(ctx).push(MaterialPageRoute(
      builder: (_) => RegistrationSuccessScreen(
        eventName: 'Global Developer Summit 2024',
        ticketId: '#UE-98210',
        onViewTicket: () => Navigator.of(ctx).pop(),
        onAddToWallet: () {},
      ),
    ));
  }

  void _pushAskQuestion(BuildContext ctx) {
    Navigator.of(ctx).push(MaterialPageRoute(
      builder: (_) => AskQuestionScreen(
        onBack: () => Navigator.of(ctx).pop(),
        onSend: (q, anon, notify) {},
      ),
    ));
  }

  // ── Ticketing Flow ──

  void _pushTicketDetail(TicketModel ticket) {
    Navigator.of(context).push(MaterialPageRoute(
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
    Navigator.of(context).push(MaterialPageRoute(
      builder: (ctx) => PastEventDetailView(
        ticket: ticket,
        onBack: () => Navigator.of(ctx).pop(),
      ),
    ));
  }

  // ── Organizer Flow ──

  void _pushCreateEvent() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => CreateEventView(
        onBack: () => Navigator.of(context).pop(),
      ),
    ));
  }

  void _pushInviteGuests(EventModel event) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => InviteGuestsView(
        onBack: () => Navigator.of(context).pop(),
      ),
    ));
  }

  void _pushSendNotification(EventModel event) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => SendNotificationView(
        onBack: () => Navigator.of(context).pop(),
      ),
    ));
  }


  void _pushManageEventHub() {
    Navigator.of(context).push(MaterialPageRoute(
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
    Navigator.of(context).push(MaterialPageRoute(
      builder: (ctx) => EditEventDetailsView(
        onBack: () => Navigator.of(ctx).pop(),
      ),
    ));
  }

  void _pushManageTeam() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (ctx) => ManageTeamView(
        onBack: () => Navigator.of(ctx).pop(),
      ),
    ));
  }

  void _pushArchiveEvent() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (ctx) => ArchiveEventView(
        onBack: () => Navigator.of(ctx).pop(),
      ),
    ));
  }

  void _pushAttendeeList() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (ctx) => AttendeeListView(
        onBack: () => Navigator.of(ctx).pop(),
      ),
    ));
  }

  void _pushExportAttendeeList() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (ctx) => ExportAttendeeListView(
        onClose: () => Navigator.of(ctx).pop(),
      ),
    ));
  }

  void _pushRegistrationQuestions() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (ctx) => RegistrationQuestionsView(
        onBack: () => Navigator.of(ctx).pop(),
        onQuestionTap: () => _pushQuestionDetail(),
      ),
    ));
  }

  void _pushQuestionDetail() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (ctx) => QuestionDetailView(
        onBack: () => Navigator.of(ctx).pop(),
      ),
    ));
  }

  void _pushQrScanner() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (ctx) => QrScannerView(
        onBack: () => Navigator.of(ctx).pop(),
      ),
    ));
  }

  // ── Profile / Settings Sub-Navigation ──

  void _pushEditProfile() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (ctx) => EditProfileView(
        onBack: () => Navigator.of(ctx).pop(),
        onSave: () => Navigator.of(ctx).pop(),
      ),
    ));
  }

  void _pushChangeEmail() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (ctx) => ChangeEmailView(
        onBack: () => Navigator.of(ctx).pop(),
        onSave: () => Navigator.of(ctx).pop(),
      ),
    ));
  }

  void _pushPasskeyLogin() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (ctx) => PasskeySetupView(
        onBack: () => Navigator.of(ctx).pop(),
        onCreatePasskey: () => Navigator.of(ctx).pop(),
      ),
    ));
  }

  void _pushHelpCenter() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (ctx) => HelpCenterView(
        onBack: () => Navigator.of(ctx).pop(),
      ),
    ));
  }

  void _pushSendFeedback() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (ctx) => SendFeedbackView(
        onBack: () => Navigator.of(ctx).pop(),
        onSubmit: () => Navigator.of(ctx).pop(),
      ),
    ));
  }

  void _pushPrivacyPolicy() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (ctx) => PrivacyPolicyView(
        onBack: () => Navigator.of(ctx).pop(),
      ),
    ));
  }

  void _pushSyncContacts() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (ctx) => SyncContactsView(
        onBack: () => Navigator.of(ctx).pop(),
        onSync: () => Navigator.of(ctx).pop(),
      ),
    ));
  }

  void _signOut() {
    _navigateToLogin(context);
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
