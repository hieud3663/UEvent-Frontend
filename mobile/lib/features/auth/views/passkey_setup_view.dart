import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/core/widgets/primary_button.dart';
import 'package:frontend/core/widgets/glass_container.dart';

class PasskeySetupView extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onCreatePasskey;

  const PasskeySetupView({
    super.key,
    this.onBack,
    this.onCreatePasskey,
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
                      const SizedBox(height: 32),
                      // Illustration
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primaryContainer.withValues(alpha: 0.3),
                                  width: 2,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.vpn_key,
                              size: 56,
                              color: AppColors.primaryContainer,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'The Future of Security',
                        style: AppTextStyles.headlineLarge.copyWith(fontSize: 24),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Passkeys are a safer and easier replacement for passwords. Use your face or fingerprint to sign in securely.',
                        style: AppTextStyles.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),

                      // Bento grid - rendered as list
                      _buildBentoItem(
                        icon: Icons.verified_user,
                        title: 'Hack-Proof Protection',
                        desc: 'Passkeys are unique to your account and never shared with our servers.',
                      ),
                      const SizedBox(height: 16),
                      _buildBentoItem(
                        icon: Icons.speed,
                        title: 'Instant Sign-In',
                        desc: 'Forget remembering complex characters. Use FaceID or TouchID.',
                      ),
                      const SizedBox(height: 16),
                      _buildBentoItem(
                        icon: Icons.sync,
                        title: 'Seamless Syncing',
                        desc: 'Your passkeys are safely stored across all your devices.',
                      ),
                      const SizedBox(height: 40),

                      // Current Status
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16, bottom: 8),
                          child: Text(
                            'CURRENT STATUS',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                      GlassContainer(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Active Passkeys', style: AppTextStyles.bodyMedium),
                                  Text('0 Found', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant)),
                                ],
                              ),
                            ),
                            Divider(height: 1, color: Colors.black.withValues(alpha: 0.05)),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Security Level', style: AppTextStyles.bodyMedium),
                                  Row(
                                    children: [
                                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle)),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Enhancement Needed',
                                        style: AppTextStyles.labelMedium.copyWith(color: AppColors.error),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),

                      PrimaryButton(
                        label: 'Create Passkey',
                        icon: Icons.add_circle,
                        onPressed: onCreatePasskey,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'SECURELY STORED IN YOUR VAULT',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
                          letterSpacing: 1.5,
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
              title: 'Passkey Login',
              leadingIcon: Icons.chevron_left,
              onLeadingTap: onBack,
              trailingIcon: Icons.more_horiz,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBentoItem({required IconData icon, required String title, required String desc}) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.primaryContainer, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(desc, style: AppTextStyles.bodySmall),
              ],
            ),
          )
        ],
      ),
    );
  }
}
