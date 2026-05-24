// File: lib/features/user_events/views/home_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/features/event_shared/models/event_model.dart';
import 'package:frontend/features/user_events/providers/user_event_providers.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/core/widgets/glass_bottom_nav_bar.dart';
import 'package:frontend/features/event_shared/widgets/event_card.dart';
import 'package:frontend/core/widgets/section_header.dart';
import 'package:frontend/core/widgets/glass_container.dart';
import 'package:frontend/core/widgets/async_state_slivers.dart';

class HomeView extends ConsumerWidget {
  final int currentNavIndex;
  final ValueChanged<int> onNavTap;
  final VoidCallback? onNotificationsTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onCreateEventTap;
  final ValueChanged<EventModel>? onEventTap;

  const HomeView({
    super.key,
    this.currentNavIndex = 0,
    required this.onNavTap,
    this.onNotificationsTap,
    this.onProfileTap,
    this.onCreateEventTap,
    this.onEventTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myEventsAsync = ref.watch(userMyEventsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Main scrollable content
          CustomScrollView(
            slivers: [
              // Top bar spacing so content starts below fixed bar
              const SliverToBoxAdapter(child: SizedBox(height: 100)),

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
              ...myEventsAsync.when(
                data: (events) {
                  return [
                    AppSuccessSliver(
                      isEmpty: events.isEmpty,
                      emptyIcon: Icons.event_busy,
                      emptyTitle: 'Chua co su kien',
                      emptyDescription:
                          'Ban chua co su kien nao trong danh sach cua minh.',
                      contentSlivers: [
                        SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final event = events[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppConstants.pagePaddingH,
                                vertical: 8,
                              ),
                              child: EventCard(
                                event: event,
                                formattedDate: DateFormat(
                                  'EEE, d MMM',
                                ).format(event.startDate),
                                trailing: _buildQrButton(),
                                onTap: onEventTap != null
                                    ? () => onEventTap!(event)
                                    : null,
                              ),
                            );
                          }, childCount: events.length),
                        ),
                      ],
                    ),
                  ];
                },
                loading: () => [const AppLoadingSliver()],
                error: (error, _) => [
                  AppErrorSliver(
                    title: 'Tai du lieu that bai',
                    description:
                        'Khong the lay danh sach su kien. Keo xuong de thu lai.',
                    onRetry: () => ref.refresh(userMyEventsProvider),
                  ),
                ],
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
                        'Khám phá hôm nay',
                        style: AppTextStyles.headlineLarge.copyWith(
                          fontSize: 24,
                        ),
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

          // // FAB
          // Positioned(
          //   bottom:
          //       AppConstants.bottomNavOffset +
          //       AppConstants.bottomNavHeight +
          //       16,
          //   right: 24,
          //   child: GestureDetector(onTap: onCreateEventTap, child: _buildFab()),
          // ),

          // Top Bar Fixed
          Positioned(
            top: 0,
            left: 0,
            right: 0,
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
        child: CachedNetworkImage(
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuAyErzTlXp9zTUqK8e5HiJWesNTOfm10_r_PwBXepemKvp1azWgTJAsFJJ7snljJsrTQulkOtMR9kLjkqonSvAXShUrveuMti8KGM5D-f6OVJouUop9N2kaqC5W_37NT0ujje2mjYinxeiOmIA1h6bBYsST_0xbefLJ6Fy7tWlS1OL1t5CFyCJZ5_vNtl2jJTv53homf79hhU0pUjNet7E-O1x01Cqh2Rm16YoGnZsETeXS4e1oJI4IkqzfhaISEsjxeBlSTJgL8NQ',
          fit: BoxFit.cover,
          memCacheWidth: 96,
          maxWidthDiskCache: 192,
          errorWidget: (context, url, error) => Container(
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
        boxShadow: [BoxShadow(color: AppColors.shadowSubtle, blurRadius: 4)],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl:
                'https://lh3.googleusercontent.com/aida-public/AB6AXuBKAOqXIg7Fd-ODNI2iA-TbQTc1BJoSEy4yKngPaqNEVxf3-y916SQLxrQaH4NvTthP_Db5oGhPTM5O8wBw7pJ33gXb0nj_X2rfVGKNFZ-zn56VtMOTnAT36BCXD2NK36mTB_zpIUB5g0k0B3zD_7uQXqXbD_w-If67-TtSBs-SFVkTUDlaz_AeItZgnTjdE2ZYNeju9jAaUKozQEAG65aVzZ5Zsq0k521yuugQN2V0EjEy70Vb1_CgLsyivemWIl_GoBQJ9YQz0qs',
            fit: BoxFit.cover,
            memCacheWidth: 1280,
            maxWidthDiskCache: 1920,
            errorWidget: (context, url, error) =>
                Container(color: AppColors.onSurface),
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
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusFull,
                    ),
                  ),
                  child: Text('NỔI BẬT', style: AppTextStyles.badge),
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
                Text('Dành riêng cho bạn', style: AppTextStyles.titleSmall),
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
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          memCacheWidth: 72,
          maxWidthDiskCache: 160,
          errorWidget: (context, url, error) =>
              Container(color: AppColors.surfaceVariant),
        ),
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

  // Widget _buildFab() {
  //   return Container(
  //     decoration: BoxDecoration(
  //       color: AppColors.primary,
  //       borderRadius: BorderRadius.circular(AppConstants.radiusFull),
  //       boxShadow: [
  //         BoxShadow(
  //           color: AppColors.shadowPrimary,
  //           blurRadius: 14,
  //           offset: const Offset(0, 4),
  //         ),
  //       ],
  //     ),
  //     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
  //     child: const Row(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         Icon(Icons.add, color: Colors.white, size: 24),
  //         SizedBox(width: 8),
  //         Text(
  //           'Tạo sự kiện',
  //           style: TextStyle(
  //             fontFamily: 'Inter',
  //             fontWeight: FontWeight.w700,
  //             fontSize: 14,
  //             color: Colors.white,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
