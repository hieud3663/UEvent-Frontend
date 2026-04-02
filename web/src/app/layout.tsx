// File: src/app/layout.tsx
import type { Metadata } from 'next';
import { Geist, Geist_Mono } from 'next/font/google';
import { ToastProvider } from '@/core/components/ToastProvider';
import { getThemeStyleVariables } from '@/core/theme';
import './globals.css';

const geistSans = Geist({
  variable: '--font-geist-sans',
  subsets: ['latin'],
});

const geistMono = Geist_Mono({
  variable: '--font-geist-mono',
  subsets: ['latin'],
});

export const metadata: Metadata = {
  title: 'UEvent Admin',
  description: 'UEvent Admin Dashboard - Manage events, users, and tickets',
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  const themeVariables = getThemeStyleVariables();

  return (
    <html
      lang="vi"
      className={`${geistSans.variable} ${geistMono.variable} h-full`}
      style={themeVariables}
    >
      <body className="h-full antialiased">
        {children}
        <ToastProvider />
      </body>
    </html>
  );
}
