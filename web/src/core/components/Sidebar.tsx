// File: src/core/components/Sidebar.tsx
'use client';

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
  Shield,
} from 'lucide-react';
import { cn } from '@/core/lib/utils';
import type { NavItem } from '@/core/types/navigation';

const navItems: NavItem[] = [
  { label: 'Dashboard', href: '/dashboard', icon: LayoutDashboard },
  { label: 'Users', href: '/users', icon: Users },
  { label: 'Events', href: '/events', icon: Calendar },
  { label: 'Categories', href: '/categories', icon: FolderOpen },
  { label: 'Notifications', href: '/notifications', icon: Bell },
  { label: 'Support', href: '/support', icon: HeadphonesIcon },
  { label: 'Settings', href: '/settings', icon: Settings },
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
        'h-screen w-64 fixed left-0 top-0 z-40',
        'bg-white/70 backdrop-blur-3xl',
        'border-r border-white/40',
        'flex flex-col p-4',
        'shadow-2xl shadow-black/5',
        className
      )}
    >
      {/* Logo */}
      <div className="mb-10 px-4">
        <span className="text-xl font-black text-slate-800 tracking-tight">
          UEvents Admin
        </span>
        <p className="text-[10px] font-bold uppercase tracking-wider text-slate-400 mt-1">
          MANAGEMENT PORTAL
        </p>
      </div>

      {/* Navigation */}
      <nav className="flex flex-col gap-1 flex-1">
        {navItems.map((item) => {
          const isActive = pathname === item.href || pathname?.startsWith(`${item.href}/`);
          const Icon = item.icon;

          return (
            <Link
              key={item.href}
              href={item.href}
              className={cn(
                'flex items-center gap-4 px-4 py-3 rounded-xl transition-all duration-200',
                isActive
                  ? 'bg-amber-500 text-white font-bold shadow-lg shadow-amber-500/20'
                  : 'text-slate-500 hover:text-slate-800 hover:bg-white/50'
              )}
            >
              <Icon className="w-5 h-5" />
              <span className={cn('text-sm', isActive ? 'font-bold' : 'font-medium')}>{item.label}</span>
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
      <div className="mt-auto p-4 flex items-center gap-3 glass-card rounded-2xl border border-white/60">
        <div className="w-10 h-10 rounded-full overflow-hidden bg-slate-200">
          <img
            src="https://lh3.googleusercontent.com/aida-public/AB6AXuDV320YMqiYUJZn9nyC85F61ox_xlvreWDOTEqyzT_FR47l5PqjYlues7JX8exjtAHIJ2yVVUK5RnOQaAiFTyNWIInCwT-JZ7Qn91g-1ro-CrcgU7pGPZXkv7VNwfayOdKYwlJmxdiaBcSuAAJm9cZZiIVPAq3hupYI4jedmyGX2BCGzXOPfoJCky_ieXThT4FnivS5VNjQrzSBkpJ6UuDcFO38zPXjCLXogfbaN486bpvnr_LoT516mwma65yIzZpXSnv1D6bD8jk"
            alt="Admin User"
            className="w-full h-full object-cover"
          />
        </div>
        <div className="overflow-hidden">
          <p className="text-xs font-bold text-slate-900 truncate">Admin User</p>
          <p className="text-[10px] text-slate-500 uppercase font-bold truncate">Super Admin</p>
        </div>
      </div>
    </aside>
  );
}
