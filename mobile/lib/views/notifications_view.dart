// File: lib/views/notifications_view.dart

import 'package:flutter/material.dart';
import '../apps/app_colors.dart';
import '../apps/app_constants.dart';
import '../apps/app_text_styles.dart';
import '../widgets/glass_top_bar.dart';
import '../widgets/glass_bottom_nav_bar.dart';
import '../widgets/notification_tile.dart';

class NotificationsView extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              SliverToBoxAdapter(
                child: GlassTopBar(
                  title: 'Notifications',
                  leadingIcon: Icons.arrow_back,
                  trailingIcon: Icons.more_vert,
                  onLeadingTap: onBack ?? () => Navigator.of(context).pop(),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // ── Today ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.pagePaddingH + 8,
                  ),
                  child: Text('TODAY', style: AppTextStyles.labelSmall),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.pagePaddingH,
                    vertical: 4,
                  ),
                  child: NotificationTile(
                    icon: Icons.event,
                    iconBgColor: AppColors.primaryFixed,
                    iconColor: AppColors.primary,
                    title: 'New Event Invite',
                    timestamp: '2m ago',
                    description:
                        'Sarah Jenkins invited you to "Neon Nights: Underground Jazz" this Friday at 8:00 PM.',
                    actionLabel: 'Add to Calendar',
                    onActionTap: () {},
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.pagePaddingH,
                    vertical: 4,
                  ),
                  child: NotificationTile(
                    icon: Icons.campaign,
                    iconBgColor: AppColors.secondaryContainer,
                    iconColor: AppColors.secondary,
                    title: 'Venue Update',
                    timestamp: '1h ago',
                    description:
                        'The workshop "Creative Coding 101" has been moved to Studio B on the 3rd floor.',
                  ),
                ),
              ),

              // ── Yesterday ──
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.pagePaddingH + 8,
                  ),
                  child: Text('YESTERDAY', style: AppTextStyles.labelSmall),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.pagePaddingH,
                    vertical: 4,
                  ),
                  child: NotificationTile(
                    icon: Icons.alarm,
                    iconBgColor: AppColors.errorContainer,
                    iconColor: AppColors.error,
                    title: 'Upcoming Workshop',
                    timestamp: '24h ago',
                    description:
                        'Reminder: "Digital Portraiture Masterclass" starts in 1 hour. Don\'t forget your tablet!',
                    opacity: 0.9,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.pagePaddingH,
                    vertical: 4,
                  ),
                  child: NotificationTile(
                    icon: Icons.confirmation_number,
                    iconBgColor: AppColors.primaryFixed,
                    iconColor: AppColors.primary,
                    title: 'Tickets Confirmed',
                    timestamp: '1d ago',
                    description:
                        'Your order #UE-9021 for "Summer Solstice Gala" is confirmed. See you there!',
                    actionLabel: 'View Receipt',
                    opacity: 0.9,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 140)),
            ],
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
}
