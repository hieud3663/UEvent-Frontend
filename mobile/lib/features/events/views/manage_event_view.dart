// File: lib/features/events/views/manage_event_view.dart

import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/core/widgets/glass_action_tile.dart';
import 'package:frontend/features/events/widgets/bento_stat_card.dart';

class ManageEventView extends StatelessWidget {
  final VoidCallback? onClose;
  // Event Operations
  final VoidCallback? onEditDetailsTap;
  final VoidCallback? onManageTeamTap;
  final VoidCallback? onArchiveTap;
  // Participant Management
  final VoidCallback? onAttendeeListTap;
  final VoidCallback? onRegistrationQuestionsTap;
  final VoidCallback? onParticipantCheckInTap;
  final VoidCallback? onExportAttendeeListTap;

  const ManageEventView({
    super.key,
    this.onClose,
    this.onEditDetailsTap,
    this.onManageTeamTap,
    this.onArchiveTap,
    this.onAttendeeListTap,
    this.onRegistrationQuestionsTap,
    this.onParticipantCheckInTap,
    this.onExportAttendeeListTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 100)),

              // ── Header Section ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.pagePaddingH),
                  child: Column(
                    children: [
                      Text(
                        'LIVE CONTROL',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primary,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Manage Event',
                        style: AppTextStyles.headlineLarge.copyWith(fontSize: 32),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Summer Gala 2024 • Vancouver, BC',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.navInactive,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),

              // ── Quick Stats Bento Grid ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.pagePaddingH),
                  child: Row(
                    children: [
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: BentoStatCard(
                            icon: Icons.how_to_reg,
                            title: 'Check-ins',
                            metric: '1,284',
                            secondaryMetric: '12% VS LAST HR',
                            isHighlightIcon: false,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: BentoStatCard(
                            icon: Icons.analytics,
                            title: 'Attendance',
                            metric: '86',
                            percentageStr: '%',
                            progressPercentage: 0.86,
                            isHighlightIcon: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),

              // ── Management Tools Sections ──
              
              // 1. Event Operations
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.pagePaddingH),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8, bottom: 12),
                        child: Text(
                          'EVENT OPERATIONS',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.navInactive.withValues(alpha: 0.8),
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      GlassActionTile(
                        icon: Icons.edit_note,
                        title: 'Edit Event Details',
                        subtitle: 'Modify schedule, location, and info',
                        onTap: onEditDetailsTap ?? () {},
                      ),
                      GlassActionTile(
                        icon: Icons.badge_outlined,
                        title: 'Manage Team',
                        subtitle: 'Assign roles and permissions',
                        onTap: onManageTeamTap ?? () {},
                      ),
                      GlassActionTile(
                        icon: Icons.archive_outlined,
                        title: 'Archive Event',
                        subtitle: 'Close event and move to history',
                        onTap: onArchiveTap ?? () {},
                        baseColor: AppColors.error,
                        trailingIcon: Icons.warning_amber_rounded,
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // 2. Participant Management
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.pagePaddingH),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8, bottom: 12),
                        child: Text(
                          'PARTICIPANT MANAGEMENT',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.navInactive.withValues(alpha: 0.8),
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      GlassActionTile(
                        icon: Icons.group_outlined,
                        title: 'Attendee List',
                        subtitle: 'View and manage all participants',
                        onTap: onAttendeeListTap ?? () {},
                      ),
                      GlassActionTile(
                        icon: Icons.quiz_outlined,
                        title: 'Registration Questions',
                        subtitle: 'Custom forms and data collection',
                        onTap: onRegistrationQuestionsTap ?? () {},
                      ),
                      GlassActionTile(
                        icon: Icons.qr_code_scanner,
                        title: 'Participant Check-in',
                        subtitle: 'Scan tickets and admit guests',
                        onTap: onParticipantCheckInTap ?? () {},
                      ),
                      GlassActionTile(
                        icon: Icons.ios_share,
                        title: 'Export Attendee List',
                        subtitle: 'Download CSV or PDF reports',
                        onTap: onExportAttendeeListTap ?? () {},
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),

              // ── Featured Map Section ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.pagePaddingH),
                  child: Container(
                    height: 192,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuBUJVgZCTaUwZWXG4b0RxtqsleC0adPsFZj9GGNgRsIkK3YgWl6kUwR7wm0ZP08JnZJrpAHOFVKuqaUF-98-eM3X5csZt8K9KpDvIS9QbaO_hlM6tllod3ldRVzFyp5xMn8YEwkYmXxfRfZE1HQw8R3pgOcLQawRMN5JPxRpTYY27FIlVySseel7bwS6-Thl1fHUz54suHTsmnsWrqIYVZQmd2ZY5VeWqtvdw_fuCDsYl0K0OG2zk5iBTdxeOU5IiDVGmJ0z4H_vVw',
                          fit: BoxFit.cover,
                          color: Colors.black.withValues(alpha: 0.25), // Grayscale brightness equivalent roughly
                          colorBlendMode: BlendMode.darken,
                          errorBuilder: (_, _, _) => Container(color: AppColors.surfaceVariant),
                        ),
                        // Overlay Gradient
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.8),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        // Content
                        Positioned(
                          bottom: 24,
                          left: 24,
                          right: 24,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Event Venue',
                                    style: AppTextStyles.titleMedium.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Harbourfront Centre, Plaza B',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: Colors.white.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  'OPEN MAP',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.onSurface,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 140)), // Padding for bottom nav bar
            ],
          ),

          // ── Fixed Top Bar ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GlassTopBar(
              title: 'Event Manager',
              leadingIcon: Icons.close,
              trailingIcon: Icons.more_vert,
              onLeadingTap: onClose ?? () => Navigator.of(context).pop(),
            ),
          ),

        ],
      ),
    );
  }
}
