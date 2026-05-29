import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/glass_container.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/core/widgets/primary_button.dart';
import 'package:frontend/features/app_setting/models/app_setting_key.dart';
import 'package:frontend/features/app_setting/providers/app_setting_providers.dart';
import 'package:frontend/features/profile/models/help_center_models.dart';
import 'package:frontend/features/profile/providers/profile_providers.dart';

class PrivacyPolicyView extends ConsumerWidget {
  final VoidCallback? onBack;
  final FutureOr<void> Function(String version)? onAccept;

  const PrivacyPolicyView({super.key, this.onBack, this.onAccept});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final policyAsync = ref.watch(privacyPolicyProvider('vi'));
    final acceptedVersion = ref
        .watch(appSettingControllerProvider)
        .value
        ?.stringValue(AppSettingKey.legalPrivacyPolicyAcceptedVersion);

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
                  child: policyAsync.when(
                    data: (policy) => _PolicyContent(
                      policy: policy,
                      acceptedVersion: acceptedVersion,
                      onAccept: onAccept,
                    ),
                    loading: () => const Padding(
                      padding: EdgeInsets.only(top: 160),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (error, stackTrace) => _PolicyError(
                      onRetry: () =>
                          ref.invalidate(privacyPolicyProvider('vi')),
                    ),
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

class _PolicyContent extends StatelessWidget {
  final LegalDocumentModel policy;
  final String? acceptedVersion;
  final FutureOr<void> Function(String version)? onAccept;

  const _PolicyContent({
    required this.policy,
    required this.acceptedVersion,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    final accepted = acceptedVersion == policy.version;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(policy.title, style: AppTextStyles.headlineLarge),
        const SizedBox(height: 8),
        Text(
          'Cập nhật lần cuối: ${policy.updatedLabel}',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        if (policy.summary.trim().isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            policy.summary,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
        const SizedBox(height: 32),
        GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Text(
            policy.body,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 24),
        if (!accepted)
          PrimaryButton(
            label: 'Tôi đã đọc và đồng ý',
            onPressed: onAccept == null
                ? null
                : () {
                    unawaited(Future.sync(() => onAccept!(policy.version)));
                  },
          ),
        const SizedBox(height: 48),
      ],
    );
  }
}

class _PolicyError extends StatelessWidget {
  final VoidCallback onRetry;

  const _PolicyError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 120),
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(
              Icons.privacy_tip_outlined,
              color: AppColors.onSurfaceVariant,
              size: 40,
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa thể tải chính sách quyền riêng tư.',
              style: AppTextStyles.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Vui lòng kiểm tra kết nối hoặc thử lại sau.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            PrimaryButton(label: 'Thử lại', onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}
