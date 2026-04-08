import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/core/widgets/glass_container.dart';

class PrivacyPolicyView extends StatelessWidget {
  final VoidCallback? onBack;

  const PrivacyPolicyView({
    super.key,
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
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      Text(
                        'Privacy Policy',
                        style: AppTextStyles.headlineLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Last updated: October 2023',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                      const SizedBox(height: 32),

                      GlassContainer(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('1. Data Collection', style: AppTextStyles.titleMedium),
                            const SizedBox(height: 8),
                            Text(
                              'We collect information you provide directly to us, such as when you create an account, update your profile, use the interactive features of our services, participate in a contest or promotion, request customer support or otherwise communicate with us.',
                              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant, height: 1.6),
                            ),
                            const SizedBox(height: 24),

                            Text('2. Use of Information', style: AppTextStyles.titleMedium),
                            const SizedBox(height: 8),
                            Text(
                              'We use the information we collect to provide, maintain, and improve our services, to develop new ones, and to protect UEvents and our users.',
                              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant, height: 1.6),
                            ),
                            const SizedBox(height: 24),

                            Text('3. Information Sharing', style: AppTextStyles.titleMedium),
                            const SizedBox(height: 8),
                            Text(
                              'We do not share your personal information with companies, organizations, or individuals outside of UEvents except in the following cases: With your consent, for legal reasons, or with domain administrators.',
                              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant, height: 1.6),
                            ),
                            const SizedBox(height: 24),
                            
                            Text('4. Data Security', style: AppTextStyles.titleMedium),
                            const SizedBox(height: 8),
                            Text(
                              'We work hard to protect UEvents and our users from unauthorized access to or unauthorized alteration, disclosure or destruction of information we hold.',
                              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant, height: 1.6),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ],
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GlassTopBar(
              title: 'Privacy Policy',
              leadingIcon: Icons.chevron_left,
              onLeadingTap: onBack,
            ),
          ),
        ],
      ),
    );
  }
}
