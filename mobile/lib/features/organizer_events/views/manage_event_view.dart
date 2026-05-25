// File: lib/features/organizer_events/views/manage_event_view.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/core/widgets/glass_action_tile.dart';
import 'package:frontend/features/event_shared/models/event_model.dart';
import 'package:frontend/features/event_shared/widgets/bento_stat_card.dart';

class ManageEventView extends StatelessWidget {
  final EventModel event;
  final VoidCallback? onClose;
  final VoidCallback? onEditDetailsTap;
  final VoidCallback? onAttendeeListTap;
  final VoidCallback? onParticipantCheckInTap;
  final VoidCallback? onQuestionsFeedbackTap;

  const ManageEventView({
    super.key,
    required this.event,
    this.onClose,
    this.onEditDetailsTap,
    this.onAttendeeListTap,
    this.onParticipantCheckInTap,
    this.onQuestionsFeedbackTap,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.pagePaddingH,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        'Quản lý event',
                        style: AppTextStyles.headlineLarge.copyWith(
                          fontSize: 32,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${event.title} • ${event.location}',
                        textAlign: TextAlign.center,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.pagePaddingH,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: 0.9,
                          child: BentoStatCard(
                            icon: Icons.how_to_reg,
                            title: 'Sức chứa',
                            metric: event.guestCount?.toString() ?? '—',
                            isHighlightIcon: false,
                            centerContent: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: 0.9,
                          child: BentoStatCard(
                            icon: Icons.analytics,
                            title: 'Trạng thái',
                            metric: _statusLabel(event.status),
                            isHighlightIcon: true,
                            centerContent: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),

              // ── Management Tools Sections ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.pagePaddingH,
                  ),
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
                        title: 'Chỉnh sửa event',
                        subtitle: 'Sửa lịch, địa điểm và thông tin',
                        onTap: onEditDetailsTap ?? () {},
                      ),
                      GlassActionTile(
                        icon: Icons.group_outlined,
                        title: 'Danh sách người đăng ký',
                        subtitle: 'Tìm theo email và cấp quyền co-host',
                        onTap: onAttendeeListTap ?? () {},
                      ),
                      GlassActionTile(
                        icon: Icons.qr_code_scanner,
                        title: 'Check-in',
                        subtitle: 'Quét vé và cho khách vào',
                        onTap: onParticipantCheckInTap ?? () {},
                      ),
                      GlassActionTile(
                        icon: Icons.forum_outlined,
                        title: 'Danh sách câu hỏi và feedback',
                        subtitle: 'Xem câu hỏi, rating và góp ý từ attendee',
                        onTap: onQuestionsFeedbackTap ?? () {},
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),

              // ── Event Location Section ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.pagePaddingH,
                  ),
                  child: Container(
                    height: 192,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl:
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuBUJVgZCTaUwZWXG4b0RxtqsleC0adPsFZj9GGNgRsIkK3YgWl6kUwR7wm0ZP08JnZJrpAHOFVKuqaUF-98-eM3X5csZt8K9KpDvIS9QbaO_hlM6tllod3ldRVzFyp5xMn8YEwkYmXxfRfZE1HQw8R3pgOcLQawRMN5JPxRpTYY27FIlVySseel7bwS6-Thl1fHUz54suHTsmnsWrqIYVZQmd2ZY5VeWqtvdw_fuCDsYl0K0OG2zk5iBTdxeOU5IiDVGmJ0z4H_vVw',
                          fit: BoxFit.cover,
                          memCacheWidth: 1200,
                          maxWidthDiskCache: 1800,
                          color: Colors.black.withValues(
                            alpha: 0.25,
                          ), // Grayscale brightness equivalent roughly
                          colorBlendMode: BlendMode.darken,
                          errorWidget: (_, _, _) =>
                              Container(color: AppColors.surfaceVariant),
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
                                    'Địa điểm event',
                                    style: AppTextStyles.titleMedium.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    event.location,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.7,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
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
              const SliverToBoxAdapter(child: SizedBox(height: 48)),
            ],
          ),

          // ── Fixed Top Bar ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GlassTopBar(
              title: 'Quản lý sự kiện',
              leadingIcon: Icons.close,
              trailingIcon: Icons.more_vert,
              onLeadingTap: onClose ?? () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(EventStatus status) {
    return switch (status) {
      EventStatus.draft => 'Draft',
      EventStatus.active => 'Active',
      EventStatus.approved => 'Approved',
      EventStatus.finished => 'Finished',
      EventStatus.cancelled => 'Cancelled',
    };
  }
}
