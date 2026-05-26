import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/glass_container.dart';
import 'package:frontend/features/app_setting/data/app_setting_legal.dart';
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
    required this.onPreferPasskeyChanged,
    required this.onAppLockChanged,
    required this.onLockTimeoutTap,
    required this.onBiometricChanged,
  });

  final AppSettingState? settings;
  final bool settingsReady;
  final bool passkeyAvailable;
  final String lockTimeoutLabel;
  final ValueChanged<bool> onPreferPasskeyChanged;
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
        SettingsToggleTile(
          icon: Icons.vpn_key,
          title: 'Ưu tiên đăng nhập bằng passkey',
          subtitle: passkeyAvailable
              ? 'Chỉ lưu lựa chọn trên thiết bị này'
              : 'Passkey chưa khả dụng trên thiết bị này',
          value:
              settings?.boolValue(AppSettingKey.securityPreferPasskeyLogin) ??
              false,
          enabled: settingsReady && passkeyAvailable,
          onChanged: onPreferPasskeyChanged,
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
    required this.notificationPermissionLabel,
    required this.onPushNotificationsChanged,
  });

  final AppSettingState? settings;
  final bool settingsReady;
  final String notificationPermissionLabel;
  final ValueChanged<bool> onPushNotificationsChanged;

  @override
  Widget build(BuildContext context) {
    return SettingsGroup(
      title: 'Thông báo',
      children: [
        SettingsToggleTile(
          icon: Icons.notifications,
          title: 'Thông báo',
          subtitle: notificationPermissionLabel,
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

class PermissionSettingsSection extends StatelessWidget {
  const PermissionSettingsSection({
    super.key,
    required this.settings,
    required this.settingsReady,
    required this.locationPermissionLabel,
    required this.contactsPermissionLabel,
    required this.cameraPermissionLabel,
    required this.photosPermissionLabel,
    required this.onLocationChanged,
    required this.onContactsChanged,
    required this.onCameraTap,
    required this.onPhotosTap,
    this.showContactsSync = true,
  });

  final AppSettingState? settings;
  final bool settingsReady;
  final bool showContactsSync;
  final String locationPermissionLabel;
  final String contactsPermissionLabel;
  final String cameraPermissionLabel;
  final String photosPermissionLabel;
  final ValueChanged<bool> onLocationChanged;
  final ValueChanged<bool> onContactsChanged;
  final VoidCallback onCameraTap;
  final VoidCallback onPhotosTap;

  @override
  Widget build(BuildContext context) {
    return SettingsGroup(
      title: 'Quyền truy cập',
      children: [
        SettingsToggleTile(
          icon: Icons.location_on,
          title: 'Dịch vụ vị trí',
          subtitle: locationPermissionLabel,
          value:
              settings?.boolValue(
                AppSettingKey.permissionLocationFeatureEnabled,
              ) ??
              false,
          enabled: settingsReady,
          onChanged: onLocationChanged,
        ),
        if (showContactsSync)
          SettingsToggleTile(
            icon: Icons.contacts,
            title: 'Đọc danh bạ',
            subtitle: contactsPermissionLabel,
            value:
                settings?.boolValue(
                  AppSettingKey.permissionContactsSyncEnabled,
                ) ??
                false,
            enabled: settingsReady,
            onChanged: onContactsChanged,
          ),
        SettingsActionTile(
          icon: Icons.qr_code_scanner,
          title: 'Camera',
          subtitle: 'Dùng khi quét mã QR',
          valueText: cameraPermissionLabel,
          onTap: onCameraTap,
        ),
        SettingsActionTile(
          icon: Icons.photo_library,
          title: 'Ảnh và thư viện',
          subtitle: 'Dùng khi chọn ảnh hồ sơ hoặc ảnh sự kiện',
          valueText: photosPermissionLabel,
          onTap: onPhotosTap,
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
    required this.onHelpCenter,
    required this.onRateOnPlayStore,
    required this.onPrivacyPolicy,
  });

  final AppSettingState? settings;
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
              acceptedVersion?.contains(AppSettingLegal.privacyPolicyVersion) ==
                  true
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
    return GestureDetector(
      onTap: onSignOut,
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(vertical: 16),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout, color: Colors.red),
            const SizedBox(width: 8),
            Text(
              'Đăng xuất',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
