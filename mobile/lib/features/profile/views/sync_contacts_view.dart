import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/core/widgets/primary_button.dart';

class SyncContactsView extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onSync;

  const SyncContactsView({
    super.key,
    this.onBack,
    this.onSync,
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
                    children: [
                      const SizedBox(height: 40),
                      // Illustration
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const Icon(
                              Icons.connect_without_contact,
                              size: 80,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 48),

                      Text(
                        'Find Your Friends',
                        style: AppTextStyles.headlineLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Sync your contacts to easily find and connect with friends who are already on UEvents. We will only use this to suggest connections.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 16,
                          color: AppColors.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 64),

                      PrimaryButton(
                        label: 'Sync Contacts',
                        onPressed: onSync,
                      ),
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: onBack,
                        child: Text(
                          'Maybe Later',
                          style: AppTextStyles.titleSmall.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
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
              title: 'Sync Contacts',
              leadingIcon: Icons.chevron_left,
              onLeadingTap: onBack,
            ),
          ),
        ],
      ),
    );
  }
}
