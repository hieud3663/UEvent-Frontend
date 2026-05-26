import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/glass_container.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/core/widgets/primary_button.dart';
import 'package:frontend/features/app_setting/data/app_setting_legal.dart';

class PrivacyPolicyView extends StatelessWidget {
  final VoidCallback? onBack;
  final FutureOr<void> Function()? onAccept;

  const PrivacyPolicyView({super.key, this.onBack, this.onAccept});

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
                        'Chính sách quyền riêng tư',
                        style: AppTextStyles.headlineLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Cập nhật lần cuối: ${AppSettingLegal.privacyPolicyUpdatedLabel}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 32),

                      GlassContainer(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '1. Thu thập dữ liệu',
                              style: AppTextStyles.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Chúng tôi thu thập thông tin bạn cung cấp trực tiếp, chẳng hạn khi bạn tạo tài khoản, cập nhật hồ sơ, sử dụng tính năng tương tác, tham gia chương trình, yêu cầu hỗ trợ hoặc liên hệ với chúng tôi.',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.onSurfaceVariant,
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 24),

                            Text(
                              '2. Sử dụng thông tin',
                              style: AppTextStyles.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Chúng tôi sử dụng thông tin đã thu thập để cung cấp, duy trì, cải thiện dịch vụ, phát triển tính năng mới và bảo vệ UEvents cùng người dùng.',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.onSurfaceVariant,
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 24),

                            Text(
                              '3. Chia sẻ thông tin',
                              style: AppTextStyles.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Chúng tôi không chia sẻ thông tin cá nhân của bạn với công ty, tổ chức hoặc cá nhân bên ngoài UEvents, trừ khi có sự đồng ý của bạn, yêu cầu pháp lý hoặc quản trị viên miền liên quan.',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.onSurfaceVariant,
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 24),

                            Text(
                              '4. Bảo mật dữ liệu',
                              style: AppTextStyles.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Chúng tôi nỗ lực bảo vệ UEvents và người dùng khỏi truy cập trái phép, thay đổi, tiết lộ hoặc phá hủy thông tin mà chúng tôi lưu giữ.',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.onSurfaceVariant,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      PrimaryButton(
                        label: 'Tôi đã đọc và đồng ý',
                        onPressed: onAccept == null
                            ? null
                            : () {
                                unawaited(Future.sync(onAccept!));
                              },
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
              title: 'Chính sách quyền riêng tư',
              leadingIcon: Icons.chevron_left,
              onLeadingTap: onBack,
            ),
          ),
        ],
      ),
    );
  }
}
