import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/app_routes.dart';
import 'package:frontend/core/providers/service_providers.dart';
import 'package:frontend/core/widgets/app_snack_bar.dart';
import 'package:frontend/features/auth/models/user_model.dart';
import 'package:frontend/features/auth/providers/auth_providers.dart';
import 'package:frontend/features/auth/views/passkey_setup_view.dart';
import 'package:frontend/features/events/controller/event_mutation_controller.dart';
import 'package:frontend/features/events/models/event_model.dart';
import 'package:frontend/features/events/models/event_registration_model.dart';
import 'package:frontend/features/events/providers/event_providers.dart';
import 'package:frontend/features/events/views/archive_event_view.dart';
import 'package:frontend/features/events/views/ask_question_screen.dart';
import 'package:frontend/features/events/views/attendee_list_view.dart';
import 'package:frontend/features/events/views/create_event_view.dart';
import 'package:frontend/features/events/views/discovery_view.dart';
import 'package:frontend/features/events/views/edit_event_details_view.dart';
import 'package:frontend/features/events/views/empty_search_view.dart';
import 'package:frontend/features/events/views/event_detail_organizer_view.dart';
import 'package:frontend/features/events/views/event_detail_screen.dart';
import 'package:frontend/features/events/views/export_attendee_list_view.dart';
import 'package:frontend/features/events/views/invite_guests_view.dart';
import 'package:frontend/features/events/views/manage_event_hub_view.dart';
import 'package:frontend/features/events/views/manage_events_view.dart';
import 'package:frontend/features/events/views/manage_team_view.dart';
import 'package:frontend/features/events/views/question_detail_view.dart';
import 'package:frontend/features/events/views/registration_confirmation_screen.dart';
import 'package:frontend/features/events/views/registration_questions_view.dart';
import 'package:frontend/features/events/views/registration_success_screen.dart';
import 'package:frontend/features/events/views/send_notification_view.dart';
import 'package:frontend/features/events/views/share_event_sheet.dart';
import 'package:frontend/features/notifications/providers/notification_providers.dart';
import 'package:frontend/features/notifications/views/notifications_view.dart';
import 'package:frontend/features/profile/providers/profile_providers.dart';
import 'package:frontend/features/profile/views/change_email_view.dart';
import 'package:frontend/features/profile/views/edit_profile_view.dart';
import 'package:frontend/features/profile/views/help_center_view.dart';
import 'package:frontend/features/profile/views/privacy_policy_view.dart';
import 'package:frontend/features/profile/views/send_feedback_view.dart';
import 'package:frontend/features/profile/views/settings_view.dart';
import 'package:frontend/features/profile/views/sync_contacts_view.dart';
import 'package:frontend/features/profile/views/user_profile_view.dart';
import 'package:frontend/features/ticketing/models/ticket_model.dart';
import 'package:frontend/features/ticketing/views/cancel_confirmation_sheet.dart';
import 'package:frontend/features/ticketing/views/cancel_error_dialog.dart';
import 'package:frontend/features/ticketing/views/my_tickets_view.dart';
import 'package:frontend/features/ticketing/views/past_event_detail_view.dart';
import 'package:frontend/features/ticketing/views/qr_scanner_view.dart';
import 'package:frontend/features/ticketing/views/ticket_detail_view.dart';

typedef SignedOutCallback = void Function(BuildContext context, WidgetRef ref);

class AppShell extends ConsumerStatefulWidget {
  const AppShell({required this.onSignedOut, super.key});

  final SignedOutCallback onSignedOut;

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

