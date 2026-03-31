// File: src/app/(admin)/notifications/page.tsx
'use client';

import { Megaphone, AlertCircle, Gift, Calendar, MoreHorizontal, Filter, Download, Plus } from 'lucide-react';
import Link from 'next/link';
import { Button, Card } from '@/core/components';
import { mockNotifications, notificationStats } from '@/features/notifications/mock/mock-notifications';
import { cn } from '@/core/lib/utils';
import type { Notification, NotificationType, NotificationStatus, AudienceType } from '@/features/notifications/types';
import { useState } from 'react';

const typeConfig: Record<NotificationType, { icon: React.ElementType; color: string; bg: string }> = {
  announcement: { icon: Calendar, color: 'text-blue-600', bg: 'bg-blue-100' },
  alert: { icon: AlertCircle, color: 'text-red-500', bg: 'bg-red-100' },
  reminder: { icon: Megaphone, color: 'text-amber-600', bg: 'bg-amber-100' },
  promotion: { icon: Gift, color: 'text-purple-600', bg: 'bg-purple-100' },
};

const statusConfig: Record<NotificationStatus, { label: string; color: string; bg: string; dotColor: string }> = {
  draft: { label: 'Draft', color: 'text-slate-600', bg: 'bg-slate-100', dotColor: 'bg-slate-500' },
  scheduled: { label: 'Scheduled', color: 'text-amber-700', bg: 'bg-amber-100', dotColor: 'bg-amber-500' },
  sent: { label: 'Sent', color: 'text-emerald-700', bg: 'bg-emerald-100', dotColor: 'bg-emerald-500' },
  failed: { label: 'Failed', color: 'text-red-600', bg: 'bg-red-100', dotColor: 'bg-red-500' },
};

const audienceConfig: Record<AudienceType, { label: string; color: string; bg: string }> = {
  all: { label: 'All Users', color: 'text-slate-600', bg: 'bg-slate-100' },
  students: { label: 'Students', color: 'text-blue-600', bg: 'bg-blue-50' },
  organizers: { label: 'Organizers', color: 'text-blue-600', bg: 'bg-blue-50' },
  admins: { label: 'Admins', color: 'text-purple-600', bg: 'bg-purple-50' },
  custom: { label: 'Specific Event', color: 'text-purple-600', bg: 'bg-purple-50' },
};

