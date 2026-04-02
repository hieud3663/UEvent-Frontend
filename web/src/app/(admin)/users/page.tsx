// File: src/app/(admin)/users/page.tsx
'use client';

import { useEffect, useMemo, useState } from 'react';
import { TrendingUp, Download, UserPlus, Edit, Shield, Ban, CheckCircle, ChevronLeft, ChevronRight, Plus } from 'lucide-react';
import Image from 'next/image';
import Link from 'next/link';
import { exportUsersCsv, getUsers, getUserStats, unbanUserById } from '@/features/users/services/users.service';
import type { User, UserRole, UserStatus } from '@/features/users/types';
import { cn } from '@/core/lib/utils';
import { runActionWithToast } from '@/core/lib/runActionWithToast';

const roleColorMap: Record<UserRole, string> = {
  student: 'bg-blue-50 text-blue-600',
  organizer: 'bg-amber-50 text-amber-600',
  admin: 'bg-purple-50 text-purple-600',
};

const userStatusDisplay: Record<UserStatus, { color: string; label: string; textColor: string }> = {
  active: { color: 'bg-emerald-500', label: 'Active', textColor: 'text-emerald-600' },
  pending: { color: 'bg-amber-500', label: 'Pending', textColor: 'text-amber-600' },
  banned: { color: 'bg-red-500', label: 'Banned', textColor: 'text-red-500' },
};

