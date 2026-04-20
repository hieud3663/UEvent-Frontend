// File: lib/views/notifications_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/async_state_slivers.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/core/widgets/glass_bottom_nav_bar.dart';
import 'package:frontend/features/notifications/models/notification_model.dart';
import 'package:frontend/features/notifications/providers/notification_providers.dart';
import 'package:frontend/features/notifications/widgets/notification_tile.dart';

class NotificationsView extends ConsumerWidget {
  final int currentNavIndex;
  final ValueChanged<int> onNavTap;
  final VoidCallback? onBack;

  const NotificationsView({
    super.key,
    this.currentNavIndex = 3,
    required this.onNavTap,
    this.onBack,
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
              // Spacing for fixed top bar
              const SliverToBoxAdapter(child: SizedBox(height: 100)),

              ...notificationsAsync.when(
                data: (notifications) => [
                  AppSuccessSliver(
                    isEmpty: notifications.isEmpty,
                    emptyIcon: Icons.notifications_off_outlined,
                    emptyTitle: 'Chua co thong bao',
                    emptyDescription: 'Thong bao moi se xuat hien tai day.',
                    emptyFillRemaining: true,
                    contentSlivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.pagePaddingH + 8,
                          ),
                          child: Text('ALL', style: AppTextStyles.labelSmall),
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
                    title: 'Khong tai du lieu duoc',
                    description: 'Vui long thu lai sau.',
                    onRetry: () => ref.read(notificationsControllerProvider.notifier).refresh(),
                  ),
                ],
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 140)),
            ],
          ),
          // Top Bar Fixed
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GlassTopBar(
              title: 'Notifications',
              leadingIcon: Icons.arrow_back,
              trailingIcon: Icons.more_vert,
              onLeadingTap: onBack ?? () => Navigator.of(context).pop(),
            ),
          ),
          GlassBottomNavBar(
            currentIndex: currentNavIndex,
            onTap: onNavTap,
            items: GlassBottomNavBar.defaultItems,
          ),
        ],
      ),
    );
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
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
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
