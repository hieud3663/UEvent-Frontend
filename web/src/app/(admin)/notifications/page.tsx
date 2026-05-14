// File: src/app/(admin)/notifications/page.tsx
'use client';

import { useEffect, useMemo, useState } from 'react';
import type { ElementType } from 'react';
import { MoreHorizontal, Filter, Download, Plus, AlertCircle, Calendar, Gift, Megaphone } from 'lucide-react';
import Link from 'next/link';
import { Button, Card } from '@/core/components';
import {
  exportNotificationsHistory,
  getNotifications,
  getNotificationPaginationConfig,
  getNotificationStats,
} from '@/features/notifications/services/notifications.service';
import { cn } from '@/core/lib/utils';
import type {
  AudienceType,
  Notification,
  NotificationPaginationConfig,
  NotificationStatus,
  NotificationType,
} from '@/features/notifications/types';
import { runActionWithToast } from '@/core/lib/runActionWithToast';

const notificationTypeConfig: Record<
  NotificationType,
  { icon: ElementType; color: string; bg: string }
> = {
  announcement: { icon: Calendar, color: 'text-blue-600', bg: 'bg-blue-100' },
  alert: { icon: AlertCircle, color: 'text-red-500', bg: 'bg-red-100' },
  reminder: { icon: Megaphone, color: 'text-amber-600', bg: 'bg-amber-100' },
  promotion: { icon: Gift, color: 'text-purple-600', bg: 'bg-purple-100' },
};

const notificationStatusConfig: Record<
  NotificationStatus,
  { label: string; color: string; bg: string; dotColor: string }
> = {
  draft: { label: 'Bản nháp', color: 'text-slate-600', bg: 'bg-slate-100', dotColor: 'bg-slate-500' },
  scheduled: { label: 'Đã lên lịch', color: 'text-amber-700', bg: 'bg-amber-100', dotColor: 'bg-amber-500' },
  sent: { label: 'Đã gửi', color: 'text-emerald-700', bg: 'bg-emerald-100', dotColor: 'bg-emerald-500' },
  failed: { label: 'Thất bại', color: 'text-red-600', bg: 'bg-red-100', dotColor: 'bg-red-500' },
};

const notificationAudienceConfig: Record<
  AudienceType,
  { label: string; color: string; bg: string }
> = {
  all: { label: 'Tất cả người dùng', color: 'text-slate-600', bg: 'bg-slate-100' },
  students: { label: 'Sinh viên', color: 'text-blue-600', bg: 'bg-blue-50' },
  organizers: { label: 'Nhà tổ chức', color: 'text-blue-600', bg: 'bg-blue-50' },
  admins: { label: 'Quản trị viên', color: 'text-purple-600', bg: 'bg-purple-50' },
  custom: { label: 'Sự kiện cụ thể', color: 'text-purple-600', bg: 'bg-purple-50' },
};

