// File: src/app/(public)/public-data.ts
export const publicNavItems = [
  { href: '/', label: 'Trang chủ' },
  { href: '/download', label: 'Tải ứng dụng' },
  { href: '/terms', label: 'Điều khoản' },
  { href: '/privacy', label: 'Chính sách' },
] as const;

export const appDownloadLinks = {
  android: {
    href: process.env.NEXT_PUBLIC_ANDROID_APK_URL || '/downloads/uevent.apk',
    label: 'Tải APK',
    platform: 'Android',
    unavailableLabel: 'APK đang cập nhật',
  },
  ios: {
    href: process.env.NEXT_PUBLIC_IOS_APP_URL || null,
    label: 'Tải cho iOS',
    platform: 'App Store',
    unavailableLabel: 'iOS đang cập nhật',
  },
} as const;
