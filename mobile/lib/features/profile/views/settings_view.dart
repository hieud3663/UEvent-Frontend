import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/core/widgets/glass_bottom_nav_bar.dart';
import 'package:frontend/core/widgets/glass_container.dart';
import 'package:frontend/features/profile/widgets/settings_group.dart';
import 'package:frontend/features/profile/widgets/settings_tiles.dart';

class SettingsView extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onEditProfile;
  final VoidCallback? onChangeEmail;
  final VoidCallback? onPasskeyLogin;
  final VoidCallback? onTwoFactorAuth;
  final VoidCallback? onHelpCenter;
  final VoidCallback? onSendFeedback;
  final VoidCallback? onPrivacyPolicy;
  final VoidCallback? onSyncContacts;
  final VoidCallback? onSignOut;

  const SettingsView({
    super.key,
    this.onBack,
    this.onEditProfile,
    this.onChangeEmail,
    this.onPasskeyLogin,
    this.onTwoFactorAuth,
    this.onHelpCenter,
    this.onSendFeedback,
    this.onPrivacyPolicy,
    this.onSyncContacts,
    this.onSignOut,
  });

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _pushNotifications = true;
  bool _passkeyLogin = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.1),
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withValues(alpha: 0.1), blurRadius: 120)
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.05),
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withValues(alpha: 0.05), blurRadius: 100)
                ],
              ),
            ),
          ),

          // Main Content
          CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 100)), // Top offset
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Profile Header
                      Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.background, width: 4),
                                  gradient: const LinearGradient(
                                    colors: [AppColors.primary, Color(0xFFFEF08A)],
                                  ),
                                ),
                                padding: const EdgeInsets.all(2),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  child: const Icon(Icons.person, size: 48, color: AppColors.outline),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.primary,
                                    border: Border.all(color: AppColors.background, width: 2),
                                  ),
                                  child: const Icon(Icons.photo_camera, size: 16, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text('Alex Rivera', style: AppTextStyles.titleLarge),
                          const SizedBox(height: 4),
                          Text('alex.rivera@uevents.com', style: AppTextStyles.bodyMedium),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: widget.onEditProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                              elevation: 4,
                              shadowColor: AppColors.primary.withValues(alpha: 0.4),
                            ),
                            child: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),

                      // Account Group
                      SettingsGroup(
                        title: 'Account',
                        children: [
                          SettingsActionTile(
                            icon: Icons.mail,
                            title: 'Change Email',
                            onTap: widget.onChangeEmail ?? () {},
                          ),
                        ],
                      ),

                      // Security Group
                      SettingsGroup(
                        title: 'Security',
                        children: [
                          SettingsToggleTile(
                            icon: Icons.vpn_key,
                            title: 'Passkey Login',
                            value: _passkeyLogin,
                            onChanged: (val) {
                              setState(() => _passkeyLogin = val);
                              if (val) widget.onPasskeyLogin?.call();
                            },
                          ),
                          SettingsActionTile(
                            icon: Icons.security,
                            title: 'Two-Factor Authentication',
                            valueText: 'Active',
                            onTap: widget.onTwoFactorAuth ?? () {},
                          ),
                        ],
                      ),

                      // Permissions Group
                      SettingsGroup(
                        title: 'Permissions',
                        children: [
                          SettingsToggleTile(
                            icon: Icons.notifications,
                            title: 'Push Notifications',
                            value: _pushNotifications,
                            onChanged: (val) => setState(() => _pushNotifications = val),
                          ),
                          SettingsActionTile(
                            icon: Icons.location_on,
                            title: 'Location Services',
                            valueText: 'While Using',
                            onTap: () {},
                          ),
                          SettingsActionTile(
                            icon: Icons.contacts,
                            title: 'Sync Contacts',
                            onTap: widget.onSyncContacts ?? () {},
                          ),
                        ],
                      ),

                      // Support Group
                      SettingsGroup(
                        title: 'Support',
                        children: [
                          SettingsActionTile(
                            icon: Icons.help_center,
                            title: 'Help Center',
                            onTap: widget.onHelpCenter ?? () {},
                          ),
                          SettingsActionTile(
                            icon: Icons.chat_bubble_outline,
                            title: 'Send Feedback',
                            onTap: widget.onSendFeedback ?? () {},
                          ),
                          SettingsActionTile(
                            icon: Icons.privacy_tip,
                            title: 'Privacy Policy',
                            onTap: widget.onPrivacyPolicy ?? () {},
                          ),
                        ],
                      ),

                      // Sign Out
                      GestureDetector(
                        onTap: widget.onSignOut,
                        child: GlassContainer(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.logout, color: Colors.red),
                              const SizedBox(width: 8),
                              Text(
                                'Sign Out',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                      Center(
                        child: Text(
                          'Version 4.2.0 (Premium Build)',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                      const SizedBox(height: 120), // Bottom nav offset
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Glass Top Bar Fixed
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GlassTopBar(
              title: 'Settings',
              leadingIcon: Icons.close,
              onLeadingTap: widget.onBack,
              trailingIcon: Icons.more_vert,
            ),
          ),
          
          // Fixed Bottom Bar mock (for representation if it's the main settings screen, 
          // usually this is part of Scaffold's bottomNavigationBar, but we'll include it here aligned with design)
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: GlassBottomNavBar(
              currentIndex: 3,
              items: GlassBottomNavBar.defaultItems,
              onTap: (_) {},
            ),
          ),
        ],
      ),
    );
  }
}
