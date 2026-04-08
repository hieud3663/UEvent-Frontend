import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/core/widgets/glass_container.dart';

class HelpCenterView extends StatelessWidget {
  final VoidCallback? onBack;

  const HelpCenterView({
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
                        'How can we help?',
                        style: AppTextStyles.headlineLarge,
                      ),
                      const SizedBox(height: 24),
                      
                      // Search Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                const Icon(Icons.search, color: AppColors.outline),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: 'Search for answers...',
                                      hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.outline),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // FAQ Section
                      Text(
                        'FREQUENTLY ASKED QUESTIONS',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GlassContainer(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            _buildFaqItem('How do I register for an event?'),
                            Divider(height: 1, color: Colors.black.withValues(alpha: 0.05)),
                            _buildFaqItem('How do I cancel my registration?'),
                            Divider(height: 1, color: Colors.black.withValues(alpha: 0.05)),
                            _buildFaqItem('Are there waitlists for events?'),
                            Divider(height: 1, color: Colors.black.withValues(alpha: 0.05)),
                            _buildFaqItem('How do I get my ticket?'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Contact Support Option
                      Text(
                        'STILL NEED HELP?',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GlassContainer(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.support_agent, color: AppColors.primary),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Contact Support', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
                                  Text('We usually reply within 24 hours', style: AppTextStyles.bodySmall),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.outline),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
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
              title: 'Help Center',
              leadingIcon: Icons.chevron_left,
              onLeadingTap: onBack,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String title) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(title, style: AppTextStyles.bodyMedium)),
          const Icon(Icons.expand_more, color: AppColors.outline),
        ],
      ),
    );
  }
}
