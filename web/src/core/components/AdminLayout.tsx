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
      <main className={cn('ml-64 pt-24 px-8 pb-12 min-h-screen', className)}>
        {children}
      </main>
    </div>
  );
}
