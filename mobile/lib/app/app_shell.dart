import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/app_routes.dart';
import 'package:frontend/core/models/nav_item_model.dart';
import 'package:frontend/core/providers/service_providers.dart';
import 'package:frontend/core/widgets/glass_bottom_nav_bar.dart';
import 'package:frontend/core/widgets/app_snack_bar.dart';
import 'package:frontend/features/app_setting/models/app_permission.dart';
import 'package:frontend/features/app_setting/models/app_setting_key.dart';
import 'package:frontend/features/app_setting/providers/app_setting_providers.dart';
import 'package:frontend/features/auth/models/user_model.dart';
import 'package:frontend/features/auth/providers/auth_providers.dart';
import 'package:frontend/features/auth/views/passkey_setup_view.dart';
import 'package:frontend/features/user_events/controller/user_event_controller.dart';
import 'package:frontend/features/event_shared/models/event_model.dart';
import 'package:frontend/features/event_shared/providers/shared_event_link_provider.dart';
import 'package:frontend/features/user_events/views/ask_question_screen.dart';
import 'package:frontend/features/organizer_events/views/attendee_list_view.dart';
import 'package:frontend/features/organizer_events/views/create_event_view.dart';
import 'package:frontend/features/user_events/views/discovery_view.dart';
import 'package:frontend/features/user_events/views/empty_search_view.dart';
import 'package:frontend/features/organizer_events/views/event_detail_organizer_view.dart';
import 'package:frontend/features/organizer_events/providers/organizer_event_providers.dart';
import 'package:frontend/features/user_events/views/event_detail_screen.dart';
import 'package:frontend/features/user_events/providers/user_event_providers.dart';
import 'package:frontend/features/organizer_events/views/manage_event_hub_view.dart';
import 'package:frontend/features/organizer_events/views/manage_events_view.dart';
import 'package:frontend/features/organizer_events/views/organizer_engagement_view.dart';
import 'package:frontend/features/user_events/views/registration_confirmation_screen.dart';
import 'package:frontend/features/user_events/views/student_events_view.dart';
import 'package:frontend/features/organizer_events/views/send_notification_view.dart';
import 'package:frontend/features/notifications/models/notification_model.dart';
import 'package:frontend/features/notifications/models/notification_intent.dart';
import 'package:frontend/features/notifications/providers/notification_data_providers.dart';
import 'package:frontend/features/notifications/providers/notification_providers.dart';
import 'package:frontend/features/notifications/views/notification_detail_view.dart';
import 'package:frontend/features/notifications/views/notifications_view.dart';
import 'package:frontend/features/profile/providers/profile_providers.dart';
import 'package:frontend/features/profile/views/change_email_view.dart';
import 'package:frontend/features/profile/views/edit_profile_view.dart';
import 'package:frontend/features/profile/views/help_center_view.dart';
import 'package:frontend/features/profile/views/privacy_policy_view.dart';
import 'package:frontend/features/profile/views/send_feedback_view.dart';
import 'package:frontend/features/profile/views/settings_view.dart';
import 'package:frontend/features/profile/views/user_profile_view.dart';
import 'package:frontend/features/ticketing/views/cancel_confirmation_sheet.dart';
import 'package:frontend/features/ticketing/views/ticket_detail_view.dart';
import 'package:frontend/features/ticketing/views/qr_scanner_view.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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
      unawaited(_registerPushDeviceIfEnabled());
      unawaited(_openPendingSharedEvent());
      unawaited(_consumePendingNotificationIntent());
    });
  }

  Future<void> _registerPushDeviceIfEnabled() async {
    final settings = await ref.read(appSettingControllerProvider.future);
    if (!settings.boolValue(
      AppSettingKey.notificationPushEnabled,
      fallback: true,
    )) {
      return;
    }

    await ref
        .read(pushNotificationControllerProvider.notifier)
        .registerCurrentDevice();
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
          onNotificationTap: _handleNotificationTap,
        ),
      ),
    );
  }

  void _handleNotificationTap(NotificationModel notification) {
    unawaited(
      _dispatchNotificationIntent(
        NotificationIntent.fromNotificationModel(notification),
      ),
    );
  }

  Future<void> _consumePendingNotificationIntent() async {
    final intent = ref
        .read(notificationIntentControllerProvider.notifier)
        .consume();
    if (intent == null || !mounted) return;
    await _dispatchNotificationIntent(intent);
  }

  Future<void> _dispatchNotificationIntent(NotificationIntent intent) async {
    final dispatched = _openNotificationTarget(intent);
    if (!dispatched) {
      _openNotificationFallback(intent);
    }

    final recipientId = intent.recipientId;
    if (recipientId == null || recipientId.isEmpty) return;

    try {
      await ref.read(notificationRepositoryProvider).markAsOpened(recipientId);
      await ref
          .read(notificationsControllerProvider.notifier)
          .refreshSilently();
    } catch (_) {}
  }

  bool _openNotificationTarget(NotificationIntent intent) {
    final eventId = intent.eventId?.trim();
    switch (intent.target) {
      case NotificationTarget.eventUser:
      case NotificationTarget.questionDetail:
        if (eventId == null || eventId.isEmpty) return false;
        return _pushStudentEventDetailById(eventId);
      case NotificationTarget.eventOrganizer:
        if (eventId == null || eventId.isEmpty) return false;
        return _pushOrganizerEventDetailById(eventId);
      case NotificationTarget.ticket:
        if (eventId == null || eventId.isEmpty) return false;
        return _pushStudentEventDetailById(eventId);
      case NotificationTarget.organizerRegistrations:
        if (eventId == null || eventId.isEmpty) return false;
        return _pushAttendeeListById(eventId);
      case NotificationTarget.organizerQuestions:
        if (eventId == null || eventId.isEmpty) return false;
        return _pushOrganizerEngagementById(eventId);
      case NotificationTarget.profile:
        _onNavTap(2);
        return true;
      case NotificationTarget.notificationDetail:
        return false;
    }
  }

  void _openNotificationFallback(NotificationIntent intent) {
    final notification = intent.notification;
    if (notification != null) {
      _pushNotificationDetail(notification);
      return;
    }
    _pushNotifications();
  }

  void _pushProfile() {
    Navigator.of(context).push(
      appRoute(
        builder: (_) => UserProfileView(
          onBack: () => Navigator.of(context).pop(),
          onEditProfile: _pushEditProfile,
          onEventTap: _pushEventDetail,
        ),
      ),
    );
  }

  void _pushNotificationDetail(NotificationModel notification) {
    Navigator.of(context).push(
      appRoute(
        builder: (ctx) => NotificationDetailView(
          notification: notification,
          onBack: () => Navigator.of(ctx).pop(),
        ),
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
    if (event.canManageCurrentUser) {
      _pushOrganizerEventDetail(event);
      return;
    }

    final participantRoute = _pushParticipantEventDetail(event);
    if (!_isStudent) {
      unawaited(
        _promoteToOrganizerEventDetailIfAllowed(event, participantRoute),
      );
    }
  }

  Future<void> _promoteToOrganizerEventDetailIfAllowed(
    EventModel event,
    Route<void> participantRoute,
  ) async {
    try {
      final organizerEvent = await ref
          .read(organizerEventRepositoryProvider)
          .getOrganizerEventDetail(event.id);
      if (!mounted || !participantRoute.isCurrent) return;

      Navigator.of(context).replace(
        oldRoute: participantRoute,
        newRoute: _organizerEventDetailRoute(organizerEvent),
      );
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      if (statusCode != 403 &&
          statusCode != 404 &&
          mounted &&
          participantRoute.isCurrent) {
        _showSnackBar(context, 'Không thể kiểm tra quyền quản lý sự kiện.');
      }
    } catch (_) {
      if (mounted && participantRoute.isCurrent) {
        _showSnackBar(context, 'Không thể kiểm tra quyền quản lý sự kiện.');
      }
    }
  }

  void _pushOrganizerEventDetail(EventModel event) {
    Navigator.of(context).push(_organizerEventDetailRoute(event));
  }

  PageRoute<void> _organizerEventDetailRoute(EventModel event) {
    return appRoute<void>(
      builder: (ctx) => EventDetailOrganizerView(
        eventId: event.id,
        initialEvent: event,
        onBack: () => Navigator.of(ctx).pop(),
        onCheckIn: () => _pushQrScanner(event),
        onNotify: () => _pushSendNotification(event),
        onManage: () => _pushManageEventHub(event),
        onShare: event.visibility == EventVisibility.public
            ? () => _shareEvent(ctx, event)
            : null,
      ),
    );
  }

  PageRoute<void> _pushParticipantEventDetail(EventModel event) {
    final route = _participantEventDetailRoute(event);
    Navigator.of(context).push(route);
    return route;
  }

  PageRoute<void> _participantEventDetailRoute(EventModel event) {
    return appRoute<void>(
      builder: (ctx) => EventDetailScreen(
        eventId: event.id,
        initialEvent: event,
        onBack: () => Navigator.of(ctx).pop(),
        onShare: event.visibility == EventVisibility.public
            ? () => _shareEvent(ctx, event)
            : null,
        onRegister: () => _pushRegistrationConfirmation(ctx, event),
        onManage: () => _pushManageEventHub(event),
        onMyTicket: () => _pushMyTicket(ctx, event),
        onUnregister: () => _showUnregisterConfirmation(ctx, event),
        onAskQuestion: () => _pushAskQuestion(ctx, event),
      ),
    );
  }

  Future<void> _openPendingSharedEvent() async {
    final slug = ref.read(sharedEventSlugProvider);
    if (slug == null) return;

    ref.read(sharedEventSlugProvider.notifier).clear();
    await _openSharedEventBySlug(slug);
  }

  Future<void> _openSharedEventBySlug(String slug) async {
    try {
      final event = await ref
          .read(userEventRepositoryProvider)
          .getEventBySlug(slug);
      if (!mounted) return;
      _pushEventDetail(event);
    } on DioException catch (error) {
      if (!mounted) return;
      final message = error.response?.statusCode == 404
          ? 'Sự kiện được chia sẻ không còn khả dụng.'
          : 'Không thể mở sự kiện được chia sẻ.';
      _showSnackBar(context, message);
    } catch (_) {
      if (!mounted) return;
      _showSnackBar(context, 'Không thể mở sự kiện được chia sẻ.');
    }
  }

  Future<void> _shareEvent(BuildContext ctx, EventModel event) async {
    try {
      final shareUrl = _resolveEventShareUrl(event);
      if (shareUrl == null) {
        _showSnackBar(ctx, 'Sự kiện chưa có liên kết chia sẻ.');
        return;
      }

      if (!ctx.mounted) return;

      await SharePlus.instance.share(
        ShareParams(text: '${event.title}\n$shareUrl', subject: event.title),
      );
    } on DioException catch (error) {
      if (!ctx.mounted) return;

      final message = error.response?.statusCode == 403
          ? 'Sự kiện riêng tư không hỗ trợ chia sẻ công khai.'
          : 'Không thể tạo liên kết chia sẻ lúc này.';
      _showSnackBar(ctx, message);
    } catch (_) {
      if (!ctx.mounted) return;
      _showSnackBar(ctx, 'Không thể tạo liên kết chia sẻ lúc này.');
    }
  }

  String? _resolveEventShareUrl(EventModel event) {
    final payloadShareUrl = event.shareUrl?.trim();
    if (payloadShareUrl?.isNotEmpty == true) return payloadShareUrl;

    final deepLink = event.deepLink?.trim();
    final deepLinkUri = deepLink == null ? null : Uri.tryParse(deepLink);
    if (deepLink?.isNotEmpty == true &&
        (deepLinkUri?.scheme == 'http' || deepLinkUri?.scheme == 'https')) {
      return deepLink;
    }

    final slug = event.slug?.trim();
    if (slug?.isNotEmpty != true) return null;
    return 'https://uevent.u-code.dev/events/share/${Uri.encodeComponent(slug!)}';
  }

  bool _pushStudentEventDetailById(String eventId) {
    Navigator.of(context).push(
      appRoute(
        builder: (ctx) => Consumer(
          builder: (ctx, ref, _) {
            final event = ref.watch(userEventDetailProvider(eventId)).value;

            return EventDetailScreen(
              eventId: eventId,
              initialEvent: event,
              onBack: () => Navigator.of(ctx).pop(),
              onShare:
                  event == null || event.visibility != EventVisibility.public
                  ? null
                  : () => _shareEvent(ctx, event),
              onRegister: event == null
                  ? null
                  : () => _pushRegistrationConfirmation(ctx, event),
              onManage: event == null ? null : () => _pushManageEventHub(event),
              onMyTicket: event == null
                  ? null
                  : () => _pushMyTicket(ctx, event),
              onUnregister: event == null
                  ? null
                  : () => _showUnregisterConfirmation(ctx, event),
              onAskQuestion: event == null
                  ? null
                  : () => _pushAskQuestion(ctx, event),
            );
          },
        ),
      ),
    );
    return true;
  }

  bool _pushOrganizerEventDetailById(String eventId) {
    Navigator.of(context).push(
      appRoute(
        builder: (ctx) => Consumer(
          builder: (ctx, ref, _) {
            final event = ref
                .watch(organizerEventDetailProvider(eventId))
                .value;

            return EventDetailOrganizerView(
              eventId: eventId,
              initialEvent: event,
              onBack: () => Navigator.of(ctx).pop(),
              onCheckIn: event == null ? null : () => _pushQrScanner(event),
              onNotify: event == null
                  ? null
                  : () => _pushSendNotification(event),
              onManage: event == null ? null : () => _pushManageEventHub(event),
              onShare:
                  event == null || event.visibility != EventVisibility.public
                  ? null
                  : () => _shareEvent(ctx, event),
            );
          },
        ),
      ),
    );
    return true;
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
          if (registration.status == 'waitlisted') {
            _showSnackBar(ctx, 'Bạn đã vào danh sách chờ.');
            return registration;
          }

          if (registration.status == 'registered' &&
              registration.ticket != null) {
            _showSnackBar(ctx, 'Đăng ký thành công.');
            unawaited(
              Future<void>.delayed(const Duration(milliseconds: 200), () {
                if (mounted && ctx.mounted) {
                  _pushMyTicket(ctx, event);
                }
              }),
            );
          } else {
            _showSnackBar(ctx, 'Đăng ký thành công.');
          }
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
        final ok = await ref
            .read(userEventRegistrationControllerProvider.notifier)
            .unregisterEvent(eventId: event.id);
        if (!mounted || !ctx.mounted) return;

        if (ok) {
          Navigator.of(ctx).pop();
          _showSnackBar(ctx, 'Đã hủy đăng ký sự kiện.');
          return;
        }

        _showSnackBar(
          ctx,
          ok ? 'Đã hủy đăng ký sự kiện.' : 'Không thể hủy đăng ký sự kiện.',
        );
      },
    );
  }

  void _pushMyTicket(BuildContext ctx, EventModel event) {
    Navigator.of(ctx).push(
      appRoute(
        builder: (routeCtx) => EventTicketDetailView(
          event: event,
          onBack: () => Navigator.of(routeCtx).pop(),
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
        builder: (_) => SendNotificationView(
          eventId: event.id,
          eventTitle: event.title,
          onBack: () => Navigator.of(context).pop(),
        ),
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
          onParticipantCheckInTap: () => _pushQrScanner(event),
          onQuestionsTap: () => _pushOrganizerEngagement(event),
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

  bool _pushAttendeeListById(String eventId) {
    Navigator.of(context).push(
      appRoute(
        builder: (ctx) => AttendeeListView(
          eventId: eventId,
          onBack: () => Navigator.of(ctx).pop(),
        ),
      ),
    );
    return true;
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

  bool _pushOrganizerEngagementById(String eventId) {
    Navigator.of(context).push(
      appRoute(
        builder: (ctx) => OrganizerEngagementView(
          eventId: eventId,
          onBack: () => Navigator.of(ctx).pop(),
        ),
      ),
    );
    return true;
  }

  Future<void> _pushQrScanner(EventModel event) async {
    final allowed = await _ensureDevicePermission(
      permissionKey: AppPermissionKey.camera,
      deniedMessage:
          'Cần quyền camera để mở trình quét QR. Vui lòng cấp quyền trong cài đặt hệ thống.',
    );
    if (!allowed || !mounted) return;

    Navigator.of(context).push(
      appRoute(
        builder: (ctx) => QrScannerView(
          eventId: event.id,
          onBack: () => Navigator.of(ctx).pop(),
        ),
      ),
    );
  }

  void _pushEditProfile() {
    Navigator.of(context).push(
      appRoute(
        builder: (ctx) => Consumer(
          builder: (ctx, ref, _) {
            final currentUser = ref.watch(userProfileProvider).value;
            return EditProfileView(
              user: currentUser,
              profileService: ref.read(profileServiceProvider),
              onBack: () => Navigator.of(ctx).pop(),
              onSaved: () {
                ref.invalidate(userProfileProvider);
                ref.invalidate(profileOverviewProvider);
                Navigator.of(ctx).pop();
              },
              onChangeEmail: () =>
                  _pushChangeEmail(ctx, currentUser?.email ?? ''),
            );
          },
        ),
      ),
    );
  }

  void _pushChangeEmail(BuildContext parentContext, String currentEmail) {
    Navigator.of(parentContext).push(
      appRoute(
        builder: (ctx) => Consumer(
          builder: (ctx, ref, _) => ChangeEmailView(
            currentEmail: currentEmail,
            profileService: ref.read(profileServiceProvider),
            onBack: () => Navigator.of(ctx).pop(),
            onChanged: (_) {
              ref.invalidate(userProfileProvider);
              ref.invalidate(profileOverviewProvider);
            },
          ),
        ),
      ),
    );
  }

  void _pushPasskeyLogin() {
    Navigator.of(context).push(
      appRoute(
        builder: (ctx) =>
            PasskeySetupView(onBack: () => Navigator.of(ctx).pop()),
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
          onRate: () => _openPlayStoreRating(ctx),
        ),
      ),
    );
  }

  Future<void> _openPlayStoreRating(BuildContext ctx) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final marketUri = Uri.parse(
        'market://details?id=${packageInfo.packageName}',
      );
      final webUri = Uri.https('play.google.com', '/store/apps/details', {
        'id': packageInfo.packageName,
      });

      final openedMarket = await launchUrl(
        marketUri,
        mode: LaunchMode.externalApplication,
      );
      if (!openedMarket) {
        final openedWeb = await launchUrl(
          webUri,
          mode: LaunchMode.externalApplication,
        );
        if (!openedWeb && ctx.mounted) {
          _showSnackBar(ctx, 'Không thể mở Play Store. Vui lòng thử lại sau.');
        }
      }
    } catch (_) {
      if (ctx.mounted) {
        _showSnackBar(ctx, 'Không thể mở Play Store. Vui lòng thử lại sau.');
      }
    }
  }

  void _pushPrivacyPolicy() {
    Navigator.of(context).push(
      appRoute(
        builder: (ctx) => PrivacyPolicyView(
          onBack: () => Navigator.of(ctx).pop(),
          onAccept: (version) async {
            await ref
                .read(appSettingControllerProvider.notifier)
                .setString(
                  AppSettingKey.legalPrivacyPolicyAcceptedVersion,
                  version,
                );
            if (!ctx.mounted) return;
            _showSnackBar(ctx, 'Đã ghi nhận đồng ý chính sách quyền riêng tư.');
            Navigator.of(ctx).pop();
          },
        ),
      ),
    );
  }

  Future<bool> _ensureDevicePermission({
    required AppPermissionKey permissionKey,
    required String deniedMessage,
  }) async {
    final controller = ref.read(appSettingControllerProvider.notifier);

    final permission = await controller.requestPermission(permissionKey);
    final allowed =
        permission?.status == AppPermissionStatus.granted ||
        permission?.status == AppPermissionStatus.limited ||
        permission?.status == AppPermissionStatus.provisional;

    if (!allowed && mounted) {
      _showSnackBar(context, deniedMessage);
      if (permission?.status.canOpenSystemSettings == true) {
        await controller.openSystemSettings(permissionKey);
      }
    }

    return allowed;
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
    ref.listen<String?>(sharedEventSlugProvider, (previous, next) {
      if (next == null || next == previous) return;

      ref.read(sharedEventSlugProvider.notifier).clear();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          unawaited(_openSharedEventBySlug(next));
        }
      });
    });

    ref.listen<NotificationIntent?>(notificationIntentControllerProvider, (
      previous,
      next,
    ) {
      if (next == null || identical(previous, next)) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          unawaited(_consumePendingNotificationIntent());
        }
      });
    });

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
          profileAvatarUrl: profile?.avatarUrl,
          profileName: profile?.fullName,
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
          onPasskeyLogin: _pushPasskeyLogin,
          onHelpCenter: _pushHelpCenter,
          onSendFeedback: _pushSendFeedback,
          onPrivacyPolicy: _pushPrivacyPolicy,
          onSignOut: _signOut,
        ),
      ],
    );
  }
}

void _showSnackBar(BuildContext context, String message) {
  showAppSnackBar(context, message);
}
