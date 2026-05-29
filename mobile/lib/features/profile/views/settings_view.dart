import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/models/nav_item_model.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/app_snack_bar.dart';
import 'package:frontend/core/widgets/glass_bottom_nav_bar.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/core/widgets/primary_button.dart';
import 'package:frontend/features/app_setting/models/app_permission.dart';
import 'package:frontend/features/app_setting/models/app_setting_key.dart';
import 'package:frontend/features/app_setting/models/app_setting_state.dart';
import 'package:frontend/features/app_setting/providers/app_setting_providers.dart';
import 'package:frontend/features/notifications/providers/notification_providers.dart';
import 'package:frontend/features/profile/providers/profile_providers.dart';
import 'package:frontend/features/profile/widgets/settings_sections.dart';

class SettingsView extends ConsumerStatefulWidget {
  final int currentNavIndex;
  final ValueChanged<int>? onNavTap;
  final VoidCallback? onBack;
  final VoidCallback? onEditProfile;
  final VoidCallback? onPasskeyLogin;
  final VoidCallback? onHelpCenter;
  final VoidCallback? onSendFeedback;
  final VoidCallback? onPrivacyPolicy;
  final VoidCallback? onSignOut;
  final List<NavItemModel> navItems;

  const SettingsView({
    super.key,
    this.currentNavIndex = 2,
    this.onNavTap,
    this.onBack,
    this.onEditProfile,
    this.onPasskeyLogin,
    this.onHelpCenter,
    this.onSendFeedback,
    this.onPrivacyPolicy,
    this.onSignOut,
    this.navItems = GlassBottomNavBar.defaultItems,
  });

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<AppSettingState>>(appSettingControllerProvider, (
      previous,
      next,
    ) {
      final error = next.value?.error;
      if (error == null || previous?.value?.error == error || !mounted) {
        return;
      }

      showAppSnackBar(context, _settingErrorMessage(error));
    });

