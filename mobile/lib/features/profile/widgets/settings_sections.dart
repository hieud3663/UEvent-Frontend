import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/glass_container.dart';
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
    required this.onPasskeyTap,
    required this.onAppLockChanged,
    required this.onLockTimeoutTap,
    required this.onBiometricChanged,
  });

  final AppSettingState? settings;
  final bool settingsReady;
  final bool passkeyAvailable;
  final String lockTimeoutLabel;
  final ValueChanged<bool> onPreferPasskeyChanged;
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
        _PasskeyPreferenceTile(
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
          onTap: onPasskeyTap,
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

class _PasskeyPreferenceTile extends StatelessWidget {
  const _PasskeyPreferenceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.enabled,
    required this.onChanged,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final contentEnabled = enabled && onTap != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: contentEnabled ? onTap : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w500,
                              color: contentEnabled
                                  ? AppColors.onSurface
                                  : AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 1,
            height: 44,
            child: CustomPaint(
              painter: _DashedVerticalDividerPainter(
                color: AppColors.outline.withValues(alpha: 0.9),
              ),
            ),
          ),
          const SizedBox(width: 12),
          CupertinoSwitch(
            value: value,
            activeTrackColor: AppColors.primary,
            onChanged: enabled ? onChanged : null,
          ),
        ],
      ),
    );
  }
}

class _DashedVerticalDividerPainter extends CustomPainter {
  const _DashedVerticalDividerPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.width
      ..strokeCap = StrokeCap.round;
    const dashHeight = 4.0;
    const dashGap = 4.0;
    var y = 0.0;

    while (y < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, y),
        Offset(size.width / 2, (y + dashHeight).clamp(0.0, size.height)),
        paint,
      );
      y += dashHeight + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedVerticalDividerPainter oldDelegate) {
    return oldDelegate.color != color;
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
