// File: src/core/components/Header.tsx
'use client';

import { Search, HelpCircle, Settings, Bell } from 'lucide-react';
import { cn } from '@/core/lib/utils';

interface HeaderProps {
  className?: string;
}

export function Header({ className }: HeaderProps) {
  return (
    <header
      className={cn(
        'fixed top-0 right-0 left-0 h-16 z-30 lg:left-64',
        'border-b border-black/10',
        'ios-blur',
        'flex items-center justify-between px-4 sm:px-6 lg:px-8',
        className
      )}
    >
      {/* Search Bar */}
      <div className="hidden min-w-0 items-center gap-4 rounded-full bg-slate-200/50 px-4 py-2 sm:flex sm:w-72 lg:w-96">
        {/* <Search className="w-4 h-4 text-slate-400" />
        <input
          type="text"
          placeholder="Tìm sự kiện hoặc người dùng..."
          className="bg-transparent border-none focus:ring-0 focus:outline-none text-sm w-full placeholder:text-slate-500"
        /> */}
      </div>

      {/* Right Side Actions */}
      <div className="flex items-center gap-6">
        {/* Quick Actions */}
        <div className="flex items-center gap-4">
          <button
            type="button"
            className="text-slate-600 hover:text-slate-800 transition-colors"
            aria-label="Trợ giúp"
          >
            <HelpCircle className="w-5 h-5" />
          </button>
          <button
            type="button"
            className="text-slate-600 hover:text-slate-800 transition-colors"
            aria-label="Cài đặt"
          >
            <Settings className="w-5 h-5" />
          </button>
          <button
            type="button"
            className="text-slate-600 hover:text-slate-800 transition-colors relative"
            aria-label="Thông báo"
          >
            <Bell className="w-5 h-5" />
            <span className="absolute -top-1 -right-1 w-2 h-2 bg-red-500 rounded-full" />
          </button>
        </div>

        {/* Divider */}
        <div className="hidden h-8 w-px bg-black/10 sm:block" />

        {/* User Info */}
        <div className="flex items-center gap-3">
          <span className="hidden text-sm font-medium text-slate-900 sm:inline">Bảng điều khiển UEvents</span>
          <div className="w-8 h-8 rounded-full bg-amber-500 flex items-center justify-center border-2 border-white/40">
            <span className="text-white font-bold text-xs">UC</span>
          </div>
        </div>
      </div>
    </header>
  );
}
