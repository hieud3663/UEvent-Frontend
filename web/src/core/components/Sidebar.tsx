// File: src/core/components/Sidebar.tsx
'use client';

import Image from 'next/image';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import {
  LayoutDashboard,
  Users,
  Calendar,
  FolderOpen,
  Bell,
  HeadphonesIcon,
  Settings,
} from 'lucide-react';
import { cn } from '@/core/lib/utils';
import type { NavItem } from '@/core/types/navigation';

const navItems: NavItem[] = [
  { label: 'Tổng quan', href: '/dashboard', icon: LayoutDashboard },
  { label: 'Người dùng', href: '/users', icon: Users },
  { label: 'Sự kiện', href: '/events', icon: Calendar },
  { label: 'Danh mục', href: '/categories', icon: FolderOpen },
  { label: 'Thông báo', href: '/notifications', icon: Bell },
  { label: 'Hỗ trợ', href: '/support', icon: HeadphonesIcon },
  { label: 'Cài đặt', href: '/settings', icon: Settings },
  // { label: 'Permissions', href: '/permissions', icon: Shield }, tạm cmt vì chưa đúng
];

interface SidebarProps {
  className?: string;
}

export function Sidebar({ className }: SidebarProps) {
  const pathname = usePathname();

  return (
    <aside
      className={cn(
        'fixed bottom-0 left-0 top-auto z-40 h-20 w-full lg:top-0 lg:bottom-auto lg:h-screen lg:w-64',
        'bg-white/70 backdrop-blur-3xl',
        'border-t border-white/40 lg:border-r lg:border-t-0',
        'flex flex-row p-2 lg:flex-col lg:p-4',
        'shadow-2xl shadow-black/5',
        className
      )}
    >
      {/* Logo */}
      <div className="mb-10 hidden px-4 lg:block">
        <span className="text-xl font-black text-slate-800 tracking-tight">
          UEvents Admin
        </span>
        <p className="text-[10px] font-bold uppercase tracking-wider text-slate-400 mt-1">
          Cổng quản trị
        </p>
      </div>

      {/* Navigation */}
      <nav className="flex flex-1 flex-row gap-2 overflow-x-auto lg:flex-col lg:gap-1 lg:overflow-visible">
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
              <Icon className="w-5 h-5" />
              <span className={cn('text-[11px] leading-tight lg:text-sm', isActive ? 'font-bold' : 'font-medium')}>{item.label}</span>
              {item.badge && (
                <span className="ml-auto bg-red-500 text-white text-xs font-bold px-2 py-0.5 rounded-full">
                  {item.badge}
                </span>
              )}
            </Link>
          );
        })}
      </nav>

      {/* User Profile */}
      <div className="mt-auto hidden p-4 items-center gap-3 glass-card rounded-2xl border border-white/60 lg:flex">
        <div className="relative w-10 h-10 rounded-full overflow-hidden bg-slate-200">
          <Image
            src="https://lh3.googleusercontent.com/aida-public/AB6AXuDV320YMqiYUJZn9nyC85F61ox_xlvreWDOTEqyzT_FR47l5PqjYlues7JX8exjtAHIJ2yVVUK5RnOQaAiFTyNWIInCwT-JZ7Qn91g-1ro-CrcgU7pGPZXkv7VNwfayOdKYwlJmxdiaBcSuAAJm9cZZiIVPAq3hupYI4jedmyGX2BCGzXOPfoJCky_ieXThT4FnivS5VNjQrzSBkpJ6UuDcFO38zPXjCLXogfbaN486bpvnr_LoT516mwma65yIzZpXSnv1D6bD8jk"
            alt="Quản trị viên"
            fill
            sizes="40px"
            className="w-full h-full object-cover"
          />
        </div>
        <div className="overflow-hidden">
          <p className="text-xs font-bold text-slate-900 truncate">Quản trị viên</p>
          <p className="text-[10px] text-slate-500 uppercase font-bold truncate">Quản trị cấp cao</p>
        </div>
      </div>
    </aside>
  );
}
