import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/primary_button.dart';
import 'package:frontend/features/app_setting/models/app_setting_key.dart';
import 'package:frontend/features/app_setting/models/app_setting_state.dart';
import 'package:frontend/features/profile/widgets/settings_group.dart';
import 'package:frontend/features/profile/widgets/settings_tiles.dart';

class SecuritySettingsSection extends StatelessWidget {
  const SecuritySettingsSection({
    super.key,
    required this.settings,
    required this.settingsReady,
    required this.passkeyAvailable,
    required this.lockTimeoutLabel,
    required this.onPasskeyTap,
    required this.onAppLockChanged,
    required this.onLockTimeoutTap,
    required this.onBiometricChanged,
  });

  final AppSettingState? settings;
  final bool settingsReady;
  final bool passkeyAvailable;
  final String lockTimeoutLabel;
  final VoidCallback? onPasskeyTap;
  final ValueChanged<bool> onAppLockChanged;
  final VoidCallback onLockTimeoutTap;
  final ValueChanged<bool> onBiometricChanged;

  @override
  Widget build(BuildContext context) {
    final appLockEnabled =
        settings?.boolValue(AppSettingKey.securityAppLockEnabled) ?? false;

    return SettingsGroup(
      title: 'Bảo mật',
      children: [
        SettingsActionTile(
          icon: Icons.vpn_key,
          title: 'Đăng nhập bằng passkey',
          subtitle: passkeyAvailable
              ? 'Tạo hoặc quản lý passkey của tài khoản'
              : 'Passkey chưa khả dụng trên thiết bị này',
          enabled: settingsReady && passkeyAvailable,
          onTap: onPasskeyTap ?? () {},
        ),
        SettingsToggleTile(
          icon: Icons.lock,
          title: 'Khóa ứng dụng',
          subtitle: 'Yêu cầu mở khóa lại khi quay về app',
          value:
              settings?.boolValue(AppSettingKey.securityAppLockEnabled) ??
              false,
          enabled: settingsReady,
          onChanged: onAppLockChanged,
        ),
        SettingsActionTile(
          icon: Icons.timer,
          title: 'Tự khóa sau',
          subtitle: 'Áp dụng khi app quay lại từ nền',
          valueText: lockTimeoutLabel,
          enabled: settingsReady,
          onTap: onLockTimeoutTap,
        ),
        if (appLockEnabled)
          SettingsToggleTile(
            icon: Icons.fingerprint,
            title: 'Mở khóa sinh trắc học',
            subtitle: 'Xác thực trước khi bật tùy chọn này',
            value:
                settings?.boolValue(
                  AppSettingKey.securityBiometricUnlockEnabled,
                ) ??
                false,
            enabled: settingsReady,
            onChanged: onBiometricChanged,
          ),
      ],
    );
  }
}

class NotificationSettingsSection extends StatelessWidget {
  const NotificationSettingsSection({
    super.key,
    required this.settings,
    required this.settingsReady,
    required this.onPushNotificationsChanged,
  });

  final AppSettingState? settings;
  final bool settingsReady;
  final ValueChanged<bool> onPushNotificationsChanged;

  @override
  Widget build(BuildContext context) {
    return SettingsGroup(
      title: 'Thông báo',
      children: [
        SettingsToggleTile(
          icon: Icons.notifications,
          title: 'Thông báo',
          subtitle: 'Nhận thông báo từ ứng dụng',
          value:
              settings?.boolValue(
                AppSettingKey.notificationPushEnabled,
                fallback: true,
              ) ??
              true,
          enabled: settingsReady,
          onChanged: onPushNotificationsChanged,
        ),
      ],
    );
  }
}

class AppearanceSettingsSection extends StatelessWidget {
  const AppearanceSettingsSection({
    super.key,
    required this.settings,
    required this.settingsReady,
    required this.localeLabel,
    required this.onLocaleTap,
  });

  final AppSettingState? settings;
  final bool settingsReady;
  final String localeLabel;
  final VoidCallback onLocaleTap;

