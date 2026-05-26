import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/core/widgets/primary_button.dart';

class SendFeedbackView extends StatelessWidget {
  final VoidCallback? onBack;
  final FutureOr<void> Function()? onRate;

  const SendFeedbackView({super.key, this.onBack, this.onRate});

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
                      const SizedBox(height: 32),
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.star_rate,
                          size: 48,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Đánh giá UEvents trên Play Store',
                        style: AppTextStyles.headlineLarge,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Feedback trong app được chuyển sang đánh giá công khai trên Play Store. Khi cần báo lỗi riêng hoặc gửi yêu cầu hỗ trợ, hãy dùng Trung tâm hỗ trợ.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      PrimaryButton(
                        label: 'Mở Play Store',
                        icon: Icons.open_in_new,
                        onPressed: onRate == null ? null : () => onRate!(),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: onBack,
                        child: Text(
                          'Để sau',
                          style: AppTextStyles.titleSmall.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
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
              title: 'Đánh giá',
              leadingIcon: Icons.chevron_left,
              onLeadingTap: onBack,
            ),
          ),
        ],
      ),
    );
  }
}
