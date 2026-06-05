// File: src/app/(public)/download/page.tsx
import type { Metadata } from 'next';
import Link from 'next/link';
import { Apple, Download, ShieldCheck, Smartphone } from 'lucide-react';
import { PublicShell } from '../PublicShell';
import { appDownloadLinks } from '../public-data';

export const metadata: Metadata = {
  title: 'Tải ứng dụng | UEvent',
  description: 'Tải UEvent cho Android APK và iOS.',
};

const releaseNotes = [
  'Đăng nhập và đồng bộ hồ sơ người dùng.',
  'Theo dõi sự kiện, vé, thông báo và lịch tham dự.',
  'Đọc chính sách quyền riêng tư và gửi yêu cầu hỗ trợ trong ứng dụng.',
];

export default function DownloadPage() {
  return (
    <PublicShell>
      <section>
        <div className="mx-auto max-w-7xl px-5 py-14 sm:px-8 sm:py-18">
          <div className="max-w-3xl">
            <p className="text-xs font-black uppercase tracking-widest text-primary-700">Tải ứng dụng</p>
            <h1 className="mt-3 text-4xl font-black tracking-tight text-on-surface sm:text-5xl">Cài UEvent trên thiết bị di động</h1>
            <p className="mt-5 text-lg leading-8 text-on-surface-variant">
              Tải bản Android APK hoặc mở trang iOS để sử dụng UEvent cho lịch sự kiện, vé và thông báo cá nhân.
            </p>
          </div>
        </div>
      </section>

      <section className="py-6 sm:py-10">
        <div className="mx-auto grid max-w-7xl gap-5 px-5 sm:px-8 lg:grid-cols-2">
          <article id="android-release" className="glass-card rounded-[32px] p-6 shadow-2xl shadow-black/5 sm:p-8">
            <div className="flex h-12 w-12 items-center justify-center rounded-2xl bg-primary-container text-on-primary-container shadow-lg shadow-primary-container/20">
              <Smartphone className="h-6 w-6" />
            </div>
            <h2 className="mt-6 text-2xl font-black text-on-surface">Android APK</h2>
            <p className="mt-3 text-sm leading-6 text-on-surface-variant">
              Dành cho thiết bị Android cần cài trực tiếp từ file phát hành chính thức của UEvent.
            </p>
            {appDownloadLinks.android.href ? (
              <Link
                href={appDownloadLinks.android.href}
                className="mt-6 inline-flex h-12 items-center justify-center gap-2 rounded-xl bg-primary-container px-5 text-sm font-bold text-on-primary-container shadow-lg shadow-primary-container/30 transition hover:scale-[1.02]"
              >
                <Download className="h-4 w-4" />
                {appDownloadLinks.android.label}
              </Link>
            ) : (
              <button
                type="button"
                disabled
                className="mt-6 inline-flex h-12 items-center justify-center gap-2 rounded-xl bg-slate-100 px-5 text-sm font-bold text-slate-500"
              >
                <Download className="h-4 w-4" />
                {appDownloadLinks.android.unavailableLabel}
              </button>
            )}
            <p className="mt-3 text-xs font-medium leading-5 text-on-surface-variant">
              File APK phát hành chính thức đã sẵn sàng để tải trực tiếp.
            </p>
          </article>

          <article id="ios-release" className="glass-card rounded-[32px] p-6 shadow-2xl shadow-black/5 sm:p-8">
            <div className="flex h-12 w-12 items-center justify-center rounded-2xl bg-slate-900 text-white shadow-lg shadow-black/10">
              <Apple className="h-6 w-6" />
            </div>
            <h2 className="mt-6 text-2xl font-black text-on-surface">iOS</h2>
            <p className="mt-3 text-sm leading-6 text-on-surface-variant">
              Dành cho iPhone và iPad thông qua trang phân phối iOS của UEvent.
            </p>
            {appDownloadLinks.ios.href ? (
              <Link
                href={appDownloadLinks.ios.href}
                className="mt-6 inline-flex h-12 items-center justify-center gap-2 rounded-xl bg-slate-900 px-5 text-sm font-bold text-white shadow-lg shadow-black/10 transition hover:scale-[1.02]"
              >
                <Apple className="h-4 w-4" />
                {appDownloadLinks.ios.label}
              </Link>
            ) : (
              <button
                type="button"
                disabled
                className="mt-6 inline-flex h-12 items-center justify-center gap-2 rounded-xl bg-slate-100 px-5 text-sm font-bold text-slate-500"
              >
                <Apple className="h-4 w-4" />
                {appDownloadLinks.ios.unavailableLabel}
              </button>
            )}
            <p className="mt-3 text-xs font-medium leading-5 text-on-surface-variant">
              Đường dẫn iOS sẽ được cập nhật khi bản phát hành chính thức sẵn sàng.
            </p>
          </article>
        </div>
      </section>

      <section className="py-12">
        <div className="mx-auto max-w-7xl px-5 sm:px-8">
          <div className="glass-card rounded-[28px] p-6 sm:p-8">
            <div className="flex items-start gap-4">
              <ShieldCheck className="mt-1 h-5 w-5 text-primary-700" />
              <div>
                <h2 className="text-xl font-black text-on-surface">Ghi chú bản phát hành</h2>
                <ul className="mt-4 grid gap-3 text-sm leading-6 text-on-surface-variant md:grid-cols-3">
                  {releaseNotes.map((note) => (
                    <li key={note}>{note}</li>
                  ))}
                </ul>
              </div>
            </div>
          </div>
        </div>
      </section>
    </PublicShell>
  );
}
