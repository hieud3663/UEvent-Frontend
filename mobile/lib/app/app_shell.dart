import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/app_routes.dart';
import 'package:frontend/core/models/nav_item_model.dart';
import 'package:frontend/core/providers/service_providers.dart';
import 'package:frontend/core/widgets/glass_bottom_nav_bar.dart';
import 'package:frontend/core/widgets/app_snack_bar.dart';
import 'package:frontend/features/auth/models/user_model.dart';
import 'package:frontend/features/auth/providers/auth_providers.dart';
import 'package:frontend/features/auth/views/passkey_setup_view.dart';
import 'package:frontend/features/user_events/controller/user_event_controller.dart';
import 'package:frontend/features/event_shared/models/event_model.dart';
import 'package:frontend/features/user_events/views/ask_question_screen.dart';
import 'package:frontend/features/organizer_events/views/attendee_list_view.dart';
import 'package:frontend/features/organizer_events/views/create_event_view.dart';
import 'package:frontend/features/user_events/views/discovery_view.dart';
import 'package:frontend/features/user_events/views/empty_search_view.dart';
import 'package:frontend/features/organizer_events/views/event_detail_organizer_view.dart';
import 'package:frontend/features/user_events/views/event_detail_screen.dart';
import 'package:frontend/features/organizer_events/views/manage_event_hub_view.dart';
import 'package:frontend/features/organizer_events/views/manage_events_view.dart';
import 'package:frontend/features/organizer_events/views/organizer_engagement_view.dart';
import 'package:frontend/features/user_events/views/registration_confirmation_screen.dart';
import 'package:frontend/features/user_events/views/student_events_view.dart';
import 'package:frontend/features/organizer_events/views/send_notification_view.dart';
import 'package:frontend/features/event_shared/views/share_event_sheet.dart';
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
import 'package:frontend/features/ticketing/views/cancel_confirmation_sheet.dart';
import 'package:frontend/features/ticketing/views/qr_scanner_view.dart';

typedef SignedOutCallback = void Function(BuildContext context, WidgetRef ref);

class AppShell extends ConsumerStatefulWidget {
  const AppShell({required this.onSignedOut, super.key});

  final SignedOutCallback onSignedOut;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _currentIndex = 0;

  bool get _isStudent {
    final role = ref.read(userProfileProvider).value?.primaryRole;
    return role?.trim().toLowerCase() == 'student';
  }

  List<NavItemModel> get _navItems =>
      GlassBottomNavBar.itemsForRole(isStudent: _isStudent);

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
    dismissAppSnackBar();
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }

  void _pushNotifications() {
    Navigator.of(context).push(
      appRoute(
        builder: (_) => NotificationsView(
          currentNavIndex: _currentIndex,
          navItems: _navItems,
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
          navItems: _navItems,
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
            onManage: () => _pushManageEventHub(event),
            onMyTicket: () => _showMyTicketPlaceholder(ctx),
            onUnregister: () => _showUnregisterConfirmation(ctx, event),
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
        final registration = await ref
            .read(userEventRegistrationControllerProvider.notifier)
            .registerEvent(eventId: event.id, answers: answers);
        if (registration != null && mounted && ctx.mounted) {
          _showSnackBar(ctx, 'Đăng ký thành công.');
        }
        return registration;
      },
    );
  }

  void _pushAskQuestion(BuildContext ctx, EventModel event) {
    Navigator.of(ctx).push(
      appRoute(
        builder: (_) => AskQuestionScreen(
          eventName: event.title,
          eventImageUrl: event.imageUrl,
          eventCategory: event.category ?? 'Phiên hỏi đáp trực tiếp',
          onBack: () => Navigator.of(ctx).pop(),
          onSend: (q, anon, notify) async {
            final ok = await ref
                .read(userEventEngagementControllerProvider.notifier)
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

  void _showUnregisterConfirmation(BuildContext ctx, EventModel event) {
    CancelConfirmationSheet.show(
      ctx,
      eventName: event.title,
      onConfirm: () async {
        Navigator.of(ctx).pop();
        final ok = await ref
            .read(userEventRegistrationControllerProvider.notifier)
            .unregisterEvent(eventId: event.id);
        if (!mounted || !ctx.mounted) return;

        _showSnackBar(
          ctx,
          ok ? 'Đã hủy đăng ký sự kiện.' : 'Không thể hủy đăng ký sự kiện.',
        );
      },
    );
  }

  void _showMyTicketPlaceholder(BuildContext ctx) {
    _showSnackBar(ctx, 'Tính năng vé của tôi sẽ được cập nhật sau.');
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
        'Bạn không phải là người tổ chức, hãy liên hệ với quản trị viên để cấp quyền cho bạn',
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
          event: event,
          onBack: () => Navigator.of(context).pop(),
          onEditDetailsTap: () => _pushEditEventDetails(event),
          onAttendeeListTap: () => _pushAttendeeList(event),
          onParticipantCheckInTap: _pushQrScanner,
          onQuestionsFeedbackTap: () => _pushOrganizerEngagement(event),
        ),
      ),
    );
  }

  void _pushEditEventDetails(EventModel event) {
    Navigator.of(context).push(
      appRoute(
        builder: (ctx) => CreateEventView(
          eventId: event.id,
          initialEvent: event,
          onBack: () => Navigator.of(ctx).pop(),
        ),
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

  void _pushOrganizerEngagement(EventModel event) {
    Navigator.of(context).push(
      appRoute(
        builder: (ctx) => OrganizerEngagementView(
          eventId: event.id,
          onBack: () => Navigator.of(ctx).pop(),
        ),
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
    final profile = ref.watch(userProfileProvider).value;
    final isStudent = profile?.primaryRole.trim().toLowerCase() == 'student';
    final navItems = GlassBottomNavBar.itemsForRole(isStudent: isStudent);
    final safeIndex = _currentIndex >= navItems.length
        ? navItems.length - 1
        : _currentIndex;

    if (safeIndex != _currentIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _currentIndex = safeIndex);
      });
    }

    return IndexedStack(
      index: safeIndex,
      children: [
        DiscoveryView(
          currentNavIndex: safeIndex,
          navItems: navItems,
          onNavTap: _onNavTap,
          onNotificationsTap: _pushNotifications,
          onProfileTap: _pushProfile,
          onSearchEmpty: _pushEmptySearch,
          onEventTap: _pushEventDetail,
        ),
        isStudent
            ? StudentEventsView(
                currentNavIndex: safeIndex,
                navItems: navItems,
                onNavTap: _onNavTap,
                onEventTap: _pushEventDetail,
              )
            : ManageEventsView(
                currentNavIndex: safeIndex,
                navItems: navItems,
                onNavTap: _onNavTap,
                onCreateEventTap: _pushCreateEvent,
                onEventTap: _pushEventDetail,
                onManageEventTap: _pushManageEventHub,
              ),
        SettingsView(
          currentNavIndex: safeIndex,
          navItems: navItems,
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