export default function UsersPage() {
  const [users, setUsers] = useState<User[]>([]);
  const [stats, setStats] = useState<Awaited<ReturnType<typeof getUserStats>> | null>(null);
  const [currentPage, setCurrentPage] = useState(1);
  const usersPerPage = 10;

  useEffect(() => {
    let isMounted = true;

    async function loadUsersPageData() {
      const [usersResponse, usersStats] = await Promise.all([getUsers(), getUserStats()]);

      if (!isMounted) {
        return;
      }

      setUsers(usersResponse.users);
      setStats(usersStats);
    }

    void loadUsersPageData();

    return () => {
      isMounted = false;
    };
  }, []);

  const totalPages = Math.max(1, Math.ceil(users.length / usersPerPage));
  const safeCurrentPage = Math.min(currentPage, totalPages);

  const paginatedUsers = useMemo(
    () => users.slice((safeCurrentPage - 1) * usersPerPage, safeCurrentPage * usersPerPage),
    [safeCurrentPage, users]
  );

  const handleExport = async () => {
    await runActionWithToast(() => exportUsersCsv(), {
      loading: 'Preparing user export...',
      success: 'User export has been queued.',
      error: 'Failed to export users.',
    });
  };

  const handleUnban = async (userId: string, userName: string) => {
    const previousUsers = users;
    setUsers((prev) => prev.map((user) => (user.id === userId ? { ...user, status: 'active' } : user)));

    try {
      await runActionWithToast(() => unbanUserById(userId), {
        loading: `Unbanning ${userName}...`,
        success: `Unbanned ${userName}.`,
        error: `Failed to unban ${userName}.`,
      });
    } catch {
      setUsers(previousUsers);
    }
  };

  if (!stats) {
    return <div className="p-6 text-sm text-slate-500">Loading users...</div>;
  }

  return (
    <div className="space-y-8">
      {/* Header Section */}
      <div className="flex justify-between items-end">
        <div>
          <h1 className="text-2xl font-bold text-on-surface tracking-tight">
            User Management
          </h1>
          <p className="text-sm text-slate-500 font-medium">
            Manage and monitor platform participants and permissions.
          </p>
        </div>
        <div className="flex gap-3">
          <button 
            type="button"
            onClick={() => {
              void handleExport();
            }}
            className="px-5 py-2.5 bg-white border border-slate-200 rounded-xl text-sm font-bold flex items-center gap-2 hover:bg-slate-50 transition-all"
          >
            <Download className="w-[18px] h-[18px]" />
            Export Data
          </button>
          <Link 
            href="/users/create"
            className="px-5 py-2.5 bg-primary-container text-on-primary-container rounded-xl text-sm font-bold flex items-center gap-2 shadow-lg shadow-amber-500/20 hover:scale-[1.02] active:scale-[0.98] transition-all"
          >
            <UserPlus className="w-[18px] h-[18px]" />
            Add New User
          </Link>
        </div>
      </div>

      {/* Dashboard Stats Bento Style */}
      <div className="grid grid-cols-4 gap-4">
        <div className="glass-card p-5 rounded-2xl flex flex-col gap-1">
          <span className="text-[10px] font-bold text-slate-500 uppercase tracking-widest">Total Users</span>
          <span className="text-2xl font-black text-on-surface">{stats.totalUsers.toLocaleString('en-US')}</span>
          <span className="text-xs text-emerald-600 font-bold flex items-center gap-1">
            <TrendingUp className="w-3 h-3" />
            +12% from last month
          </span>
        </div>
        <div className="glass-card p-5 rounded-2xl flex flex-col gap-1">
          <span className="text-[10px] font-bold text-slate-500 uppercase tracking-widest">Active Organizers</span>
          <span className="text-2xl font-black text-on-surface">{stats.activeOrganizers}</span>
          <span className="text-xs text-slate-400 font-medium">Verified event hosts</span>
        </div>
        <div className="glass-card p-5 rounded-2xl flex flex-col gap-1">
          <span className="text-[10px] font-bold text-slate-500 uppercase tracking-widest">Pending Requests</span>
          <span className="text-2xl font-black text-amber-600">{stats.pendingRequests}</span>
          <span className="text-xs text-amber-600/70 font-bold">Awaiting verification</span>
        </div>
        <div className="glass-card p-5 rounded-2xl flex flex-col gap-1">
          <span className="text-[10px] font-bold text-slate-500 uppercase tracking-widest">Platform Status</span>
          <span className="text-2xl font-black text-emerald-500">{stats.platformStatus}</span>
          <span className="text-xs text-slate-400 font-medium">{stats.uptime} Uptime</span>
        </div>
      </div>

      {/* Main Data Table Container */}
      <div className="glass-card rounded-[32px] overflow-hidden shadow-2xl shadow-black/5">
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="border-b border-white/40">
                <th className="px-6 py-5 text-[10px] font-black text-slate-400 uppercase tracking-[0.1em]">User Profile</th>
                <th className="px-6 py-5 text-[10px] font-black text-slate-400 uppercase tracking-[0.1em]">Student ID</th>
                <th className="px-6 py-5 text-[10px] font-black text-slate-400 uppercase tracking-[0.1em]">Role</th>
                <th className="px-6 py-5 text-[10px] font-black text-slate-400 uppercase tracking-[0.1em]">Status</th>
                <th className="px-6 py-5 text-[10px] font-black text-slate-400 uppercase tracking-[0.1em] text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-white/20">
              {paginatedUsers.map((user) => (
                <UserRow key={user.id} user={user} onUnban={handleUnban} />
              ))}
            </tbody>
          </table>
        </div>

        {/* Pagination */}
        <div className="px-6 py-4 bg-white/30 flex items-center justify-between">
          <span className="text-xs font-bold text-slate-400 uppercase tracking-wider">
            Showing {(safeCurrentPage - 1) * usersPerPage + 1}-{Math.min(safeCurrentPage * usersPerPage, users.length)} of {stats.totalUsers.toLocaleString('en-US')}
          </span>
          <div className="flex gap-2">
            <button
              type="button"
              disabled={safeCurrentPage === 1}
              onClick={() => setCurrentPage((prev) => Math.max(1, prev - 1))}
              className="w-8 h-8 flex items-center justify-center rounded-lg border border-white/40 text-slate-400 hover:bg-white/50 transition-all disabled:opacity-50"
            >
              <ChevronLeft className="w-[18px] h-[18px]" />
            </button>
            {[...Array(Math.min(3, totalPages))].map((_, index) => {
              const page = index + 1;
              return (
                <button
                  key={page}
                  type="button"
                  onClick={() => setCurrentPage(page)}
                  className={cn(
                    'w-8 h-8 flex items-center justify-center rounded-lg text-xs font-bold transition-all',
                    safeCurrentPage === page
                      ? 'bg-amber-500 text-white'
                      : 'hover:bg-white/50 text-slate-600'
                  )}
                >
                  {page}
                </button>
              );
            })}
            <button
              type="button"
              disabled={safeCurrentPage >= totalPages}
              onClick={() => setCurrentPage((prev) => Math.min(totalPages, prev + 1))}
              className="w-8 h-8 flex items-center justify-center rounded-lg border border-white/40 text-slate-400 hover:bg-white/50 transition-all disabled:opacity-50"
            >
              <ChevronRight className="w-[18px] h-[18px]" />
            </button>
          </div>
        </div>
      </div>

      {/* Floating Action Button */}
      <Link 
        href="/users/create"
        className="fixed bottom-8 right-8 w-14 h-14 bg-amber-500 text-white rounded-full shadow-2xl shadow-amber-500/40 flex items-center justify-center hover:scale-110 active:scale-95 transition-all z-50"
      >
        <Plus className="w-6 h-6" />
      </Link>
    </div>
  );
}

