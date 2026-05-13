'use client';

// File: src/core/components/AdminLayout.tsx
import { Sidebar } from './Sidebar';
import { Header } from './Header';
import { cn } from '@/core/lib/utils';

interface AdminLayoutProps {
  children: React.ReactNode;
  className?: string;
}

export function AdminLayout({ children, className }: AdminLayoutProps) {
  return (
    <div className="min-h-screen bg-surface">
      <Sidebar />
      <Header />
      <main className={cn('min-h-screen px-4 pb-24 pt-24 sm:px-6 lg:ml-64 lg:px-8 lg:pb-12', className)}>
        {children}
      </main>
    </div>
  );
}