    final settingsAsync = ref.watch(appSettingControllerProvider);
    final settings = settingsAsync.value;
    final cacheSize = ref.watch(cacheSizeProvider);
    final passkeyAvailable = ref.watch(passkeyCapabilityProvider).value ?? true;
    final privacyPolicyVersion = ref
        .watch(privacyPolicyProvider('vi'))
        .value
        ?.version;
    final settingsReady = settings != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
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
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 120,
                  ),
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
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    blurRadius: 100,
                  ),
                ],
              ),
            ),
          ),
          CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _ProfileHeader(onEditProfile: widget.onEditProfile),
                      SecuritySettingsSection(
                        settings: settings,
                        settingsReady: settingsReady,
                        passkeyAvailable: passkeyAvailable,
                        lockTimeoutLabel: _lockTimeoutLabel(settings),
                        onPasskeyTap: widget.onPasskeyLogin,
                        onAppLockChanged: _setAppLockEnabled,
                        onLockTimeoutTap: () => _selectLockTimeout(settings),
                        onBiometricChanged: (value) => ref
                            .read(appSettingControllerProvider.notifier)
                            .setBiometricUnlock(value),
                      ),
                      NotificationSettingsSection(
                        settings: settings,
                        settingsReady: settingsReady,
                        onPushNotificationsChanged: _setPushNotifications,
                      ),
                      AppearanceSettingsSection(
                        settings: settings,
                        settingsReady: settingsReady,
                        localeLabel: _localeLabel(settings),
                        onLocaleTap: () => _selectLocale(settings),
                      ),
                      DataSettingsSection(
                        settings: settings,
                        settingsReady: settingsReady,
                        cacheSizeLabel: _cacheSizeLabel(cacheSize),
                        onClearCacheTap: _clearTemporaryCache,
                        onAutoClearCacheChanged: (value) => ref
                            .read(appSettingControllerProvider.notifier)
                            .setBool(
                              AppSettingKey.dataAutoClearCacheEnabled,
                              value,
                            ),
                        onResetSettingsTap: _confirmResetSettings,
                      ),
                      SupportSettingsSection(
                        settings: settings,
                        privacyPolicyVersion: privacyPolicyVersion,
                        onHelpCenter: widget.onHelpCenter,
                        onRateOnPlayStore: widget.onSendFeedback,
                        onPrivacyPolicy: widget.onPrivacyPolicy,
                      ),
                      SignOutSettingsButton(onSignOut: widget.onSignOut),
                      const SizedBox(height: 24),
                      Center(
                        child: Text(
                          settings?.versionInfo?.displayLabel ??
                              'Đang đọc phiên bản...',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.onSurfaceVariant.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GlassTopBar(title: 'Cài đặt'),
          ),
          GlassBottomNavBar(
            currentIndex: widget.currentNavIndex,
            items: widget.navItems,
            onTap: widget.onNavTap ?? (_) {},
          ),
        ],
      ),
    );
  }

  Future<void> _setPushNotifications(bool enabled) async {
    final settingsController = ref.read(appSettingControllerProvider.notifier);

    if (!enabled) {
      await settingsController.setBool(
        AppSettingKey.notificationPushEnabled,
        false,
      );
      await ref
          .read(pushNotificationControllerProvider.notifier)
          .unregisterCurrentDevice();
      if (mounted) showAppSnackBar(context, 'Đã tắt thông báo đẩy.');
      return;
    }

    final permission = await settingsController.requestPermission(
      AppPermissionKey.notification,
    );
    final allowed =
        permission?.status == AppPermissionStatus.granted ||
        permission?.status == AppPermissionStatus.provisional;

    if (!allowed) {
      await settingsController.setBool(
        AppSettingKey.notificationPushEnabled,
        false,
      );
      if (mounted) {
        showAppSnackBar(
          context,
          'Chưa thể bật thông báo. Vui lòng cấp quyền trong cài đặt hệ thống.',
        );
      }
      return;
    }

    await settingsController.setBool(
      AppSettingKey.notificationPushEnabled,
      true,
    );
    await ref
        .read(pushNotificationControllerProvider.notifier)
        .registerCurrentDevice();
    if (mounted) showAppSnackBar(context, 'Đã bật thông báo đẩy.');
  }

  Future<void> _clearTemporaryCache() async {
    final result = await ref.read(cacheServiceProvider).clearTemporaryCache();
    ref.invalidate(cacheSizeProvider);
    if (!mounted) return;

    final message = result.hasFailures
        ? 'Đã xóa một phần cache tạm, ${result.failedEntries} mục chưa xóa được.'
        : 'Đã xóa cache tạm, giải phóng ${_bytesLabel(result.freedBytes)}.';
    showAppSnackBar(context, message);
  }

  Future<void> _confirmResetSettings() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đặt lại cài đặt?'),
        content: const Text(
          'Toàn bộ cài đặt app_setting sẽ quay về mặc định. Phiên đăng nhập vẫn được giữ nguyên.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Đặt lại'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await ref.read(appSettingControllerProvider.notifier).resetToDefaults();
    if (mounted) showAppSnackBar(context, 'Đã đặt lại cài đặt.');
  }

  Future<void> _setAppLockEnabled(bool enabled) async {
    final controller = ref.read(appSettingControllerProvider.notifier);

    if (enabled) {
      final available = await controller.canUseLocalAuthentication();
      if (!available) {
        if (mounted) {
          showAppSnackBar(
            context,
            'Thiết bị chưa hỗ trợ khóa bảo mật hoặc chưa thiết lập khóa màn hình.',
          );
        }
        return;
      }
    }

    await controller.setBool(AppSettingKey.securityAppLockEnabled, enabled);
  }

  Future<void> _selectLocale(AppSettingState? settings) async {
    if (settings == null) return;

    final current = settings.stringValue(AppSettingKey.appearanceLocale);
    final next = await _showOptionSheet<String>(
      title: 'Chọn ngôn ngữ',
      currentValue: current,
      options: const [
        _SettingOption(value: 'system', label: 'Theo hệ thống'),
        _SettingOption(value: 'vi', label: 'Tiếng Việt'),
        _SettingOption(value: 'en', label: 'English'),
      ],
    );
    if (next == null) return;

    await ref
        .read(appSettingControllerProvider.notifier)
        .setString(AppSettingKey.appearanceLocale, next);
  }

  Future<void> _selectLockTimeout(AppSettingState? settings) async {
    if (settings == null) return;

    final current = settings.intValue(
      AppSettingKey.securityLockAfterSeconds,
      fallback: 60,
    );
    final next = await _showOptionSheet<int>(
      title: 'Tự khóa sau',
      currentValue: current,
      options: const [
        _SettingOption(value: 0, label: 'Ngay lập tức'),
        _SettingOption(value: 30, label: '30 giây'),
        _SettingOption(value: 60, label: '1 phút'),
        _SettingOption(value: 300, label: '5 phút'),
      ],
    );
    if (next == null) return;

    await ref
        .read(appSettingControllerProvider.notifier)
        .setInt(AppSettingKey.securityLockAfterSeconds, next);
  }

  Future<T?> _showOptionSheet<T>({
    required String title,
    required T currentValue,
    required List<_SettingOption<T>> options,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
              child: Text(title, style: AppTextStyles.titleMedium),
            ),
            for (final option in options)
              ListTile(
                onTap: () => Navigator.of(context).pop(option.value),
                title: Text(option.label),
                subtitle: option.description == null
                    ? null
                    : Text(option.description!),
                trailing: option.value == currentValue
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  String _lockTimeoutLabel(AppSettingState? settings) {
    final seconds =
        settings?.intValue(
          AppSettingKey.securityLockAfterSeconds,
          fallback: 60,
        ) ??
        60;

    return switch (seconds) {
      0 => 'Ngay lập tức',
      30 => '30 giây',
      60 => '1 phút',
      300 => '5 phút',
      _ => '$seconds giây',
    };
  }

  String _localeLabel(AppSettingState? settings) {
    return switch (settings?.stringValue(AppSettingKey.appearanceLocale)) {
      'vi' => 'Tiếng Việt',
      'en' => 'English',
      _ => 'Theo hệ thống',
    };
  }

  String _cacheSizeLabel(AsyncValue<int> cacheSize) {
    final bytes = cacheSize.value;
    if (bytes == null) return 'Đang tính';
    return _bytesLabel(bytes);
  }

  String _bytesLabel(int bytes) {
    if (bytes < 1024) return '$bytes B';
    final kb = bytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
    final mb = kb / 1024;
    return '${mb.toStringAsFixed(1)} MB';
  }

  String _settingErrorMessage(Object error) {
    if (error is ArgumentError) {
      return error.message?.toString() ?? error.toString();
    }
    if (error is StateError) {
      return error.message;
    }
    return 'Không thể cập nhật cài đặt. Vui lòng thử lại.';
  }
}

class _SettingOption<T> {
  final T value;
  final String label;
  final String? description;

  const _SettingOption({
    required this.value,
    required this.label,
    this.description,
  });
}

class _ProfileHeader extends ConsumerWidget {
  final VoidCallback? onEditProfile;

  const _ProfileHeader({this.onEditProfile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(userProfileProvider)
        .when(
          data: (user) => Column(
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
                      child: user.avatarUrl != null
                          ? ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: user.avatarUrl!,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) =>
                                    const Icon(
                                      Icons.person,
                                      size: 48,
                                      color: AppColors.outline,
                                    ),
                              ),
                            )
                          : const Icon(
                              Icons.person,
                              size: 48,
                              color: AppColors.outline,
                            ),
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
                        border: Border.all(
                          color: AppColors.background,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.photo_camera,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(user.fullName, style: AppTextStyles.titleLarge),
              const SizedBox(height: 4),
              Text(user.email, style: AppTextStyles.bodyMedium),
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'Chỉnh sửa hồ sơ',
                isFullWidth: false,
                onPressed: onEditProfile,
              ),
              const SizedBox(height: 32),
            ],
          ),
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 40.0),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (err, stack) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 40.0),
            child: Center(child: Text('Lỗi tải hồ sơ: $err')),
          ),
        );
  }
}
