import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/app_routes.dart';
import 'package:frontend/core/models/nav_item_model.dart';
import 'package:frontend/core/providers/service_providers.dart';
import 'package:frontend/core/widgets/glass_bottom_nav_bar.dart';
import 'package:frontend/core/widgets/app_snack_bar.dart';
import 'package:frontend/features/app_setting/data/app_setting_legal.dart';
import 'package:frontend/features/app_setting/models/app_permission.dart';
import 'package:frontend/features/app_setting/models/app_setting_key.dart';
import 'package:frontend/features/app_setting/providers/app_setting_providers.dart';
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
import 'package:frontend/features/profile/views/sync_contacts_view.dart';
import 'package:frontend/features/profile/views/settings_view.dart';
import 'package:frontend/features/profile/views/user_profile_view.dart';
import 'package:frontend/features/ticketing/views/cancel_confirmation_sheet.dart';
import 'package:frontend/features/ticketing/views/ticket_detail_view.dart';
import 'package:frontend/features/ticketing/views/qr_scanner_view.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
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
      unawaited(_bootstrapAppPermissions());
    });
  }

  Future<void> _bootstrapAppPermissions() async {
    await _requestInitialCameraPermission();
    if (!mounted) return;

    await _registerPushDeviceIfEnabled();
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

  Future<void> _requestInitialCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isDenied) {
      await Permission.camera.request();
    }
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
            onCheckIn: () => _pushQrScanner(event),
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
            onMyTicket: () => _pushMyTicket(ctx, event),
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
          onParticipantCheckInTap: () => _pushQrScanner(event),
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
          onAccept: () async {
            await ref
                .read(appSettingControllerProvider.notifier)
                .setString(
                  AppSettingKey.legalPrivacyPolicyAcceptedVersion,
                  AppSettingLegal.privacyPolicyVersion,
                );
            if (!ctx.mounted) return;
            _showSnackBar(ctx, 'Đã ghi nhận đồng ý chính sách quyền riêng tư.');
            Navigator.of(ctx).pop();
          },
        ),
      ),
    );
  }

  Future<void> _pushSyncContacts() async {
    final allowed = await _ensureDevicePermission(
      permissionKey: AppPermissionKey.contacts,
      settingKey: AppSettingKey.permissionContactsSyncEnabled,
      deniedMessage:
          'Cần quyền danh bạ để đồng bộ bạn bè. Vui lòng cấp quyền trong cài đặt hệ thống.',
    );
    if (!allowed || !mounted) return;

    Navigator.of(context).push(
      appRoute(
        builder: (ctx) =>
            SyncContactsView(onBack: () => Navigator.of(ctx).pop()),
      ),
    );
  }

  Future<bool> _ensureDevicePermission({
    required AppPermissionKey permissionKey,
    required String deniedMessage,
    String? settingKey,
  }) async {
    final controller = ref.read(appSettingControllerProvider.notifier);
    final state = ref.read(appSettingControllerProvider).value;

    if (settingKey != null && state?.boolValue(settingKey) == false) {
      await controller.setBool(settingKey, true);
    }

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

    if (settingKey != null) {
      await controller.setBool(settingKey, allowed);
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
          onPasskeyLogin: _pushPasskeyLogin,
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