  void _pushNotifications() {
    Navigator.of(context).push(
      appRoute(
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
      appRoute(
        builder: (_) =>
            UserProfileView(onBack: () => Navigator.of(context).pop()),
      ),
    );
  }

  void _pushEmptySearch() {
    Navigator.of(context).push(
      appRoute(
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

  void _pushEventDetail(EventModel event) {
    if (event.isOrganizer) {
      Navigator.of(context).push(
        appRoute(
          builder: (ctx) => EventDetailOrganizerView(
            eventId: event.id,
            initialEvent: event,
            onBack: () => Navigator.of(ctx).pop(),
            onCheckIn: _pushQrScanner,
            onInvite: () => _pushInviteGuests(event),
            onNotify: () => _pushSendNotification(event),
            onManage: () => _pushManageEventHub(event),
            onShare: () => ShareEventSheet.show(ctx),
          ),
        ),
      );
    } else {
      Navigator.of(context).push(
        appRoute(
          builder: (ctx) => EventDetailScreen(
            eventId: event.id,
            initialEvent: event,
            onBack: () => Navigator.of(ctx).pop(),
            onShare: () => ShareEventSheet.show(ctx),
            onRegister: () => _pushRegistrationConfirmation(ctx, event),
            onAskQuestion: () => _pushAskQuestion(ctx, event),
          ),
        ),
      );
    }
  }

  void _pushRegistrationConfirmation(BuildContext ctx, EventModel event) {
    RegistrationConfirmationScreen.show(
      ctx,
      event: event,
      onConfirm: (answers) async {
        final detail = ref
            .read(eventDetailProvider(event.id))
            .whenOrNull(data: (value) => value);
        final registration = await ref
            .read(eventRegistrationControllerProvider.notifier)
            .registerEvent(eventId: event.id, answers: answers);
        if (registration != null && mounted) {
          if (ctx.mounted) {
            _pushRegistrationSuccess(ctx, detail ?? event, registration);
          }
        }
        return registration;
      },
    );
  }

  void _pushRegistrationSuccess(
    BuildContext ctx,
    EventModel event,
    EventRegistrationModel registration,
  ) {
    Navigator.of(ctx).push(
      appRoute(
        builder: (_) => RegistrationSuccessScreen(
          eventName: event.title,
          ticketId:
              registration.ticket?.ticketCode ??
              registration.status.toUpperCase(),
          onViewTicket: () => Navigator.of(ctx).pop(),
          onAddToWallet: () {},
        ),
      ),
    );
  }

  void _pushAskQuestion(BuildContext ctx, EventModel event) {
    Navigator.of(ctx).push(
      appRoute(
        builder: (_) => AskQuestionScreen(
          eventName: event.title,
          eventImageUrl: event.imageUrl,
          eventCategory: event.category ?? 'Live Q&A Session',
          onBack: () => Navigator.of(ctx).pop(),
          onSend: (q, anon, notify) async {
            final ok = await ref
                .read(eventEngagementControllerProvider.notifier)
                .createQuestion(
                  eventId: event.id,
                  questionText: q,
                  isAnonymous: anon,
                );

            if (ok && mounted && ctx.mounted) {
              _showSnackBar(ctx, 'Đã gửi câu hỏi.');
            }

            return ok;
          },
        ),
      ),
    );
  }

  void _pushTicketDetail(TicketModel ticket) {
    Navigator.of(context).push(
      appRoute(
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
        Navigator.of(ctx).pop();
        CancelErrorDialog.show(ctx);
      },
    );
  }

  void _pushPastEventDetail(TicketModel ticket) {
    Navigator.of(context).push(
      appRoute(
        builder: (ctx) => PastEventDetailView(
          ticket: ticket,
          onBack: () => Navigator.of(ctx).pop(),
        ),
      ),
    );
  }

  void _pushCreateEvent() {
    unawaited(_handleCreateEventTap());
  }

  Future<void> _handleCreateEventTap() async {
    late final UserModel user;
    try {
      user = await ref.read(userProfileProvider.future);
      if (!mounted) return;
    } catch (_) {
      if (!mounted) return;
      _showSnackBar(context, 'Không thể kiểm tra quyền tạo sự kiện.');
      return;
    }

    final primaryRole = user.primaryRole.trim().toLowerCase();
    final canCreateEvent =
        primaryRole == 'admin' ||
        primaryRole == 'administrator' ||
        primaryRole == 'organizer';

    if (!canCreateEvent) {
      _showSnackBar(
        context,
        'Bạn không phải là người tổ chức, hãy liên hệ với administrator để cấp quyền cho bạn',
      );
      return;
    }

    Navigator.of(context).push(
      appRoute(
        builder: (_) =>
            CreateEventView(onBack: () => Navigator.of(context).pop()),
      ),
    );
  }

  void _pushInviteGuests(EventModel event) {
    Navigator.of(context).push(
      appRoute(
        builder: (_) =>
            InviteGuestsView(onBack: () => Navigator.of(context).pop()),
      ),
    );
  }

  void _pushSendNotification(EventModel event) {
    Navigator.of(context).push(
      appRoute(
        builder: (_) =>
            SendNotificationView(onBack: () => Navigator.of(context).pop()),
      ),
    );
  }

  void _pushManageEventHub(EventModel event) {
    Navigator.of(context).push(
      appRoute(
        builder: (_) => ManageEventHubView(
          onBack: () => Navigator.of(context).pop(),
          onEditDetailsTap: () => _pushEditEventDetails(event),
          onManageTeamTap: () => _pushManageTeam(event),
          onArchiveTap: _pushArchiveEvent,
          onAttendeeListTap: () => _pushAttendeeList(event),
          onRegistrationQuestionsTap: _pushRegistrationQuestions,
          onParticipantCheckInTap: _pushQrScanner,
          onExportAttendeeListTap: _pushExportAttendeeList,
        ),
      ),
    );
  }

  void _pushEditEventDetails(EventModel event) {
    Navigator.of(context).push(
      appRoute(
        builder: (ctx) => EditEventDetailsView(
          eventId: event.id,
          initialEvent: event,
          onBack: () => Navigator.of(ctx).pop(),
        ),
      ),
    );
  }

  void _pushManageTeam(EventModel event) {
    Navigator.of(context).push(
      appRoute(
        builder: (ctx) => ManageTeamView(
          eventId: event.id,
          onBack: () => Navigator.of(ctx).pop(),
        ),
      ),
    );
  }

  void _pushArchiveEvent() {
    Navigator.of(context).push(
      appRoute(
        builder: (ctx) =>
            ArchiveEventView(onBack: () => Navigator.of(ctx).pop()),
      ),
    );
  }

  void _pushAttendeeList(EventModel event) {
    Navigator.of(context).push(
      appRoute(
        builder: (ctx) => AttendeeListView(
          eventId: event.id,
          onBack: () => Navigator.of(ctx).pop(),
        ),
      ),
    );
  }

  void _pushExportAttendeeList() {
    Navigator.of(context).push(
      appRoute(
        builder: (ctx) =>
            ExportAttendeeListView(onClose: () => Navigator.of(ctx).pop()),
      ),
    );
  }

  void _pushRegistrationQuestions() {
    Navigator.of(context).push(
      appRoute(
        builder: (ctx) => RegistrationQuestionsView(
          onBack: () => Navigator.of(ctx).pop(),
          onQuestionTap: () => _pushQuestionDetail(),
        ),
      ),
    );
  }

  void _pushQuestionDetail() {
    Navigator.of(context).push(
      appRoute(
        builder: (ctx) =>
            QuestionDetailView(onBack: () => Navigator.of(ctx).pop()),
      ),
    );
  }

  void _pushQrScanner() {
    Navigator.of(context).push(
      appRoute(
        builder: (ctx) => QrScannerView(onBack: () => Navigator.of(ctx).pop()),
      ),
    );
  }

  void _pushEditProfile() {
    Navigator.of(context).push(
      appRoute(
        builder: (ctx) => Consumer(
          builder: (ctx, ref, _) {
            final currentUser = ref.read(userProfileProvider).value;
            return EditProfileView(
              user: currentUser,
              profileService: ref.read(profileServiceProvider),
              onBack: () => Navigator.of(ctx).pop(),
              onSaved: () {
                ref.invalidate(userProfileProvider);
                ref.invalidate(profileOverviewProvider);
                Navigator.of(ctx).pop();
              },
            );
          },
        ),
      ),
    );
  }

  void _pushChangeEmail() {
    Navigator.of(context).push(
      appRoute(
        builder: (ctx) => ChangeEmailView(
          onBack: () => Navigator.of(ctx).pop(),
          onSave: () => Navigator.of(ctx).pop(),
        ),
      ),
    );
  }

  void _pushPasskeyLogin() {
    Navigator.of(context).push(
      appRoute(
        builder: (ctx) => PasskeySetupView(
          onBack: () => Navigator.of(ctx).pop(),
          onCreatePasskey: () => Navigator.of(ctx).pop(),
        ),
      ),
    );
  }

  void _pushHelpCenter() {
    Navigator.of(context).push(
      appRoute(
        builder: (ctx) => HelpCenterView(onBack: () => Navigator.of(ctx).pop()),
      ),
    );
  }

  void _pushSendFeedback() {
    Navigator.of(context).push(
      appRoute(
        builder: (ctx) => SendFeedbackView(
          onBack: () => Navigator.of(ctx).pop(),
          onSubmit: () => Navigator.of(ctx).pop(),
        ),
      ),
    );
  }

  void _pushPrivacyPolicy() {
    Navigator.of(context).push(
      appRoute(
        builder: (ctx) =>
            PrivacyPolicyView(onBack: () => Navigator.of(ctx).pop()),
      ),
    );
  }

  void _pushSyncContacts() {
    Navigator.of(context).push(
      appRoute(
        builder: (ctx) => SyncContactsView(
          onBack: () => Navigator.of(ctx).pop(),
          onSync: () => Navigator.of(ctx).pop(),
        ),
      ),
    );
  }

  void _signOut() {
    Navigator.of(context).pushAndRemoveUntil(
      appRoute(
        builder: (_) => Consumer(
          builder: (ctx, ref, _) {
            Future.microtask(() async {
              final session = await ref
                  .read(authLocalDataSourceProvider)
                  .readSession();
              try {
                if (session != null && !session.isExpired) {
                  await ref
                      .read(pushNotificationControllerProvider.notifier)
                      .unregisterCurrentDevice();
                }
              } finally {
                await ref.read(authControllerProvider.notifier).signOut();
                if (ctx.mounted) widget.onSignedOut(ctx, ref);
              }
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

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: _currentIndex,
      children: [
        DiscoveryView(
          currentNavIndex: _currentIndex,
          onNavTap: _onNavTap,
          onNotificationsTap: _pushNotifications,
          onProfileTap: _pushProfile,
          onSearchEmpty: _pushEmptySearch,
          onEventTap: _pushEventDetail,
        ),
        ManageEventsView(
          currentNavIndex: _currentIndex,
          onNavTap: _onNavTap,
          onCreateEventTap: _pushCreateEvent,
          onEventTap: _pushEventDetail,
          onManageEventTap: _pushManageEventHub,
        ),
        MyTicketsView(
          currentNavIndex: _currentIndex,
          onNavTap: _onNavTap,
          onTicketTap: _pushTicketDetail,
          onPastTicketTap: _pushPastEventDetail,
          onScanTap: _pushQrScanner,
        ),
        SettingsView(
          currentNavIndex: _currentIndex,
          onNavTap: _onNavTap,
          onBack: () => _onNavTap(0),
          onEditProfile: _pushEditProfile,
          onChangeEmail: _pushChangeEmail,
          onPasskeyLogin: _pushPasskeyLogin,
          onTwoFactorAuth: () {},
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

void _showSnackBar(BuildContext context, String message) {
  showAppSnackBar(context, message);
}
