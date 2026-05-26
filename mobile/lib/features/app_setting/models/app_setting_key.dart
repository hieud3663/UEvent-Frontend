class AppSettingKey {
  AppSettingKey._();

  static const notificationPushEnabled = 'notification.push_enabled';
  static const notificationEventRemindersEnabled =
      'notification.event_reminders_enabled';
  static const notificationTicketUpdatesEnabled =
      'notification.ticket_updates_enabled';
  static const notificationOrganizerUpdatesEnabled =
      'notification.organizer_updates_enabled';
  static const notificationMarketingEnabled = 'notification.marketing_enabled';
  static const notificationQuietHoursEnabled =
      'notification.quiet_hours_enabled';
  static const notificationQuietHoursStart = 'notification.quiet_hours_start';
  static const notificationQuietHoursEnd = 'notification.quiet_hours_end';

  static const securityPreferPasskeyLogin = 'security.prefer_passkey_login';
  static const securityAppLockEnabled = 'security.app_lock_enabled';
  static const securityBiometricUnlockEnabled =
      'security.biometric_unlock_enabled';
  static const securityLockAfterSeconds = 'security.lock_after_seconds';

  static const permissionLocationFeatureEnabled =
      'permission.location_feature_enabled';
  static const permissionContactsSyncEnabled =
      'permission.contacts_sync_enabled';

  static const appearanceThemeMode = 'appearance.theme_mode';
  static const appearanceLocale = 'appearance.locale';
  static const appearanceReduceMotionEnabled =
      'appearance.reduce_motion_enabled';

  static const dataAutoClearCacheEnabled = 'data.auto_clear_cache_enabled';
  static const dataCacheLimitMb = 'data.cache_limit_mb';

  static const legalPrivacyPolicyAcceptedVersion =
      'legal.privacy_policy_accepted_version';
}