export default function NotificationsPage() {
  const [currentPage, setCurrentPage] = useState(1);
  const totalNotifications = 42;
  const notificationsPerPage = 4;

  return (
    <div className="space-y-8">
      {/* Header Section */}
      <div className="flex flex-col md:flex-row md:items-end justify-between gap-4">
        <div>
          <h2 className="text-2xl font-bold text-slate-900 tracking-tight">
            Notification History
          </h2>
          <p className="text-slate-500 text-sm mt-1">
            Review and manage your push communication logs
          </p>
        </div>
        <div className="flex gap-2">
          <Button
            variant="secondary"
            className="px-4 py-2 rounded-full text-xs font-bold uppercase tracking-wider"
            leftIcon={<Filter className="w-4 h-4" />}
          >
            Filter
          </Button>
          <Button
            variant="secondary"
            className="px-4 py-2 rounded-full text-xs font-bold uppercase tracking-wider"
            leftIcon={<Download className="w-4 h-4" />}
          >
            Export
          </Button>
          <Link href="/notifications/create">
            <Button
              variant="primary"
              className="rounded-full shadow-lg shadow-amber-500/20"
              leftIcon={<Plus className="w-4 h-4" />}
            >
              Create New Notification
            </Button>
          </Link>
        </div>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <Card className="glass-card border-none rounded-3xl p-6">
          <p className="text-[10px] font-bold uppercase tracking-widest text-slate-500 mb-1">
            Total Sent
          </p>
          <div className="flex items-baseline gap-2">
            <span className="text-3xl font-extrabold text-slate-900">
              {notificationStats.totalSent.toLocaleString('en-US')}
            </span>
            {notificationStats.totalSentChange && (
              <span className="text-xs font-bold text-emerald-600">
                {notificationStats.totalSentChange}
              </span>
            )}
          </div>
        </Card>

        <Card className="glass-card border-none rounded-3xl p-6">
          <p className="text-[10px] font-bold uppercase tracking-widest text-slate-500 mb-1">
            Avg. Open Rate
          </p>
          <div className="flex items-baseline gap-2">
            <span className="text-3xl font-extrabold text-slate-900">
              {notificationStats.avgOpenRate}%
            </span>
            {notificationStats.avgOpenRateStatus && (
              <span className="text-xs font-bold text-amber-600">
                {notificationStats.avgOpenRateStatus}
              </span>
            )}
          </div>
        </Card>

        <Card className="glass-card border-none rounded-3xl p-6">
          <p className="text-[10px] font-bold uppercase tracking-widest text-slate-500 mb-1">
            Scheduled
          </p>
          <div className="flex items-baseline gap-2">
            <span className="text-3xl font-extrabold text-slate-900">
              {notificationStats.scheduled}
            </span>
            {notificationStats.scheduledNote && (
              <span className="text-xs font-bold text-slate-400">
                {notificationStats.scheduledNote}
              </span>
            )}
          </div>
        </Card>

        <Card className="glass-card border-none rounded-3xl p-6 overflow-hidden relative">
          <div className="absolute inset-0 opacity-10 pointer-events-none">
            <div className="w-full h-full bg-gradient-to-br from-amber-500 via-purple-500 to-pink-500" />
          </div>
          <p className="text-[10px] font-bold uppercase tracking-widest text-slate-500 mb-1">
            Active Users
          </p>
          <div className="flex items-baseline gap-2">
            <span className="text-3xl font-extrabold text-slate-900">
              {notificationStats.activeUsers.toLocaleString('en-US')}
            </span>
            {notificationStats.activeUsersStatus && (
              <span className="text-xs font-bold text-emerald-600">
                {notificationStats.activeUsersStatus}
              </span>
            )}
          </div>
        </Card>
      </div>

      {/* Notification Table */}
      <Card className="glass-card border-none rounded-[2rem] overflow-hidden shadow-sm">
        <div className="overflow-x-auto">
          <table className="w-full border-collapse text-left">
            <thead>
              <tr className="border-b border-black/5 bg-slate-50/30">
                <th className="px-8 py-5 text-[10px] font-bold uppercase tracking-widest text-slate-400">
                  Notification Title
                </th>
                <th className="px-6 py-5 text-[10px] font-bold uppercase tracking-widest text-slate-400">
                  Target Audience
                </th>
                <th className="px-6 py-5 text-[10px] font-bold uppercase tracking-widest text-slate-400">
                  Sent Date
                </th>
                <th className="px-6 py-5 text-[10px] font-bold uppercase tracking-widest text-slate-400">
                  Status
                </th>
                <th className="px-6 py-5 text-[10px] font-bold uppercase tracking-widest text-slate-400">
                  Performance
                </th>
                <th className="px-8 py-5 text-right text-[10px] font-bold uppercase tracking-widest text-slate-400">
                  Action
                </th>
              </tr>
            </thead>
            <tbody className="divide-y divide-black/5">
              {mockNotifications.map((notification) => (
                <NotificationRow key={notification.id} notification={notification} />
              ))}
            </tbody>
          </table>
        </div>

        {/* Pagination */}
        <div className="px-8 py-4 bg-slate-50/30 flex items-center justify-between">
          <p className="text-xs text-slate-500">
            Showing <span className="font-bold text-slate-900">1-{notificationsPerPage}</span> of{' '}
            <span className="font-bold text-slate-900">{totalNotifications}</span> notifications
          </p>
          <div className="flex gap-2">
            <button
              type="button"
              className="w-8 h-8 flex items-center justify-center rounded-lg border border-slate-200 text-slate-400 hover:bg-white transition-colors disabled:opacity-50"
              disabled={currentPage === 1}
              onClick={() => setCurrentPage(currentPage - 1)}
            >
              <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
              </svg>
            </button>
            <button
              type="button"
              className={cn(
                'w-8 h-8 flex items-center justify-center rounded-lg text-xs font-bold',
                currentPage === 1
                  ? 'bg-amber-500 text-white shadow-sm'
                  : 'border border-slate-200 text-slate-600 hover:bg-white transition-colors'
              )}
              onClick={() => setCurrentPage(1)}
            >
              1
            </button>
            <button
              type="button"
              className={cn(
                'w-8 h-8 flex items-center justify-center rounded-lg text-xs font-bold',
                currentPage === 2
                  ? 'bg-amber-500 text-white shadow-sm'
                  : 'border border-slate-200 text-slate-600 hover:bg-white transition-colors'
              )}
              onClick={() => setCurrentPage(2)}
            >
              2
            </button>
            <button
              type="button"
              className={cn(
                'w-8 h-8 flex items-center justify-center rounded-lg text-xs font-bold',
                currentPage === 3
                  ? 'bg-amber-500 text-white shadow-sm'
                  : 'border border-slate-200 text-slate-600 hover:bg-white transition-colors'
              )}
              onClick={() => setCurrentPage(3)}
            >
              3
            </button>
            <button
              type="button"
              className="w-8 h-8 flex items-center justify-center rounded-lg border border-slate-200 text-slate-400 hover:bg-white transition-colors"
              onClick={() => setCurrentPage(currentPage + 1)}
            >
              <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
              </svg>
            </button>
          </div>
        </div>
      </Card>
    </div>
  );
}

