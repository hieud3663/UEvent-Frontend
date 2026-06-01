// File: src/core/components/Sidebar.tsx
'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import {
  Bell,
  Calendar,
  FolderOpen,
  HeadphonesIcon,
  LayoutDashboard,
  MapPinned,
  Settings,
  Ticket,
  Users,
} from 'lucide-react';
import { cn } from '@/core/lib/utils';
import type { NavItem } from '@/core/types/navigation';

const navItems: NavItem[] = [
  { label: 'Tổng quan', href: '/dashboard', icon: LayoutDashboard },
  { label: 'Người dùng', href: '/users', icon: Users },
  { label: 'Sự kiện', href: '/events', icon: Calendar },
  { label: 'Địa điểm', href: '/locations', icon: MapPinned },
  { label: 'Vé', href: '/tickets', icon: Ticket },
  { label: 'Danh mục', href: '/categories', icon: FolderOpen },
  { label: 'Thông báo', href: '/notifications', icon: Bell },
  { label: 'Hỗ trợ', href: '/support', icon: HeadphonesIcon },
  { label: 'Cài đặt', href: '/settings', icon: Settings },
];

interface SidebarProps {
  className?: string;
}

export function Sidebar({ className }: SidebarProps) {
  const pathname = usePathname();

  return (
    <aside
      className={cn(
        'fixed bottom-0 left-0 top-auto z-40 h-[calc(5rem+env(safe-area-inset-bottom))] w-full lg:top-0 lg:bottom-auto lg:h-screen lg:w-64',
        'bg-white/70 backdrop-blur-3xl',
        'border-t border-white/40 lg:border-r lg:border-t-0',
        'flex flex-row p-2 pb-[calc(0.5rem+env(safe-area-inset-bottom))] lg:flex-col lg:p-4',
        'shadow-2xl shadow-black/5',
        className
      )}
    >
      <div className="mb-10 hidden px-4 lg:block">
        <span className="text-xl font-black text-slate-800 tracking-tight">UEvents Admin</span>
        <p className="mt-1 text-[10px] font-bold uppercase tracking-wider text-slate-400">Cổng quản trị</p>
      </div>

      <nav className="flex flex-1 flex-row gap-2 overflow-x-auto [scrollbar-width:none] lg:flex-col lg:gap-1 lg:overflow-visible [&::-webkit-scrollbar]:hidden">
        {navItems.map((item) => {
          const isActive = pathname === item.href || pathname?.startsWith(`${item.href}/`);
          const Icon = item.icon;

          return (
            <Link
              key={item.href}
              href={item.href}
              className={cn(
                'flex min-w-[74px] flex-col items-center justify-center gap-1 rounded-xl px-2 py-2 transition-all duration-200 lg:min-w-0 lg:flex-row lg:justify-start lg:gap-4 lg:px-4 lg:py-3',
                isActive
                  ? 'bg-amber-500 text-white font-bold shadow-lg shadow-amber-500/20'
                  : 'text-slate-500 hover:text-slate-800 hover:bg-white/50'
              )}
            >
              <Icon className="h-5 w-5" />
              <span className={cn('text-[11px] leading-tight lg:text-sm', isActive ? 'font-bold' : 'font-medium')}>
                {item.label}
              </span>
              {item.badge ? (
                <span className="ml-auto rounded-full bg-red-500 px-2 py-0.5 text-xs font-bold text-white">
                  {item.badge}
                </span>
              ) : null}
            </Link>
          );
        })}
      </nav>
    </aside>
  );
}
