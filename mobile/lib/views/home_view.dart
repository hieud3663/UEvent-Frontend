// File: lib/views/home_view.dart

import 'package:flutter/material.dart';
import '../apps/app_colors.dart';
import '../apps/app_constants.dart';
import '../apps/app_text_styles.dart';
import '../models/event_model.dart';
import '../widgets/glass_top_bar.dart';
import '../widgets/glass_bottom_nav_bar.dart';
import '../widgets/event_card.dart';
import '../widgets/section_header.dart';
import '../widgets/glass_container.dart';

class HomeView extends StatelessWidget {
  final int currentNavIndex;
  final ValueChanged<int> onNavTap;
  final VoidCallback? onNotificationsTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onCreateEventTap;

  const HomeView({
    super.key,
    this.currentNavIndex = 0,
    required this.onNavTap,
    this.onNotificationsTap,
    this.onProfileTap,
    this.onCreateEventTap,
  });

  // ── Mock Data ──
  static final List<EventModel> _myEvents = [
    EventModel(
      id: '1',
      title: 'Workshop Nhiếp Ảnh Căn Bản',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDuQsHATzTyDapvZjwkwkqCQweROKenFuGknzW9zUSqCQ0xGGI-3qyWIiUnQJxDofLYUmsCW77RKctoWOORYZ-C9VOyfO5onLl-SmmowvJANUGB1UyC5A6a0EZQq4ftjYn4uwWDxJC8K9QoXfIsGL927GPIeLulzLMSGWxyX2SEnL4PslhXvvwPVKIHgIt39Gl3rUlExwAcByDM3_wG9X6y5SjcOyOPvEgM06SayCpfP7qpiOJVnbxwMrfQl1gKtphIwFpFLtgmKfo',
      location: 'The Lab Studio, Quận 1',
      startDate: DateTime(2025, 5, 24),
    ),
    EventModel(
      id: '2',
      title: 'Lễ Hội Âm Nhạc Bãi Biển',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCvPC6lDKFEGyp8qY0ujcdU-w6F0GxOiIf9IWYTiyqNVfaB2IsxrVELFRzOzTTTx_IFCPh2lT7rqdNq26lIm7lx2dEdbUfRGcePsJm4RFW5HitgpSxYG3dS9vgW887rZ1YfXnLi0l1gVoF27EjJa8qS_su4uIcHVXB_P6kqtfbSM3BDOsMFSmrex-BlYAWmtAWHvazbxc_C2SoHgd8-nimw1-dhDMWGCLQryvxL3CNp11FC_4bc6FH4u0NRROb6PA29MkQtDIYnaM0',
      location: 'Vũng Tàu Beach Club',
      startDate: DateTime(2025, 5, 25),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Main scrollable content
          CustomScrollView(
            slivers: [
              // Top bar spacing
              const SliverToBoxAdapter(child: SizedBox(height: 8)),

              // Top bar
              SliverToBoxAdapter(
                child: GlassTopBar(
                  title: 'UEvents',
                  titleStyle: AppTextStyles.titleLarge,
                  leadingWidget: GestureDetector(
                    onTap: onProfileTap,
                    child: _buildAvatar(),
                  ),
                  trailingIcon: Icons.notifications_outlined,
                  onTrailingTap: onNotificationsTap,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // ── Your Events Section ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.pagePaddingH,
                  ),
                  child: SectionHeader(
                    title: 'Sự kiện của bạn',
                    actionText: 'XEM TẤT CẢ',
                    onActionTap: () {},
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final event = _myEvents[index];
                    final dates = [
                      'Thứ 7, 24 Th05',
                      'Chủ nhật, 25 Th05',
                    ];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.pagePaddingH,
                        vertical: 8,
                      ),
                      child: EventCard(
                        event: event,
                        formattedDate: dates[index],
                        trailing: _buildQrButton(),
                      ),
                    );
                  },
                  childCount: _myEvents.length,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),

              // ── Welcome Section ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.pagePaddingH,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CHÀO MỪNG QUAY LẠI',
                        style: AppTextStyles.labelSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Khám phá hôm nay',
                        style: AppTextStyles.headlineLarge.copyWith(fontSize: 24),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // ── Featured Bento Grid ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.pagePaddingH,
                  ),
                  child: _buildBentoGrid(),
                ),
              ),

              // Bottom spacing for nav bar
              const SliverToBoxAdapter(child: SizedBox(height: 140)),
            ],
          ),

          // FAB
          Positioned(
            bottom: AppConstants.bottomNavOffset + AppConstants.bottomNavHeight + 16,
            right: 24,
            child: GestureDetector(
              onTap: onCreateEventTap,
              child: _buildFab(),
            ),
          ),

          // Bottom Nav
          GlassBottomNavBar(
            currentIndex: currentNavIndex,
            onTap: onNavTap,
            items: GlassBottomNavBar.defaultItems,
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 48,
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: ClipOval(
        child: Image.network(
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAyErzTlXp9zTUqK8e5HiJWesNTOfm10_r_PwBXepemKvp1azWgTJAsFJJ7snljJsrTQulkOtMR9kLjkqonSvAXShUrveuMti8KGM5D-f6OVJouUop9N2kaqC5W_37NT0ujje2mjYinxeiOmIA1h6bBYsST_0xbefLJ6Fy7tWlS1OL1t5CFyCJZ5_vNtl2jJTv53homf79hhU0pUjNet7E-O1x01Cqh2Rm16YoGnZsETeXS4e1oJI4IkqzfhaISEsjxeBlSTJgL8NQ',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: AppColors.surfaceVariant,
            child: const Icon(Icons.person, color: AppColors.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildQrButton() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.4),
          width: 0.5,
        ),
      ),
      child: const Icon(Icons.qr_code_2, color: AppColors.primary),
    );
  }

  Widget _buildBentoGrid() {
    return Column(
      children: [
        // Featured large card
        _buildFeaturedCard(),
        const SizedBox(height: 16),
        // Two small cards
        Row(
          children: [
            Expanded(child: _buildInfoCard()),
            const SizedBox(width: 16),
            Expanded(child: _buildTicketCard()),
          ],
        ),
      ],
    );
  }

  Widget _buildFeaturedCard() {
    return Container(
      height: AppConstants.featuredCardHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        boxShadow: [BoxShadow(color: AppColors.shadowSubtle, blurRadius: 8)],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://lh3.googleusercontent.com/aida-public/AB6AXuBKAOqXIg7Fd-ODNI2iA-TbQTc1BJoSEy4yKngPaqNEVxf3-y916SQLxrQaH4NvTthP_Db5oGhPTM5O8wBw7pJ33gXb0nj_X2rfVGKNFZ-zn56VtMOTnAT36BCXD2NK36mTB_zpIUB5g0k0B3zD_7uQXqXbD_w-If67-TtSBs-SFVkTUDlaz_AeItZgnTjdE2ZYNeju9jAaUKozQEAG65aVzZ5Zsq0k521yuugQN2V0EjEy70Vb1_CgLsyivemWIl_GoBQJ9YQz0qs',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: AppColors.onSurface),
          ),
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.2),
                  Colors.black.withValues(alpha: 0.8),
                ],
              ),
            ),
          ),
          // Content
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                  ),
                  child: Text(
                    'NỔI BẬT',
                    style: AppTextStyles.badge,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Đêm Nhạc Indie 2024',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Trung tâm Triển lãm SECC',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        height: AppConstants.bentoCardHeight - 40,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.auto_awesome, color: AppColors.primary),
                const SizedBox(height: 8),
                Text(
                  'Dành riêng cho bạn',
                  style: AppTextStyles.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Dựa trên sở thích âm nhạc và nghệ thuật của bạn.',
                  style: AppTextStyles.bodySmall.copyWith(height: 1.3),
                ),
              ],
            ),
            // Avatars row — overlapping via Stack
            SizedBox(
              height: 32,
              width: 80,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    child: _buildMiniAvatar(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuDSLwAnvG7daEh2lahLNj7CYE-yJJN-_z87uzTDwmaFJBMQbESSDhnW62JXpr2L8QoIBJ7cvQOJNfgJvCN_MEz7F1kDtnLodoPByIBLtvF4LNGMt8oxX5IDwXCCR7cL0x1jfH_dOIXaTDNUZRUzf4vqWkTJWsXzB-OeNHmMiORR-MWjSVeI-sdeZ8l0XS-mII3qfYWxgZL3DjWVJ_KHXUuOtbJrJ0SMcd7vrduF6TQiW-H2qKiqkkGTlMRT2M65_YHkdBhfTZHMk6k',
                    ),
                  ),
                  Positioned(
                    left: 22,
                    child: _buildMiniAvatar(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuCRrq281VVC6U6rUFJysUUAd3wPqGVnrul4FQX_L1Kcy_PvL8UDodutBz279GlhnQtMHLTN1E49H-gkLLdzHB8caqfgXzbnOqHWEtGDDqry9gYrSsoLOMLyvk5-E_I4kcHtNEoLydBH6x_q8LwOF94J4pk4bBxbIV5lEuzXHzUq_gdXPa6Igdp0TRPPN4S6y5nSVLClVUzJAYQ3J-OnAA-zCPck2r6I49OXvrug1KOelrJWh5cp_DZ_zdn-ZvLyk6a009wM4FYPRb4',
                    ),
                  ),
                  Positioned(
                    left: 44,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDE68A),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        '+12',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFD97706),
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
    );
  }

  Widget _buildMiniAvatar(String url) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: ClipOval(
        child: Image.network(url, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: AppColors.surfaceVariant)),
      ),
    );
  }

  Widget _buildTicketCard() {
    return Container(
      height: AppConstants.bentoCardHeight,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowPrimary.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.confirmation_number, color: Colors.white, size: 32),
          const SizedBox(height: 4),
          const Text(
            '2 Vé mới',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Đã sẵn sàng trong ví của bạn',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFab() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowPrimary,
            blurRadius: 25,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add, color: Colors.white, size: 24),
          SizedBox(width: 8),
          Text(
            'Tạo sự kiện',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