function NotificationRow({ notification }: { notification: Notification }) {
  const type = typeConfig[notification.type];
  const status = statusConfig[notification.status];
  const audience = audienceConfig[notification.audience];
  const TypeIcon = type.icon;

  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    return {
      date: date.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' }),
      time: date.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit', hour12: true }),
    };
  };

  const sentDate = notification.sentAt
    ? formatDate(notification.sentAt)
    : notification.scheduledAt
      ? formatDate(notification.scheduledAt)
      : null;

  return (
    <tr className="hover:bg-slate-50/50 transition-colors group">
      {/* Notification Title */}
      <td className="px-8 py-6">
        <div className="flex items-center gap-4">
          <div className={cn('w-10 h-10 rounded-xl flex items-center justify-center shrink-0', type.bg)}>
            <TypeIcon className={cn('w-5 h-5', type.color)} />
          </div>
          <div>
            <h4 className="font-bold text-slate-900 group-hover:text-amber-600 transition-colors">
              {notification.title}
            </h4>
            <p className="text-xs text-slate-500 truncate max-w-[200px]">
              {notification.message}
            </p>
          </div>
        </div>
      </td>

      {/* Target Audience */}
      <td className="px-6 py-6">
        <span
          className={cn(
            'inline-flex items-center px-2.5 py-0.5 rounded-full text-[10px] font-bold uppercase tracking-tighter',
            audience.bg,
            audience.color
          )}
        >
          {audience.label}
        </span>
      </td>

      {/* Sent Date */}
      <td className="px-6 py-6">
        {sentDate ? (
          <>
            <p className="text-sm font-medium text-slate-700">{sentDate.date}</p>
            <p className="text-[10px] text-slate-400">{sentDate.time}</p>
          </>
        ) : (
          <p className="text-sm text-slate-400 italic">Not sent</p>
        )}
      </td>

      {/* Status */}
      <td className="px-6 py-6">
        <span
          className={cn(
            'inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-[10px] font-extrabold uppercase',
            status.bg,
            status.color
          )}
        >
          <span className={cn('w-1.5 h-1.5 rounded-full', status.dotColor, notification.status === 'scheduled' && 'animate-pulse')} />
          {status.label}
        </span>
      </td>

      {/* Performance */}
      <td className="px-6 py-6">
        {notification.performance ? (
          <div>
            <div className="flex items-center gap-3">
              <div className="flex-1 h-1.5 bg-slate-100 rounded-full overflow-hidden max-w-[80px]">
                <div
                  className="h-full bg-amber-500 rounded-full"
                  style={{ width: `${notification.performance.reachPercentage}%` }}
                />
              </div>
              <span className="text-xs font-bold text-slate-700">
                {notification.performance.reachPercentage}% Reach
              </span>
            </div>
            <p className="text-[10px] text-slate-400 mt-1">
              {notification.performance.openRate}% Open Rate
            </p>
          </div>
        ) : (
          <p className="text-xs text-slate-400 italic">Pending...</p>
        )}
      </td>

      {/* Action */}
      <td className="px-8 py-6 text-right">
        <button
          type="button"
          className="text-slate-400 hover:text-slate-900 transition-colors"
          title="More actions"
        >
          <MoreHorizontal className="w-5 h-5" />
        </button>
      </td>
    </tr>
  );
}
