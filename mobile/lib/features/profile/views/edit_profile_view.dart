import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/core/widgets/glass_input_field.dart';
import 'package:frontend/core/widgets/primary_button.dart';

class EditProfileView extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onSave;

  const EditProfileView({
    super.key,
    this.onBack,
    this.onSave,
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
                      // Photo Section
                      Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 112,
                                height: 112,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 4),
                                  color: AppColors.outlineVariant,
                                ),
                                child: const Icon(Icons.person, size: 64, color: Colors.white),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryContainer,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    color: AppColors.onPrimaryContainer,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'CHANGE PHOTO',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 48),

                      // Form
                      const GlassInputField(
                        label: 'FULL NAME',
                        placeholder: 'Alexander J. Nguyen',
                        leadingIcon: Icons.person,
                      ),
                      const SizedBox(height: 24),

                      const GlassInputField(
                        label: 'STUDENT ID (MSSV)',
                        placeholder: '20215432',
                        leadingIcon: Icons.badge,
                      ),
                      const SizedBox(height: 24),

                      const GlassInputField(
                        label: 'CLASS',
                        placeholder: 'Software Engineering K66',
                        leadingIcon: Icons.school,
                      ),
                      const SizedBox(height: 24),

                      const GlassInputField(
                        label: 'DEPARTMENT',
                        placeholder: 'Computer Science',
                        leadingIcon: Icons.account_balance,
                      ),
                      const SizedBox(height: 48),

                      PrimaryButton(
                        label: 'Save Changes',
                        onPressed: onSave,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Last updated on 12 Oct, 2023',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Top Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GlassTopBar(
              title: 'Edit Profile',
              leadingIcon: Icons.chevron_left,
              onLeadingTap: onBack,
              trailingIcon: Icons.more_vert,
            ),
          ),
        ],
      ),
    );
  }
}
