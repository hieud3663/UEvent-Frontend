// File: src/app/(public)/PublicShell.tsx
import Link from 'next/link';
import type { ReactNode } from 'react';
import { publicNavItems } from './public-data';

interface PublicShellProps {
  children: ReactNode;
}

export function PublicShell({ children }: PublicShellProps) {
  return (
    <main className="relative min-h-screen overflow-hidden bg-ethereal text-on-surface">
      <div className="pointer-events-none absolute left-[-12%] top-[-18%] h-[40rem] w-[40rem] rounded-full bg-primary-container/20 blur-[120px]" />
      <div className="pointer-events-none absolute bottom-[-18%] right-[-12%] h-[34rem] w-[34rem] rounded-full bg-secondary-container/30 blur-[120px]" />

      <header className="ios-blur sticky top-0 z-50 border-b border-white/40">
        <div className="mx-auto flex max-w-7xl items-center justify-between px-5 py-4 sm:px-8">
          <Link href="/" className="text-xl font-black tracking-tight text-on-surface">
            UEvent
          </Link>
          <nav className="hidden items-center gap-6 text-sm font-bold text-on-surface-variant md:flex">
            {publicNavItems.map((item) => (
              <Link key={item.href} href={item.href} className="transition-colors hover:text-on-surface">
                {item.label}
              </Link>
            ))}
          </nav>
          <Link
            href="/admin"
            className="inline-flex h-10 items-center justify-center rounded-xl border border-black/5 bg-white/70 px-4 text-sm font-bold text-on-surface shadow-sm transition hover:bg-white"
          >
            Quản trị
          </Link>
        </div>
      </header>
      <div className="relative z-10">{children}</div>
      <footer className="relative z-10 border-t border-white/50 bg-white/60">
        <div className="mx-auto flex max-w-7xl flex-col gap-3 px-5 py-6 text-sm font-medium text-on-surface-variant sm:px-8 md:flex-row md:items-center md:justify-between">
          <span>© 2026 UEvent. Bảo lưu mọi quyền.</span>
          <div className="flex gap-4">
            <Link href="/terms" className="hover:text-on-surface">
              Điều khoản
            </Link>
            <Link href="/privacy" className="hover:text-on-surface">
              Chính sách
            </Link>
          </div>
        </div>
      </footer>
    </main>
  );
}
