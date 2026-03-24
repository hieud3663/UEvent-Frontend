// File: lib/views/user_profile_view.dart

import 'package:flutter/material.dart';
import '../apps/app_colors.dart';
import '../apps/app_constants.dart';
import '../apps/app_text_styles.dart';

import '../widgets/glass_top_bar.dart';
import '../widgets/glass_container.dart';

class UserProfileView extends StatefulWidget {
  final VoidCallback? onBack;
  const UserProfileView({super.key, this.onBack});

  @override
  State<UserProfileView> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<UserProfileView> {
  int _selectedTab = 0;
  final _tabs = ['Created', 'Upcoming', 'Finished'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
        SliverToBoxAdapter(child: GlassTopBar(
          title: 'PROFILE',
          titleStyle: AppTextStyles.titleMedium.copyWith(letterSpacing: 2, fontWeight: FontWeight.w700),
          leadingIcon: Icons.close,
          trailingIcon: Icons.more_vert,
          onLeadingTap: widget.onBack ?? () => Navigator.of(context).pop(),
        )),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        SliverToBoxAdapter(child: _buildProfileHeader()),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
        SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: _buildStats())),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: _buildTabs())),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: _buildEventList())),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ]),
    );
  }

  Widget _buildProfileHeader() {
    return Column(children: [
      Stack(alignment: Alignment.bottomRight, children: [
        Container(width: 112, height: 112, decoration: BoxDecoration(
          shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 4),
          boxShadow: [BoxShadow(color: AppColors.shadowNav, blurRadius: 20)],
        ), child: ClipOval(child: Image.network(
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAyErzTlXp9zTUqK8e5HiJWesNTOfm10_r_PwBXepemKvp1azWgTJAsFJJ7snljJsrTQulkOtMR9kLjkqonSvAXShUrveuMti8KGM5D-f6OVJouUop9N2kaqC5W_37NT0ujje2mjYinxeiOmIA1h6bBYsST_0xbefLJ6Fy7tWlS1OL1t5CFyCJZ5_vNtl2jJTv53homf79hhU0pUjNet7E-O1x01Cqh2Rm16YoGnZsETeXS4e1oJI4IkqzfhaISEsjxeBlSTJgL8NQ',
          fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: AppColors.surfaceVariant),
        ))),
        Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(
          color: AppColors.profilePrimary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2),
        ), child: const Icon(Icons.edit, size: 14, color: Colors.white)),
      ]),
      const SizedBox(height: 16),
      Text('Nguyen Van A', style: AppTextStyles.headlineLarge),
      const SizedBox(height: 4),
      Text('MSSV: 21520000', style: AppTextStyles.labelSmall.copyWith(letterSpacing: 2)),
      const SizedBox(height: 8),
      Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(9999),
      ), child: Text('Faculty of Computer Science', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant))),
      const SizedBox(height: 4),
      Text('Class: CS2021', style: AppTextStyles.bodySmall.copyWith(color: AppColors.navInactive)),
    ]);
  }

  Widget _buildStats() {
    return Row(children: [
      Expanded(child: GlassContainer(padding: const EdgeInsets.all(16), child: Column(children: [
        Text('12', style: AppTextStyles.statNumber),
        const SizedBox(height: 4),
        Text('EVENTS', style: AppTextStyles.labelSmall.copyWith(color: AppColors.navInactive)),
      ]))),
      const SizedBox(width: 16),
      Expanded(child: GlassContainer(padding: const EdgeInsets.all(16), child: Column(children: [
        Text('5', style: AppTextStyles.statNumber),
        const SizedBox(height: 4),
        Text('CLUBS', style: AppTextStyles.labelSmall.copyWith(color: AppColors.navInactive)),
      ]))),
    ]);
  }

  Widget _buildTabs() {
    return GlassContainer(padding: const EdgeInsets.all(4), borderRadius: 12, child: Row(
      children: List.generate(_tabs.length, (i) => Expanded(child: GestureDetector(
        onTap: () => setState(() => _selectedTab = i),
        child: AnimatedContainer(duration: AppConstants.animFast, padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(color: _selectedTab == i ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(8),
            boxShadow: _selectedTab == i ? [BoxShadow(color: AppColors.shadowSubtle, blurRadius: 4)] : null),
          alignment: Alignment.center,
          child: Text(_tabs[i], style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: _selectedTab == i ? FontWeight.w700 : FontWeight.w600,
            color: _selectedTab == i ? AppColors.profilePrimary : AppColors.navInactive)),
        ),
      ))),
    ));
  }

  Widget _buildEventList() {
    final events = [
      {'title': 'AI Workshop: Future Trends', 'date': 'Oct 24, 2024', 'status': 'Active',
        'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDdkReXA_HMyY2sg2TmNmA-4IKSGCAxEeujwXP3JVGJj0W4Fp-e8ZD9fWuA5E5qrskyF4NRB5d91S1BNFky_Z1ypIIoaLx8Q2SJ3-wEB1g35UyvfuhoydWjoKDdRfoQsn7WS60bJvGCLWDu8z8KnsMdbiLnK3R94M8rb6m46ifdmPrcjeOrtzS81sXSpFBfMVHEoIAFPHXmsoj1sT-xNAwTj_zt2RnRSbC4XhUnryanmY0SL_O-zAt87b4FgYgSbMvmnWkPFdNYteY'},
      {'title': 'Campus Open Mic Night', 'date': 'Oct 30, 2024', 'status': 'Draft',
        'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuByft2wTiNzS6FnbkbPZHJM7hAg7DcadGP94XTPOk7sXKdZ7fEzzpQ13Ho9er_gRbVaZbHC3fto9gJyBgmaggPFk5_22irpwRb8I9gPJxecwEkEs7it7AlXKz5nVd4gbEYCk2j3U_xSna_zTKF3KAcL7HuCYpychLHF0U69k_juvv_9srVqtc2rcBvWaUbctZV39KSW34SUPSOPnZEEc1u8gHVCqUicXZkrsseUeVZhb5sUL4xtgvrXzh-1PfTnUrrobNrxHp0JjRY'},
    ];

    return Column(children: events.map((e) => Padding(padding: const EdgeInsets.only(bottom: 16), child: GlassContainer(
      borderRadius: 12, child: Row(children: [
        SizedBox(width: 96, height: 96, child: ClipRRect(borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
          child: Image.network(e['image']!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: AppColors.surfaceVariant)))),
        Expanded(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(e['title']!, style: AppTextStyles.titleSmall.copyWith(fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Row(children: [const Icon(Icons.calendar_today, size: 12, color: AppColors.navInactive), const SizedBox(width: 4),
            Text(e['date']!, style: AppTextStyles.labelSmall.copyWith(color: AppColors.navInactive))]),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(
              color: e['status'] == 'Active' ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(9999)),
              child: Text(e['status']!, style: AppTextStyles.labelSmall.copyWith(
                color: e['status'] == 'Active' ? AppColors.primary : AppColors.navInactive))),
            const Icon(Icons.more_vert, size: 16, color: AppColors.navInactive),
          ]),
        ]))),
      ]),
    ))).toList());
  }
}
