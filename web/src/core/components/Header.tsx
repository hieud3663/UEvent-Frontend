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
        'fixed top-0 right-0 left-64 h-16 z-30',
        'border-b border-black/10',
        'ios-blur',
        'flex items-center justify-between px-8',
        className
      )}
    >
      {/* Search Bar */}
      <div className="flex items-center gap-4 bg-slate-200/50 px-4 py-2 rounded-full w-96">
        <Search className="w-4 h-4 text-slate-400" />
        <input
          type="text"
          placeholder="Search events or users..."
          className="bg-transparent border-none focus:ring-0 focus:outline-none text-sm w-full placeholder:text-slate-500"
        />
      </div>

      {/* Right Side Actions */}
      <div className="flex items-center gap-6">
        {/* Quick Actions */}
        <div className="flex items-center gap-4">
          <button
            type="button"
            className="text-slate-600 hover:text-slate-800 transition-colors"
            aria-label="Help"
          >
            <HelpCircle className="w-5 h-5" />
          </button>
          <button
            type="button"
            className="text-slate-600 hover:text-slate-800 transition-colors"
            aria-label="Settings"
          >
            <Settings className="w-5 h-5" />
          </button>
          <button
            type="button"
            className="text-slate-600 hover:text-slate-800 transition-colors relative"
            aria-label="Notifications"
          >
            <Bell className="w-5 h-5" />
            <span className="absolute -top-1 -right-1 w-2 h-2 bg-red-500 rounded-full" />
          </button>
        </div>

        {/* Divider */}
        <div className="h-8 w-px bg-black/10" />

        {/* User Info */}
        <div className="flex items-center gap-3">
          <span className="text-sm font-medium text-slate-900">UEvents Control</span>
          <div className="w-8 h-8 rounded-full bg-amber-500 flex items-center justify-center border-2 border-white/40">
            <span className="text-white font-bold text-xs">UC</span>
          </div>
        </div>
      </div>
    </header>
  );
}
