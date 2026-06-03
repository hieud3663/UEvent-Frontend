// File: src/core/components/Header.tsx
'use client';

import Image from 'next/image';
import { FormEvent, useEffect, useMemo, useRef, useState } from 'react';
import { useRouter } from 'next/navigation';
import { Bell, ChevronDown, HelpCircle, LogOut, Search, Settings } from 'lucide-react';
import { AdminSelect } from '@/core/components/AdminSelect';
import { cn } from '@/core/lib/utils';
import { getCurrentAdmin, logoutAdmin } from '@/features/auth/services/auth.service';
import type { AdminUserInfo } from '@/features/auth/types';

interface HeaderProps {
  className?: string;
}

const SEARCH_SCOPES = [
  { value: 'users', label: 'Người dùng', href: '/users' },
  { value: 'events', label: 'Sự kiện', href: '/events' },
  { value: 'locations', label: 'Địa điểm', href: '/locations' },
  { value: 'tickets', label: 'Vé', href: '/tickets' },
  { value: 'categories', label: 'Danh mục', href: '/categories' },
  { value: 'notifications', label: 'Thông báo', href: '/notifications' },
  { value: 'support', label: 'Hỗ trợ', href: '/support' },
] as const;

type SearchScope = (typeof SEARCH_SCOPES)[number]['value'];

export function Header({ className }: HeaderProps) {
  const router = useRouter();
  const menuRef = useRef<HTMLDivElement | null>(null);
  const [admin, setAdmin] = useState<AdminUserInfo | null>(null);
  const [isAccountMenuOpen, setIsAccountMenuOpen] = useState(false);
  const [searchScope, setSearchScope] = useState<SearchScope>('users');
  const [searchQuery, setSearchQuery] = useState('');
  const [isLoggingOut, setIsLoggingOut] = useState(false);

  useEffect(() => {
    let mounted = true;
    getCurrentAdmin()
      .then((currentAdmin) => {
        if (mounted) setAdmin(currentAdmin);
      })
      .catch(() => {
        if (mounted) setAdmin(null);
      });

    return () => {
      mounted = false;
    };
  }, []);

  useEffect(() => {
    if (!isAccountMenuOpen) return;

    const handleClickOutside = (event: MouseEvent) => {
      if (menuRef.current && !menuRef.current.contains(event.target as Node)) {
        setIsAccountMenuOpen(false);
      }
    };

    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, [isAccountMenuOpen]);

  const initials = useMemo(() => getInitials(admin?.fullName || admin?.username || 'Admin'), [admin]);
  const displayName = admin?.fullName || admin?.username || 'Quản trị viên';

  const handleSearchSubmit = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    const query = searchQuery.trim();
    if (!query) return;

    const scope = SEARCH_SCOPES.find((item) => item.value === searchScope) ?? SEARCH_SCOPES[0];
    router.push(`${scope.href}?search=${encodeURIComponent(query)}`);
  };

  const handleLogout = async () => {
    setIsLoggingOut(true);
    try {
      await logoutAdmin();
    } finally {
      router.replace('/login');
      router.refresh();
    }
  };

  return (
    <header
      className={cn(
        'fixed top-0 right-0 left-0 h-16 z-30 lg:left-64',
        'border-b border-black/10',
        'ios-blur',
        'flex items-center justify-end px-4 sm:justify-between sm:px-6 lg:px-8',
        className
      )}
    >
      <form
        onSubmit={handleSearchSubmit}
        className="hidden min-w-0 items-center gap-2 rounded-full bg-slate-200/50 px-3 py-2 sm:flex sm:w-[28rem] lg:w-[34rem]"
      >
        <Search className="h-4 w-4 shrink-0 text-slate-400" />
        <input
          type="text"
          value={searchQuery}
          onChange={(event) => setSearchQuery(event.target.value)}
          placeholder="Tìm trong admin..."
          className="min-w-0 flex-1 border-none bg-transparent text-sm font-medium text-slate-800 outline-none placeholder:text-slate-500"
        />
        <AdminSelect<SearchScope>
          value={searchScope}
          onChange={setSearchScope}
          options={SEARCH_SCOPES}
          ariaLabel="Phạm vi tìm kiếm"
          className="w-36 shrink-0"
          triggerClassName="h-8 rounded-full border-white/70 bg-white/70 px-3 text-xs font-bold text-slate-600 hover:border-amber-300"
          menuClassName="right-0 left-auto w-44 rounded-2xl"
        />
      </form>

      <div className="flex min-w-0 items-center gap-3 sm:gap-6">
        <div className="flex items-center gap-3 sm:gap-4">
          <button
            type="button"
            onClick={() => router.push('/support')}
            className="text-slate-600 transition-colors hover:text-slate-800"
            aria-label="Trợ giúp"
          >
            <HelpCircle className="h-5 w-5" />
          </button>
          <button
            type="button"
            onClick={() => router.push('/settings')}
            className="text-slate-600 transition-colors hover:text-slate-800"
            aria-label="Cài đặt"
          >
            <Settings className="h-5 w-5" />
          </button>
          <button
            type="button"
            onClick={() => router.push('/notifications')}
            className="relative text-slate-600 transition-colors hover:text-slate-800"
            aria-label="Thông báo"
          >
            <Bell className="h-5 w-5" />
          </button>
        </div>

        <div className="hidden h-8 w-px bg-black/10 sm:block" />

        <div ref={menuRef} className="relative">
          <button
            type="button"
            onClick={() => setIsAccountMenuOpen((open) => !open)}
            className="flex min-w-0 items-center gap-2 rounded-full px-1 py-1 transition hover:bg-white/60"
            aria-haspopup="menu"
            aria-expanded={isAccountMenuOpen}
          >
            <span className="hidden max-w-40 truncate text-sm font-bold text-slate-900 sm:inline">{displayName}</span>
            <span className="relative flex h-9 w-9 shrink-0 items-center justify-center overflow-hidden rounded-full border-2 border-white/50 bg-amber-500">
              {admin?.avatarUrl ? (
                <Image src={admin.avatarUrl} alt={displayName} fill sizes="36px" className="object-cover" />
              ) : (
                <span className="text-xs font-black text-white">{initials}</span>
              )}
            </span>
            <ChevronDown className="hidden h-4 w-4 text-slate-500 sm:block" />
          </button>

          {isAccountMenuOpen ? (
            <div
              role="menu"
              className="absolute right-0 mt-3 w-64 rounded-2xl border border-white/70 bg-white/95 p-2 shadow-xl shadow-black/10 backdrop-blur-xl"
            >
              <div className="border-b border-slate-100 px-3 py-3">
                <p className="truncate text-sm font-bold text-slate-900">{displayName}</p>
                <p className="truncate text-xs text-slate-500">{admin?.email || admin?.username || 'Admin'}</p>
              </div>
              <button
                type="button"
                role="menuitem"
                disabled={isLoggingOut}
                onClick={() => {
                  void handleLogout();
                }}
                className="mt-2 flex w-full items-center gap-2 rounded-xl px-3 py-2 text-left text-sm font-bold text-red-600 transition hover:bg-red-50 disabled:cursor-not-allowed disabled:opacity-60"
              >
                <LogOut className="h-4 w-4" />
                {isLoggingOut ? 'Đang đăng xuất...' : 'Đăng xuất'}
              </button>
            </div>
          ) : null}
        </div>
      </div>
    </header>
  );
}

function getInitials(name: string): string {
  return (
    name
      .split(/\s+/)
      .filter(Boolean)
      .slice(0, 2)
      .map((part) => part[0]?.toUpperCase())
      .join('') || 'AD'
  );
}