  @override
  Widget build(BuildContext context) {
    return SettingsGroup(
      title: 'Giao diện',
      children: [
        SettingsActionTile(
          icon: Icons.language,
          title: 'Ngôn ngữ',
          subtitle: 'Tùy chọn hiển thị trong app',
          valueText: localeLabel,
          enabled: settingsReady,
          onTap: onLocaleTap,
        ),
      ],
    );
  }
}

class DataSettingsSection extends StatelessWidget {
  const DataSettingsSection({
    super.key,
    required this.settings,
    required this.settingsReady,
    required this.cacheSizeLabel,
    required this.onClearCacheTap,
    required this.onAutoClearCacheChanged,
    required this.onResetSettingsTap,
  });

  final AppSettingState? settings;
  final bool settingsReady;
  final String cacheSizeLabel;
  final VoidCallback onClearCacheTap;
  final ValueChanged<bool> onAutoClearCacheChanged;
  final VoidCallback onResetSettingsTap;

  @override
  Widget build(BuildContext context) {
    return SettingsGroup(
      title: 'Dữ liệu',
      children: [
        SettingsActionTile(
          icon: Icons.cleaning_services,
          title: 'Xóa cache tạm',
          subtitle: 'Không xóa phiên đăng nhập hoặc cài đặt',
          valueText: cacheSizeLabel,
          onTap: onClearCacheTap,
        ),
        SettingsToggleTile(
          icon: Icons.auto_delete,
          title: 'Tự xóa cache khi mở app',
          value:
              settings?.boolValue(AppSettingKey.dataAutoClearCacheEnabled) ??
              false,
          enabled: settingsReady,
          onChanged: onAutoClearCacheChanged,
        ),
        SettingsActionTile(
          icon: Icons.restore,
          title: 'Đặt lại cài đặt',
          subtitle: 'Đưa toàn bộ app_setting về mặc định',
          onTap: onResetSettingsTap,
        ),
      ],
    );
  }
}

class SupportSettingsSection extends StatelessWidget {
  const SupportSettingsSection({
    super.key,
    required this.settings,
    required this.privacyPolicyVersion,
    required this.onHelpCenter,
    required this.onRateOnPlayStore,
    required this.onPrivacyPolicy,
  });

  final AppSettingState? settings;
  final String? privacyPolicyVersion;
  final VoidCallback? onHelpCenter;
  final VoidCallback? onRateOnPlayStore;
  final VoidCallback? onPrivacyPolicy;

  @override
  Widget build(BuildContext context) {
    final acceptedVersion = settings?.stringValue(
      AppSettingKey.legalPrivacyPolicyAcceptedVersion,
    );

    return SettingsGroup(
      title: 'Hỗ trợ',
      children: [
        SettingsActionTile(
          icon: Icons.help_center,
          title: 'Trung tâm hỗ trợ',
          onTap: onHelpCenter ?? () {},
        ),
        SettingsActionTile(
          icon: Icons.star_rate,
          title: 'Đánh giá trên Play Store',
          subtitle: 'Mở trang ứng dụng để gửi đánh giá công khai',
          onTap: onRateOnPlayStore ?? () {},
        ),
        SettingsActionTile(
          icon: Icons.privacy_tip,
          title: 'Chính sách quyền riêng tư',
          valueText:
              privacyPolicyVersion != null &&
                  acceptedVersion == privacyPolicyVersion
              ? 'Đã chấp nhận'
              : null,
          onTap: onPrivacyPolicy ?? () {},
        ),
      ],
    );
  }
}

class SignOutSettingsButton extends StatelessWidget {
  const SignOutSettingsButton({super.key, required this.onSignOut});

  final VoidCallback? onSignOut;

  @override
  Widget build(BuildContext context) {
    return SecondaryButton(
      label: 'Đăng xuất',
      icon: Icons.logout,
      onPressed: onSignOut,
      foregroundColor: AppColors.error,
      borderColor: AppColors.error.withValues(alpha: 0.3),
    );
  }
}
