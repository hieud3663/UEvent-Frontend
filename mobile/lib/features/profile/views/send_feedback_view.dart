import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/core/widgets/primary_button.dart';

class SendFeedbackView extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onSubmit;

  const SendFeedbackView({super.key, this.onBack, this.onSubmit});

  @override
  State<SendFeedbackView> createState() => _SendFeedbackViewState();
}

class _SendFeedbackViewState extends State<SendFeedbackView> {
  String selectedCategory = 'Bug Report';
  final List<String> categories = [
    'Bug Report',
    'Feature Request',
    'General',
    'Other',
  ];

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
                        'We value your feedback',
                        style: AppTextStyles.headlineLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Let us know how we can improve your UEvents experience.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Category Selection
                      Text(
                        'CATEGORY',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: categories.map((cat) {
                          final isSelected = selectedCategory == cat;
                          return GestureDetector(
                            onTap: () => setState(() => selectedCategory = cat),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.white.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.outlineVariant,
                                ),
                              ),
                              child: Text(
                                cat,
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.onSurfaceVariant,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 32),

                      // Message Input
                      Text(
                        'MESSAGE',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Container(
                            height: 200,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.5),
                              border: Border.all(color: Colors.white, width: 1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: TextField(
                              maxLines: null,
                              decoration: InputDecoration(
                                hintText:
                                    'Vui lòng mô tả chi tiết vấn đề hoặc góp ý của bạn...',
                                hintStyle: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.outline,
                                ),
                                border: InputBorder.none,
                              ),
                              style: AppTextStyles.bodyMedium,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),

                      PrimaryButton(
                        label: 'Gửi góp ý',
                        onPressed: widget.onSubmit,
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
              title: 'Góp ý',
              leadingIcon: Icons.chevron_left,
              onLeadingTap: widget.onBack,
            ),
          ),
        ],
      ),
    );
  }
}
