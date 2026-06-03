// File: lib/views/notifications_view.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/models/nav_item_model.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/app_snack_bar.dart';
import 'package:frontend/core/widgets/async_state_slivers.dart';
import 'package:frontend/core/widgets/glass_bottom_nav_bar.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/features/notifications/models/notification_model.dart';
import 'package:frontend/features/notifications/providers/notification_providers.dart';
import 'package:frontend/features/notifications/widgets/notification_tile.dart';

class NotificationsView extends ConsumerWidget {
  final int currentNavIndex;
  final ValueChanged<int> onNavTap;
  final VoidCallback? onBack;
  final ValueChanged<NotificationModel>? onNotificationTap;
  final List<NavItemModel> navItems;

  const NotificationsView({
    super.key,
    this.currentNavIndex = 2,
    required this.onNavTap,
    this.onBack,
    this.onNotificationTap,
    this.navItems = GlassBottomNavBar.defaultItems,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 100)),

              ...notificationsAsync.when(
                data: (notifications) => [
                  AppSuccessSliver(
                    isEmpty: notifications.isEmpty,
                    emptyIcon: Icons.notifications_off_outlined,
                    emptyTitle: 'Chưa có thông báo',
                    emptyDescription: 'Thông báo mới sẽ xuất hiện tại đây.',
                    emptyFillRemaining: true,
                    contentSlivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.pagePaddingH + 8,
                          ),
                          child: Text(
                            'TẤT CẢ',
                            style: AppTextStyles.labelSmall,
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 8)),
                      SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final notification = notifications[index];
                          final iconConfig = _iconConfig(notification.type);

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.pagePaddingH,
                              vertical: 4,
                            ),
                            child: NotificationTile(
                              icon: iconConfig.icon,
                              iconBgColor: iconConfig.bgColor,
                              iconColor: iconConfig.iconColor,
                              title: notification.title,
                              timestamp: _relativeTime(notification.timestamp),
                              description: notification.description,
                              actionLabel: notification.actionLabel,
                              onTap: () => _openNotification(ref, notification),
                              opacity: notification.isRead ? 0.8 : 1,
                            ),
                          );
                        }, childCount: notifications.length),
                      ),
                    ],
                  ),
                ],
                loading: () => [const AppLoadingSliver()],
                error: (error, stackTrace) => [
                  AppErrorSliver(
                    icon: Icons.wifi_off,
                    title: 'Không tải dữ liệu được',
                    description: 'Vui lòng thử lại sau.',
                    onRetry: () => ref
                        .read(notificationsControllerProvider.notifier)
                        .refresh(),
                  ),
                ],
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 140)),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GlassTopBar(
              title: 'Thông báo',
              leadingIcon: Icons.arrow_back,
              trailingIcon: Icons.more_vert,
              onLeadingTap: onBack ?? () => Navigator.of(context).pop(),
              onTrailingTap: () => _showNotificationMenu(
                context,
                ref,
                notificationsAsync.asData?.value ?? const [],
              ),
            ),
          ),
          GlassBottomNavBar(
            currentIndex: currentNavIndex,
            onTap: onNavTap,
            items: navItems,
          ),
        ],
      ),
    );
  }

  void _openNotification(WidgetRef ref, NotificationModel notification) {
    if (!notification.isRead) {
      unawaited(
        ref
            .read(notificationsControllerProvider.notifier)
            .markAsRead(notification.id),
      );
    }

    onNotificationTap?.call(notification);
  }

  Future<void> _showNotificationMenu(
    BuildContext context,
    WidgetRef ref,
    List<NotificationModel> notifications,
  ) {
    final unreadCount = notifications.where((item) => !item.isRead).length;

    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowNav,
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.refresh),
                  title: const Text('Làm mới thông báo'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    ref
                        .read(notificationsControllerProvider.notifier)
                        .refresh();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.done_all),
                  title: const Text('Đánh dấu tất cả là đã đọc'),
                  subtitle: Text(
                    unreadCount > 0
                        ? '$unreadCount thông báo chưa đọc'
                        : 'Không có thông báo chưa đọc',
                  ),
                  enabled: unreadCount > 0,
                  onTap: unreadCount == 0
                      ? null
                      : () {
                          Navigator.of(sheetContext).pop();
                          unawaited(
                            _markVisibleAsRead(context, ref, notifications),
                          );
                        },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _markVisibleAsRead(
    BuildContext context,
    WidgetRef ref,
    List<NotificationModel> notifications,
  ) async {
    try {
      final count = await ref
          .read(notificationsControllerProvider.notifier)
          .markVisibleAsRead(notifications);

      if (context.mounted) {
        showAppSnackBar(
          context,
          count > 0
              ? 'Đã đánh dấu $count thông báo là đã đọc.'
              : 'Không có thông báo chưa đọc.',
        );
      }
    } catch (_) {
      if (context.mounted) {
        showAppSnackBar(
          context,
          'Không thể cập nhật thông báo. Vui lòng thử lại.',
        );
      }
    }
  }

  _NotificationIconConfig _iconConfig(NotificationType type) {
    switch (type) {
      case NotificationType.eventInvite:
        return const _NotificationIconConfig(
          icon: Icons.event,
          bgColor: AppColors.primaryFixed,
          iconColor: AppColors.primary,
        );
      case NotificationType.announcement:
        return const _NotificationIconConfig(
          icon: Icons.campaign,
          bgColor: AppColors.secondaryContainer,
          iconColor: AppColors.secondary,
        );
      case NotificationType.reminder:
        return const _NotificationIconConfig(
          icon: Icons.alarm,
          bgColor: AppColors.errorContainer,
          iconColor: AppColors.error,
        );
      case NotificationType.ticketConfirm:
        return const _NotificationIconConfig(
          icon: Icons.confirmation_number,
          bgColor: AppColors.primaryFixed,
          iconColor: AppColors.primary,
        );
    }
  }

  String _relativeTime(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    return '${diff.inDays} ngày trước';
  }
}

class _NotificationIconConfig {
  final IconData icon;
  final Color bgColor;
  final Color iconColor;

  const _NotificationIconConfig({
    required this.icon,
    required this.bgColor,
    required this.iconColor,
  });
}
