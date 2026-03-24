// File: lib/views/event_detail_organizer_view.dart

import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/features/events/models/event_model.dart';
import 'package:frontend/features/events/models/team_member_model.dart';
import 'package:frontend/features/events/mock/mock_event_data.dart';
import 'package:frontend/features/events/mock/mock_team_data.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/core/widgets/glass_container.dart';
import 'package:frontend/core/widgets/primary_button.dart';
import 'package:frontend/core/widgets/section_header.dart';
import 'package:frontend/features/events/widgets/team_member_tile.dart';

/// Event Detail — Organizer View with Check-in capability.
/// Push navigation (no bottom nav, ← back button).
class EventDetailOrganizerView extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onCheckIn;
  final VoidCallback? onInvite;
  final VoidCallback? onNotify;
  final VoidCallback? onManage;
  final VoidCallback? onShare;

  const EventDetailOrganizerView({
    super.key,
    this.onBack,
    this.onCheckIn,
    this.onInvite,
    this.onNotify,
    this.onManage,
    this.onShare,
  });

  // Reference mock data from dedicated mock files
  static EventModel get _event => MockEventData.eventDetailOrganizer;
  static List<TeamMemberModel> get _teamMembers => MockTeamData.btcTeam;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 100)),

          // ── Hero Image ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.pagePaddingH,
              ),
              child: _buildHeroImage(),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // ── Category Badge + Title + Meta ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.pagePaddingH,
              ),
              child: _buildEventInfo(),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ── Organizer Action Buttons (Invite / Notify / Manage) ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.pagePaddingH,
              ),
              child: _buildActionButtons(),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // ── Participant Check-in CTA ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.pagePaddingH,
              ),
              child: PrimaryButton(
                label: 'Participant Check-in',
                icon: Icons.qr_code_2,
                onPressed: onCheckIn,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ── Stats Section ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.pagePaddingH,
              ),
              child: _buildStatsSection(),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ── Event Description ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.pagePaddingH,
              ),
              child: _buildDescriptionSection(),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ── BTC Team ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.pagePaddingH,
              ),
              child: _buildTeamSection(),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
      Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: GlassTopBar(
          title: 'Event Details',
          titleStyle: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
          leadingIcon: Icons.chevron_left,
          trailingWidget: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCircleButton(Icons.share, onTap: onShare, isPrimary: true),
              const SizedBox(width: 4),
              _buildCircleButton(Icons.more_vert, onTap: () {}),
            ],
          ),
          onLeadingTap: onBack ?? () => Navigator.of(context).pop(),
        ),
      ),
    ],
  ),
);
}

  // ── Helper: Circle button for top bar trailing ──
  Widget _buildCircleButton(IconData icon,
      {VoidCallback? onTap, bool isPrimary = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: AppColors.shadowSubtle, blurRadius: 4),
          ],
        ),
        child: Icon(
          icon,
          size: 20,
          color: isPrimary ? AppColors.primary : AppColors.onSurface,
        ),
      ),
    );
  }

  // ── Hero Image with Live badge ──
  Widget _buildHeroImage() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        boxShadow: [BoxShadow(color: AppColors.shadowSubtle, blurRadius: 8)],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            _event.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(color: AppColors.surfaceVariant),
          ),
          // "Live Now" badge
          Positioned(
            top: 16,
            right: 16,
            child: GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              borderRadius: 9999,
              child: Text(
                'LIVE NOW',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Event Info: category badge, title, date, location ──
  Widget _buildEventInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(9999),
          ),
          child: Text(
            _event.category?.toUpperCase() ?? '',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Title
        Text(
          _event.title,
          style: AppTextStyles.headlineLarge.copyWith(fontSize: 28),
        ),
        const SizedBox(height: 16),
        // Date row
        _buildInfoRow(Icons.calendar_month, 'Oct 24, 2024 • ${_event.timeRange}'),
        const SizedBox(height: 12),
        // Location row
        _buildInfoRow(Icons.location_on, _event.location),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.navInactive,
            ),
          ),
        ),
      ],
    );
  }

  // ── Action Buttons: Invite / Notify / Manage ──
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(child: _buildActionChip(Icons.person_add, 'Invite', onInvite)),
        const SizedBox(width: 12),
        Expanded(child: _buildActionChip(Icons.send, 'Notify', onNotify)),
        const SizedBox(width: 12),
        Expanded(child: _buildActionChip(Icons.settings, 'Manage', onManage)),
      ],
    );
  }

  Widget _buildActionChip(IconData icon, String label, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowPrimary.withValues(alpha: 0.2),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: AppColors.onPrimaryDark),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.onPrimaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Stats: Tickets Sold + Pending Approvals ──
  Widget _buildStatsSection() {
    return Column(
      children: [
        // Tickets Sold
        GlassContainer(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TICKETS SOLD',
                style: AppTextStyles.labelSmall.copyWith(
                  letterSpacing: 2.0,
                  color: AppColors.navInactive,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '1,842',
                    style: AppTextStyles.headlineLarge.copyWith(fontSize: 30),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF059669).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.trending_up, size: 14, color: Color(0xFF059669)),
                        SizedBox(width: 4),
                        Text(
                          '+12%',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: Color(0xFF059669),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Pending Approvals
        GlassContainer(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PENDING APPROVALS',
                      style: AppTextStyles.labelSmall.copyWith(
                        letterSpacing: 2.0,
                        color: AppColors.navInactive,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '48 Guest Requests',
                      style: AppTextStyles.headlineMedium,
                    ),
                  ],
                ),
              ),
              // Stacked avatars
              SizedBox(
                width: 88,
                height: 40,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      child: _buildSmallAvatar(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuB-d1vmiJ14n16NNg466wUFGDC6CFrZckYrbzXeKZrijCMo9M58HKs3kWjs-CILqQMfdQkw2GY3kHH_taQiBf8gaEaL6PzKTSK9P5q7_Iac16Yoq1-hy0lzJKk0JXyaOg6jVBFiduww_6nNZgJpynwzaQJ6ohs9JEffcWOqanESgrWLbzQCJpkrrG9iQeCVfoSFOss5kvI595oahmbk9MdWONZ7JNAF8TTwcZNMXXWWCJVLaWkDOFi-ZWAy8rXYGp45Ofjw_mtHbBA',
                      ),
                    ),
                    Positioned(
                      left: 26,
                      child: _buildSmallAvatar(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuDX2Tn5stZ_okdusxrUK7RR5Nr5T23JLRYSCqcd561ER9l92kk8x5yim9o1fHSv_RRFMoFUIVTZG9LZj9IvWd4r2G6dYkWxt4dw1NNXlcFgcKHL0YAfqTw6wsmpOTR8mE0lD_Si_aR_tLBfZcrNpAhJtsA_jm28_degoIq7x8pw57DA5UALVCMwdpDB0R7x4CyFI9M2QMkjSn2b9Lzw1m8PtI9e6EEtdTs8C9E1u0OQ0-7mi1ApnsaO7ygRD3ggr4jtuEZSs8LzCJk',
                      ),
                    ),
                    Positioned(
                      left: 52,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.background, width: 2),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '+45',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSmallAvatar(String url) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.background, width: 2),
      ),
      child: ClipOval(
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              Container(color: AppColors.surfaceVariant),
        ),
      ),
    );
  }

  // ── Description ──
  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Event Description', style: AppTextStyles.headlineMedium),
        const SizedBox(height: 12),
        Text(
          _event.description ?? '',
          style: AppTextStyles.bodyMedium.copyWith(
            height: 1.6,
            color: AppColors.onSurfaceVariant,
          ),
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              'Read more',
              style: AppTextStyles.labelLarge.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.expand_more, size: 16, color: AppColors.primary),
          ],
        ),
      ],
    );
  }

  // ── BTC Team Section ──
  Widget _buildTeamSection() {
    return Column(
      children: [
        SectionHeader(
          title: 'BTC Team',
          titleStyle: AppTextStyles.headlineMedium,
          actionText: 'View All',
          onActionTap: () {},
        ),
        const SizedBox(height: 12),
        ...List.generate(
          _teamMembers.length,
          (i) => Padding(
            padding: EdgeInsets.only(bottom: i < _teamMembers.length - 1 ? 12 : 0),
            child: TeamMemberTile(member: _teamMembers[i]),
          ),
        ),
      ],
    );
  }
}