function UserRow({
  user,
  onUnban,
}: {
  user: User;
  onUnban: (userId: string, userName: string) => void;
}) {
  const isBanned = user.status === 'banned';
  const status = userStatusDisplay[user.status];

  return (
    <tr className="hover:bg-white/40 transition-colors group">
      <td className="px-6 py-4">
        <div className="flex items-center gap-4">
          <div
            className={cn(
              'relative w-10 h-10 rounded-full bg-slate-200 overflow-hidden ring-2 ring-white ring-offset-2 ring-offset-transparent',
              isBanned && 'grayscale opacity-60'
            )}
          >
            {user.avatar ? (
              <Image src={user.avatar} alt={user.name} fill sizes="40px" className="w-full h-full object-cover" />
            ) : (
              <div className="w-full h-full flex items-center justify-center bg-gradient-to-br from-amber-200 to-amber-400 text-slate-700 font-bold text-sm">
                {user.name.split(' ').map(n => n[0]).join('')}
              </div>
            )}
          </div>
          <div className="flex flex-col">
            <span
              className={cn(
                'text-sm font-bold',
                isBanned ? 'text-slate-400 line-through' : 'text-on-surface'
              )}
            >
              {user.name}
            </span>
            <span className={cn('text-xs', isBanned ? 'text-slate-400' : 'text-slate-500')}>
              {user.email}
            </span>
          </div>
        </div>
      </td>
      <td className="px-6 py-4">
        <span
          className={cn(
            'text-sm font-mono font-medium',
            isBanned ? 'text-slate-400' : 'text-slate-600'
          )}
        >
          {user.studentId}
        </span>
      </td>
      <td className="px-6 py-4">
        <span
          className={cn(
            'px-3 py-1 text-[10px] font-black uppercase rounded-full',
            isBanned ? 'bg-slate-100 text-slate-500' : roleColorMap[user.role]
          )}
        >
          {user.role}
        </span>
      </td>
      <td className="px-6 py-4">
        <div className="flex items-center gap-2">
          <div
            className={cn(
              'w-2 h-2 rounded-full',
              status.color,
              user.status === 'active' && 'shadow-[0_0_8px_rgba(16,185,129,0.5)]'
            )}
          />
          <span className={cn('text-xs font-bold', status.textColor)}>
            {status.label}
          </span>
        </div>
      </td>
      <td className="px-6 py-4 text-right">
        <div className="flex justify-end gap-3">
          <Link
            href={`/users/${user.id}`}
            className="p-2 bg-white/40 backdrop-blur-sm border border-white/40 rounded-lg text-amber-600 hover:bg-amber-500 hover:text-white transition-all shadow-sm flex items-center justify-center"
            title="Edit User"
          >
            <Edit className="w-[18px] h-[18px]" />
          </Link>
          <Link
            href="/permissions"
            className="p-2 bg-white/40 backdrop-blur-sm border border-white/40 rounded-lg text-amber-600 hover:bg-amber-500 hover:text-white transition-all shadow-sm flex items-center justify-center"
            title="Permissions"
          >
            <Shield className="w-[18px] h-[18px]" />
          </Link>
          {isBanned ? (
            <button
              onClick={() => {
                void onUnban(user.id, user.name);
              }}
              className="p-2 bg-white/40 backdrop-blur-sm border border-white/40 rounded-lg text-emerald-500 hover:bg-emerald-500 hover:text-white transition-all shadow-sm flex items-center justify-center"
              title="Unban User"
              type="button"
            >
              <CheckCircle className="w-[18px] h-[18px]" />
            </button>
          ) : (
            <Link
              href={`/users/${user.id}/ban`}
              className="p-2 bg-white/40 backdrop-blur-sm border border-white/40 rounded-lg text-red-500 hover:bg-red-500 hover:text-white transition-all shadow-sm flex items-center justify-center"
              title="Ban User"
            >
              <Ban className="w-[18px] h-[18px]" />
            </Link>
          )}
        </div>
      </td>
    </tr>
  );
}
