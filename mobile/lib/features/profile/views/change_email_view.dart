import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/core/widgets/glass_input_field.dart';
import 'package:frontend/core/widgets/primary_button.dart';

class ChangeEmailView extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onSave;

  const ChangeEmailView({
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      Text(
                        'Change Email Address',
                        style: AppTextStyles.headlineLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your current email address is alex.rivera@uevents.com',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                      const SizedBox(height: 48),

                      const GlassInputField(
                        label: 'NEW EMAIL ADDRESS',
                        placeholder: 'Enter new email address',
                        leadingIcon: Icons.mail_outline,
                      ),
                      const SizedBox(height: 24),

                      const GlassInputField(
                        label: 'CONFIRM PASSWORD',
                        placeholder: 'Enter current password',
                        leadingIcon: Icons.lock_outline,
                        obscureText: true,
                      ),
                      const SizedBox(height: 48),

                      PrimaryButton(
                        label: 'Update Email',
                        onPressed: onSave,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'We will send a verification link to your new email address. Please follow the link to complete the change.',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
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
              title: 'Change Email',
              leadingIcon: Icons.chevron_left,
              onLeadingTap: onBack,
            ),
          ),
        ],
      ),
    );
  }
}