export default function NotificationsPage() {
  const [notifications, setNotifications] = useState<Notification[]>([]);
  const [stats, setStats] = useState<Awaited<ReturnType<typeof getNotificationStats>> | null>(null);
  const [paginationConfig, setPaginationConfig] = useState<NotificationPaginationConfig | null>(null);
  const [currentPage, setCurrentPage] = useState(1);
  const notificationsPerPage = paginationConfig?.perPage ?? 4;

  useEffect(() => {
    let isMounted = true;

    async function loadNotificationsPageData() {
      const [notificationsResponse, notificationStats, config] = await Promise.all([
        getNotifications(),
        getNotificationStats(),
        getNotificationPaginationConfig(),
      ]);

      if (!isMounted) {
        return;
      }

      setNotifications(notificationsResponse);
      setStats(notificationStats);
      setPaginationConfig(config);
    }

    void loadNotificationsPageData();

    return () => {
      isMounted = false;
    };
  }, []);

  const totalNotifications = notifications.length;
  const totalPages = Math.max(1, Math.ceil(totalNotifications / notificationsPerPage));
  const safeCurrentPage = Math.min(currentPage, totalPages);

  const paginatedNotifications = useMemo(
    () =>
      notifications.slice(
        (safeCurrentPage - 1) * notificationsPerPage,
        safeCurrentPage * notificationsPerPage
      ),
    [safeCurrentPage, notifications, notificationsPerPage]
  );

  const handleFilter = async () => {
    await runActionWithToast(async () => Promise.resolve(), {
      loading: 'Đang chuẩn bị bộ lọc thông báo...',
      success: 'Bộ lọc thông báo đã sẵn sàng.',
      error: 'Không thể mở bộ lọc thông báo.',
    });
  };

  const handleExport = async () => {
    await runActionWithToast(() => exportNotificationsHistory(), {
      loading: 'Đang chuẩn bị file xuất thông báo...',
      success: 'Yêu cầu xuất lịch sử thông báo đã được đưa vào hàng đợi.',
      error: 'Không thể xuất lịch sử thông báo.',
    });
  };

  const handleMoreActions = async (notification: Notification) => {
    await runActionWithToast(async () => Promise.resolve(), {
      loading: `Đang mở thao tác cho "${notification.title}"...`,
      success: `Menu thao tác cho "${notification.title}" đã sẵn sàng.`,
      error: `Không thể mở thao tác cho "${notification.title}".`,
    });
  };

  if (!stats || !paginationConfig) {
    return <div className="p-6 text-sm text-slate-500">Đang tải thông báo...</div>;
  }

  const visiblePageCount = Math.min(paginationConfig.maxVisiblePages, totalPages);
  const pageNumbers = Array.from({ length: visiblePageCount }, (_, index) => index + 1);

  return (
    <div className="space-y-8">
      {/* Header Section */}
      <div className="flex flex-col md:flex-row md:items-end justify-between gap-4">
        <div>
          <h2 className="text-2xl font-bold text-slate-900 tracking-tight">
            Lịch sử thông báo
          </h2>
          <p className="text-slate-500 text-sm mt-1">
            Xem lại và quản lý nhật ký gửi thông báo cho người dùng.
          </p>
        </div>
        <div className="flex flex-wrap gap-2">
          <Button
            variant="secondary"
            onClick={() => {
              void handleFilter();
            }}
            className="px-4 py-2 rounded-full text-xs font-bold uppercase tracking-wider"
            leftIcon={<Filter className="w-4 h-4" />}
          >
            Lọc
          </Button>
          <Button
            variant="secondary"
            onClick={() => {
              void handleExport();
            }}
            className="px-4 py-2 rounded-full text-xs font-bold uppercase tracking-wider"
            leftIcon={<Download className="w-4 h-4" />}
          >
            Xuất file
          </Button>
          <Link href="/notifications/create">
            <Button
              variant="primary"
              className="rounded-full shadow-lg shadow-amber-500/20"
              leftIcon={<Plus className="w-4 h-4" />}
            >
              Tạo thông báo
            </Button>
          </Link>
        </div>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4 lg:gap-6">
        <Card className="glass-card border-none rounded-3xl p-6">
          <p className="text-[10px] font-bold uppercase tracking-widest text-slate-500 mb-1">
            Tổng đã gửi
          </p>
          <div className="flex items-baseline gap-2">
            <span className="text-3xl font-extrabold text-slate-900">
              {stats.totalSent.toLocaleString('en-US')}
            </span>
            {stats.totalSentChange && (
              <span className="text-xs font-bold text-emerald-600">
                {stats.totalSentChange}
              </span>
            )}
          </div>
        </Card>

        <Card className="glass-card border-none rounded-3xl p-6">
          <p className="text-[10px] font-bold uppercase tracking-widest text-slate-500 mb-1">
            Tỷ lệ mở trung bình
          </p>
          <div className="flex items-baseline gap-2">
            <span className="text-3xl font-extrabold text-slate-900">
              {stats.avgOpenRate}%
            </span>
            {stats.avgOpenRateStatus && (
              <span className="text-xs font-bold text-amber-600">
                {stats.avgOpenRateStatus}
              </span>
            )}
          </div>
        </Card>

        <Card className="glass-card border-none rounded-3xl p-6">
          <p className="text-[10px] font-bold uppercase tracking-widest text-slate-500 mb-1">
            Đã lên lịch
          </p>
          <div className="flex items-baseline gap-2">
            <span className="text-3xl font-extrabold text-slate-900">
              {stats.scheduled}
            </span>
            {stats.scheduledNote && (
              <span className="text-xs font-bold text-slate-400">
                {stats.scheduledNote}
              </span>
            )}
          </div>
        </Card>

        <Card className="glass-card border-none rounded-3xl p-6 overflow-hidden relative">
          <div className="absolute inset-0 opacity-10 pointer-events-none">
            <div className="w-full h-full bg-gradient-to-br from-amber-500 via-purple-500 to-pink-500" />
          </div>
          <p className="text-[10px] font-bold uppercase tracking-widest text-slate-500 mb-1">
            Người dùng hoạt động
          </p>
          <div className="flex items-baseline gap-2">
            <span className="text-3xl font-extrabold text-slate-900">
              {stats.activeUsers.toLocaleString('en-US')}
            </span>
            {stats.activeUsersStatus && (
              <span className="text-xs font-bold text-emerald-600">
                {stats.activeUsersStatus}
              </span>
            )}
          </div>
        </Card>
      </div>

      {/* Notification Table */}
      <Card className="glass-card border-none rounded-[2rem] overflow-hidden shadow-sm">
        <div className="overflow-x-auto">
          <table className="min-w-[920px] w-full border-collapse text-left">
            <thead>
              <tr className="border-b border-black/5 bg-slate-50/30">
                <th className="px-8 py-5 text-[10px] font-bold uppercase tracking-widest text-slate-400">
                  Tiêu đề thông báo
                </th>
                <th className="px-6 py-5 text-[10px] font-bold uppercase tracking-widest text-slate-400">
                  Đối tượng nhận
                </th>
                <th className="px-6 py-5 text-[10px] font-bold uppercase tracking-widest text-slate-400">
                  Ngày gửi
                </th>
                <th className="px-6 py-5 text-[10px] font-bold uppercase tracking-widest text-slate-400">
                  Trạng thái
                </th>
                <th className="px-6 py-5 text-[10px] font-bold uppercase tracking-widest text-slate-400">
                  Hiệu suất
                </th>
                <th className="px-8 py-5 text-right text-[10px] font-bold uppercase tracking-widest text-slate-400">
                  Thao tác
                </th>
              </tr>
            </thead>
            <tbody className="divide-y divide-black/5">
              {paginatedNotifications.map((notification) => (
                <NotificationRow
                  key={notification.id}
                  notification={notification}
                  onMoreActions={handleMoreActions}
                />
              ))}
            </tbody>
          </table>
        </div>

        {/* Pagination */}
        <div className="flex flex-col gap-3 bg-slate-50/30 px-4 py-4 sm:px-8 md:flex-row md:items-center md:justify-between">
          <p className="text-xs text-slate-500">
            Hiển thị <span className="font-bold text-slate-900">{(safeCurrentPage - 1) * notificationsPerPage + 1}-{Math.min(safeCurrentPage * notificationsPerPage, totalNotifications)}</span> trong{' '}
            <span className="font-bold text-slate-900">{totalNotifications}</span> thông báo
          </p>
          <div className="flex gap-2">
            <button
              type="button"
              className="w-8 h-8 flex items-center justify-center rounded-lg border border-slate-200 text-slate-400 hover:bg-white transition-colors disabled:opacity-50"
              disabled={currentPage === 1}
              onClick={() => setCurrentPage((prev) => Math.max(1, prev - 1))}
              title="Trang trước"
            >
              <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
              </svg>
            </button>
            {pageNumbers.map((pageNumber) => (
              <button
                key={pageNumber}
                type="button"
                className={cn(
                  'w-8 h-8 flex items-center justify-center rounded-lg text-xs font-bold',
                  safeCurrentPage === pageNumber
                    ? 'bg-amber-500 text-white shadow-sm'
                    : 'border border-slate-200 text-slate-600 hover:bg-white transition-colors'
                )}
                onClick={() => setCurrentPage(pageNumber)}
              >
                {pageNumber}
              </button>
            ))}
            <button
              type="button"
              className="w-8 h-8 flex items-center justify-center rounded-lg border border-slate-200 text-slate-400 hover:bg-white transition-colors"
              disabled={safeCurrentPage >= totalPages}
              onClick={() => setCurrentPage((prev) => Math.min(totalPages, prev + 1))}
              title="Trang sau"
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

function NotificationRow({
  notification,
  onMoreActions,
}: {
  notification: Notification;
  onMoreActions: (notification: Notification) => void;
}) {
  const type = notificationTypeConfig[notification.type];
  const status = notificationStatusConfig[notification.status];
  const audience = notificationAudienceConfig[notification.audience];
  const TypeIcon = type.icon;

  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    return {
      date: date.toLocaleDateString('vi-VN', { month: 'short', day: 'numeric', year: 'numeric' }),
      time: date.toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' }),
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
          <p className="text-sm text-slate-400 italic">Chưa gửi</p>
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
                {notification.performance.reachPercentage}% tiếp cận
              </span>
            </div>
            <p className="text-[10px] text-slate-400 mt-1">
              {notification.performance.openRate}% mở
            </p>
          </div>
        ) : (
          <p className="text-xs text-slate-400 italic">Đang chờ...</p>
        )}
      </td>

      {/* Action */}
      <td className="px-8 py-6 text-right">
        <button
          type="button"
          onClick={() => onMoreActions(notification)}
          className="text-slate-400 hover:text-slate-900 transition-colors"
          title="Thêm thao tác"
        >
          <MoreHorizontal className="w-5 h-5" />
        </button>
      </td>
    </tr>
  );
}
