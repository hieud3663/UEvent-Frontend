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
    <div className="min-h-screen overflow-x-hidden bg-surface">
      <Sidebar />
      <Header />
      <main
        className={cn(
          'min-h-screen max-w-full overflow-x-hidden px-4 pb-[calc(6rem+env(safe-area-inset-bottom))] pt-20 sm:px-6 lg:ml-64 lg:px-8 lg:pb-12 lg:pt-24',
          className
        )}
      >
        {children}
      </main>
    </div>
  );
}
