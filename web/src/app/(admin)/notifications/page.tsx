'use client';

import { useCallback, useEffect, useMemo, useState } from 'react';
import type { ElementType } from 'react';
import type { ReactNode } from 'react';
import {
  AlertCircle,
  Calendar,
  ChevronLeft,
  ChevronRight,
  Download,
  Eye,
  FileSpreadsheet,
  Gift,
  Megaphone,
  Pencil,
  Plus,
  RotateCcw,
  Search,
  Send,
  Trash2,
} from 'lucide-react';
import Link from 'next/link';
import { AdminSelect, Button, Card, ConfirmActionDialog, EmptyState, ErrorState } from '@/core/components';
import {
  deleteNotificationById,
  exportNotificationsHistory,
  getNotificationPaginationConfig,
  getNotificationStats,
  getNotificationsPage,
  publishNotificationById,
  type NotificationExportFormat,
  type NotificationFilters,
} from '@/features/notifications/services/notifications.service';
import { cn } from '@/core/lib/utils';
import type {
  AudienceType,
  Notification,
  NotificationPaginationConfig,
  NotificationStats,
  NotificationStatus,
  NotificationType,
} from '@/features/notifications/types';
import { runActionWithToast } from '@/core/lib/runActionWithToast';

const notificationTypeConfig: Record<NotificationType, { icon: ElementType; color: string; bg: string; label: string }> = {
  announcement: { icon: Calendar, color: 'text-blue-600', bg: 'bg-blue-100', label: 'Thông báo' },
  alert: { icon: AlertCircle, color: 'text-red-500', bg: 'bg-red-100', label: 'Cảnh báo' },
  reminder: { icon: Megaphone, color: 'text-amber-600', bg: 'bg-amber-100', label: 'Nhắc lịch' },
  promotion: { icon: Gift, color: 'text-purple-600', bg: 'bg-purple-100', label: 'Ưu đãi' },
  invite: { icon: Send, color: 'text-cyan-600', bg: 'bg-cyan-100', label: 'Lời mời' },
  ticket_confirm: { icon: Calendar, color: 'text-emerald-600', bg: 'bg-emerald-100', label: 'Vé' },
};

const notificationStatusConfig: Record<NotificationStatus, { label: string; color: string; bg: string; dotColor: string }> = {
  draft: { label: 'Bản nháp', color: 'text-slate-600', bg: 'bg-slate-100', dotColor: 'bg-slate-500' },
  scheduled: { label: 'Đã lên lịch', color: 'text-amber-700', bg: 'bg-amber-100', dotColor: 'bg-amber-500' },
  sent: { label: 'Đã gửi', color: 'text-emerald-700', bg: 'bg-emerald-100', dotColor: 'bg-emerald-500' },
  failed: { label: 'Thất bại', color: 'text-red-600', bg: 'bg-red-100', dotColor: 'bg-red-500' },
};

const notificationAudienceConfig: Record<AudienceType, { label: string; color: string; bg: string }> = {
  all: { label: 'Tất cả người dùng', color: 'text-slate-600', bg: 'bg-slate-100' },
  students: { label: 'Sinh viên', color: 'text-blue-600', bg: 'bg-blue-50' },
  organizers: { label: 'Nhà tổ chức', color: 'text-blue-600', bg: 'bg-blue-50' },
  admins: { label: 'Quản trị viên', color: 'text-purple-600', bg: 'bg-purple-50' },
  custom: { label: 'Tùy chọn', color: 'text-purple-600', bg: 'bg-purple-50' },
};

const statusOptions = [
  { value: 'all', label: 'Tất cả trạng thái' },
  { value: 'draft', label: 'Bản nháp' },
  { value: 'scheduled', label: 'Đã lên lịch' },
  { value: 'sent', label: 'Đã gửi' },
  { value: 'failed', label: 'Thất bại' },
] as const;

const audienceOptions = [
  { value: 'all_filter', label: 'Mọi đối tượng' },
  { value: 'all', label: 'Tất cả người dùng' },
  { value: 'students', label: 'Sinh viên' },
  { value: 'organizers', label: 'Nhà tổ chức' },
  { value: 'admins', label: 'Quản trị viên' },
  { value: 'custom', label: 'Tùy chọn' },
] as const;

const typeOptions = [
  { value: 'all', label: 'Mọi loại' },
  { value: 'announcement', label: 'Thông báo' },
  { value: 'alert', label: 'Cảnh báo' },
  { value: 'reminder', label: 'Nhắc lịch' },
  { value: 'promotion', label: 'Ưu đãi' },
  { value: 'invite', label: 'Lời mời' },
  { value: 'ticket_confirm', label: 'Vé' },
] as const;

export default function NotificationsPage() {
  const [notifications, setNotifications] = useState<Notification[]>([]);
  const [stats, setStats] = useState<NotificationStats | null>(null);
  const [paginationConfig, setPaginationConfig] = useState<NotificationPaginationConfig | null>(null);
  const [keyword, setKeyword] = useState('');
  const [status, setStatus] = useState<'all' | NotificationStatus>('all');
  const [type, setType] = useState<'all' | NotificationType>('all');
  const [audience, setAudience] = useState<'all_filter' | AudienceType>('all_filter');
  const [currentPage, setCurrentPage] = useState(1);
  const [total, setTotal] = useState(0);
  const [totalPages, setTotalPages] = useState(1);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [pendingAction, setPendingAction] = useState<{ type: 'publish' | 'delete'; notification: Notification } | null>(null);

  const notificationsPerPage = paginationConfig?.perPage ?? 10;
  const filters = useMemo<NotificationFilters>(
    () => ({
      keyword,
      status: status === 'all' ? undefined : status,
      type: type === 'all' ? undefined : type,
      audience: audience === 'all_filter' ? undefined : audience,
      ordering: '-created_at',
      page: currentPage,
      pageSize: notificationsPerPage,
    }),
    [audience, currentPage, keyword, notificationsPerPage, status, type]
  );

  const loadData = useCallback(async () => {
    try {
      setIsLoading(true);
      setError(null);
      const [notificationsResponse, notificationStats, config] = await Promise.all([
        getNotificationsPage(filters),
        getNotificationStats(),
        getNotificationPaginationConfig(),
      ]);
      setNotifications(notificationsResponse.notifications);
      setStats(notificationStats);
      setPaginationConfig(config);
      setTotal(notificationsResponse.total);
      setTotalPages(notificationsResponse.totalPages);
    } catch (loadError) {
      setError(loadError instanceof Error ? loadError.message : 'Không thể tải danh sách thông báo.');
    } finally {
      setIsLoading(false);
    }
  }, [filters]);

  const hasActiveFilters =
    keyword.trim() !== '' ||
    status !== 'all' ||
    type !== 'all' ||
    audience !== 'all_filter';

  const handleRefreshFilters = () => {
    if (!hasActiveFilters) {
      void loadData();
      return;
    }

    setKeyword('');
    setStatus('all');
    setType('all');
    setAudience('all_filter');
    setCurrentPage(1);
  };

  useEffect(() => {
    void loadData();
  }, [loadData]);

  useEffect(() => {
    setCurrentPage(1);
  }, [audience, keyword, status, type]);

  const handleExport = async (format: NotificationExportFormat) => {
    const formatLabel = format === 'xlsx' ? 'Excel' : 'CSV';
    await runActionWithToast(() => exportNotificationsHistory(filters, format), {
      loading: `Đang xuất lịch sử thông báo sang ${formatLabel}...`,
      success: `Đã tải file lịch sử thông báo ${formatLabel}.`,
      error: `Không thể xuất lịch sử thông báo ${formatLabel}.`,
    });
  };

  const handleConfirmAction = async () => {
    if (!pendingAction) return;

    if (pendingAction.type === 'publish') {
      await runActionWithToast(async () => {
        await publishNotificationById(pendingAction.notification.id);
        await loadData();
      }, {
        loading: 'Đang gửi thông báo...',
        success: 'Đã gửi thông báo.',
        error: 'Không thể gửi thông báo.',
      });
    }

    if (pendingAction.type === 'delete') {
      await runActionWithToast(async () => {
        await deleteNotificationById(pendingAction.notification.id);
        await loadData();
      }, {
        loading: 'Đang xóa thông báo...',
        success: 'Đã xóa thông báo.',
        error: 'Không thể xóa thông báo.',
      });
    }

    setPendingAction(null);
  };

  const firstVisible = total === 0 ? 0 : (currentPage - 1) * notificationsPerPage + 1;
  const lastVisible = Math.min(currentPage * notificationsPerPage, total);
  const pageNumbers = buildVisiblePages(currentPage, totalPages, paginationConfig?.maxVisiblePages ?? 5);

  return (
    <div className="mx-auto flex w-full max-w-7xl flex-col gap-6 pb-24">
      <div className="flex flex-col gap-4 lg:flex-row lg:items-end lg:justify-between">
        <div className="min-w-0">
          <h1 className="text-2xl font-bold tracking-tight text-on-surface">
            Quản lý thông báo
          </h1>
          <p className="mt-1 max-w-2xl text-sm font-medium text-on-surface-variant">
            Tạo, lên lịch, gửi và xuất lịch sử thông báo bằng API thật.
          </p>
        </div>
        <div className="flex flex-col gap-2 sm:flex-row">
          <Button
            variant="secondary"
            onClick={() => {
              void handleExport('csv');
            }}
            leftIcon={<Download className="h-4 w-4" />}
          >
            Xuất CSV
          </Button>
          <Button
            variant="secondary"
            onClick={() => {
              void handleExport('xlsx');
            }}
            leftIcon={<FileSpreadsheet className="h-4 w-4" />}
          >
            Xuất Excel
          </Button>
          <Link href="/notifications/create">
            <Button variant="primary" leftIcon={<Plus className="h-4 w-4" />}>
              Tạo thông báo
            </Button>
          </Link>
        </div>
      </div>

      <div className="grid gap-3 sm:grid-cols-2 xl:grid-cols-4">
        <NotificationStatCard label="Đã gửi" value={stats?.totalSent ?? 0} />
        <NotificationStatCard label="Tỷ lệ mở TB" value={`${stats?.avgOpenRate ?? 0}%`} />
        <NotificationStatCard label="Đã lên lịch" value={stats?.scheduled ?? 0} />
        <NotificationStatCard label="Người dùng hoạt động" value={stats?.activeUsers ?? 0} />
      </div>

      <Card className="relative z-30 border border-white/70 bg-white/80 p-4 shadow-sm backdrop-blur-xl sm:p-5">
        <div className="grid gap-3 xl:grid-cols-[minmax(16rem,1fr)_11rem_11rem_12rem_auto]">
          <label className="relative block">
            <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-slate-400" />
            <input
              value={keyword}
              onChange={(event) => setKeyword(event.target.value)}
              className="h-11 w-full rounded-xl border border-slate-200 bg-white pl-10 pr-3 text-sm font-medium text-slate-800 outline-none transition focus:border-amber-500 focus:ring-4 focus:ring-amber-500/10"
              placeholder="Tìm theo tiêu đề, nội dung hoặc người tạo"
            />
          </label>
          <AdminSelect value={status} onChange={setStatus} options={statusOptions} ariaLabel="Lọc trạng thái thông báo" />
          <AdminSelect value={type} onChange={setType} options={typeOptions} ariaLabel="Lọc loại thông báo" />
          <AdminSelect value={audience} onChange={setAudience} options={audienceOptions} ariaLabel="Lọc đối tượng nhận" />
          <button
            type="button"
            onClick={handleRefreshFilters}
            className="inline-flex h-11 items-center justify-center gap-2 rounded-xl border border-slate-200 bg-white px-4 text-sm font-bold text-slate-700 transition hover:border-amber-300 hover:bg-amber-50 hover:text-amber-700"
            title="Làm mới bộ lọc"
          >
            <RotateCcw className="h-4 w-4" />
            <span className="xl:sr-only 2xl:not-sr-only">Làm mới</span>
          </button>
        </div>
      </Card>

      {error ? (
        <ErrorState
          title="Không thể tải thông báo"
          message={error}
          retryLabel="Tải lại"
          onRetry={() => {
            void loadData();
          }}
        />
      ) : null}

      {!error ? (
        <Card className="overflow-hidden border border-white/70 bg-white/75 shadow-sm backdrop-blur-xl">
          <div className="flex flex-col gap-3 border-b border-slate-100 px-4 py-4 sm:px-6 md:flex-row md:items-center md:justify-between">
            <div>
              <p className="text-xs font-bold uppercase tracking-widest text-slate-500">Lịch sử thông báo</p>
              <p className="mt-1 text-sm text-slate-600">
                Hiển thị {firstVisible}-{lastVisible} trong {total.toLocaleString('vi-VN')} thông báo
              </p>
            </div>
            <p className="text-sm font-bold text-slate-600">Trang {currentPage}/{totalPages}</p>
          </div>

          {isLoading ? (
            <div className="grid gap-3 p-4 sm:p-6">
              {Array.from({ length: 4 }).map((_, index) => (
                <div key={index} className="h-32 animate-pulse rounded-2xl bg-slate-100" />
              ))}
            </div>
          ) : notifications.length === 0 ? (
            <EmptyState
              title="Không có thông báo phù hợp"
              description="Thử đổi bộ lọc hoặc tạo thông báo mới."
              className="m-4 bg-white/70 sm:m-6"
            />
          ) : (
            <div className="divide-y divide-slate-100">
              {notifications.map((notification) => (
                <NotificationRow
                  key={notification.id}
                  notification={notification}
                  detailHref={`/notifications/${notification.id}`}
                  editHref={`/notifications/create?notificationId=${notification.id}`}
                  onPublish={() => setPendingAction({ type: 'publish', notification })}
                  onDelete={() => setPendingAction({ type: 'delete', notification })}
                />
              ))}
            </div>
          )}

          <div className="flex flex-col gap-3 border-t border-slate-100 px-4 py-4 sm:px-6 md:flex-row md:items-center md:justify-between">
            <p className="text-xs font-medium text-slate-500">Danh sách và thống kê được lấy từ backend admin.</p>
            <div className="flex flex-wrap gap-2">
              <PageButton disabled={currentPage === 1} onClick={() => setCurrentPage((page) => Math.max(1, page - 1))}>
                <ChevronLeft className="h-4 w-4" />
              </PageButton>
              {pageNumbers.map((pageNumber) => (
                <PageButton
                  key={pageNumber}
                  active={pageNumber === currentPage}
                  onClick={() => setCurrentPage(pageNumber)}
                >
                  {pageNumber}
                </PageButton>
              ))}
              <PageButton
                disabled={currentPage >= totalPages}
                onClick={() => setCurrentPage((page) => Math.min(totalPages, page + 1))}
              >
                <ChevronRight className="h-4 w-4" />
              </PageButton>
            </div>
          </div>
        </Card>
      ) : null}

      <ConfirmActionDialog
        open={pendingAction !== null}
        onOpenChange={(open) => {
          if (!open) setPendingAction(null);
        }}
        title={pendingAction?.type === 'publish' ? 'Xác nhận gửi thông báo' : 'Xác nhận xóa thông báo'}
        description={
          pendingAction?.type === 'publish'
            ? `Thông báo "${pendingAction.notification.title}" sẽ được gửi tới nhóm người nhận đã chọn.`
            : `Thông báo "${pendingAction?.notification.title ?? ''}" sẽ bị xóa nếu trạng thái backend cho phép.`
        }
        confirmLabel="Xác nhận"
        cancelLabel="Hủy"
        variant={pendingAction?.type === 'delete' ? 'danger' : 'default'}
        onConfirm={() => {
          void handleConfirmAction();
        }}
      />
    </div>
  );
}

function NotificationStatCard({ label, value }: { label: string; value: string | number }) {
  return (
    <Card className="border border-white/70 bg-white/80 p-5 shadow-sm backdrop-blur-xl">
      <p className="text-[10px] font-bold uppercase tracking-widest text-slate-500">{label}</p>
      <p className="mt-3 text-2xl font-black text-slate-950">
        {typeof value === 'number' ? value.toLocaleString('vi-VN') : value}
      </p>
    </Card>
  );
}

function NotificationRow({
  notification,
  onPublish,
  onDelete,
  detailHref,
  editHref,
}: {
  notification: Notification;
  onPublish: () => void;
  onDelete: () => void;
  detailHref: string;
  editHref: string;
}) {
  const type = notificationTypeConfig[notification.type];
  const status = notificationStatusConfig[notification.status];
  const audience = notificationAudienceConfig[notification.audience];
  const TypeIcon = type.icon;
  const sentDate = notification.sentAt || notification.scheduledAt;

  return (
    <article className="grid gap-4 px-4 py-5 transition hover:bg-white/80 sm:px-6 xl:grid-cols-[minmax(0,1fr)_12rem_10rem_11rem] xl:items-center">
      <div className="min-w-0">
        <div className="flex items-start gap-3">
          <div className={cn('flex h-11 w-11 shrink-0 items-center justify-center rounded-2xl', type.bg)}>
            <TypeIcon className={cn('h-5 w-5', type.color)} />
          </div>
          <div className="min-w-0">
            <div className="flex flex-wrap items-center gap-2">
              <h2 className="min-w-0 truncate text-base font-bold text-on-surface">{notification.title}</h2>
              <span className="text-xs font-bold text-slate-500">{type.label}</span>
            </div>
            <p className="mt-1 line-clamp-2 text-sm text-slate-600">{notification.message}</p>
            <p className="mt-2 text-xs text-slate-500">Tạo bởi {notification.createdBy}</p>
          </div>
        </div>
      </div>

      <div className="flex flex-wrap gap-2 xl:block xl:space-y-2">
        <span className={cn('inline-flex rounded-full px-2.5 py-1 text-[11px] font-bold', audience.bg, audience.color)}>
          {audience.label}
        </span>
        <p className="text-sm font-bold text-slate-700">{notification.recipientCount.toLocaleString('vi-VN')} người nhận</p>
      </div>

      <div>
        {sentDate ? (
          <>
            <p className="text-sm font-bold text-slate-800">
              {new Intl.DateTimeFormat('vi-VN', { dateStyle: 'medium' }).format(new Date(sentDate))}
            </p>
            <p className="text-xs text-slate-500">
              {new Intl.DateTimeFormat('vi-VN', { timeStyle: 'short' }).format(new Date(sentDate))}
            </p>
          </>
        ) : (
          <p className="text-sm font-medium text-slate-400">Chưa đặt lịch</p>
        )}
      </div>

      <div className="flex flex-wrap items-center gap-2 xl:justify-end">
        <span className={cn('inline-flex items-center gap-1.5 rounded-full px-3 py-1 text-[11px] font-bold', status.bg, status.color)}>
          <span className={cn('h-1.5 w-1.5 rounded-full', status.dotColor)} />
          {status.label}
        </span>
        <Link
          href={detailHref}
          className="inline-flex h-9 w-9 items-center justify-center rounded-xl border border-slate-200 bg-white text-slate-600 transition hover:border-blue-300 hover:bg-blue-50 hover:text-blue-700"
          title="Xem chi tiết thông báo"
        >
          <Eye className="h-4 w-4" />
        </Link>
        {notification.status !== 'sent' ? (
          <button
            type="button"
            onClick={onPublish}
            className="inline-flex h-9 items-center justify-center rounded-xl bg-amber-500 px-3 text-xs font-bold text-white transition hover:bg-amber-600"
          >
            Gửi
          </button>
        ) : null}
        {notification.status === 'draft' || notification.status === 'scheduled' ? (
          <>
            <Link
              href={editHref}
              className="inline-flex h-9 w-9 items-center justify-center rounded-xl border border-slate-200 bg-white text-slate-600 transition hover:border-amber-300 hover:bg-amber-50 hover:text-amber-700"
              title="Chỉnh sửa thông báo"
            >
              <Pencil className="h-4 w-4" />
            </Link>
            <button
              type="button"
              onClick={onDelete}
              className="inline-flex h-9 w-9 items-center justify-center rounded-xl border border-red-100 bg-red-50 text-red-600 transition hover:bg-red-100"
              title="Xóa thông báo"
            >
              <Trash2 className="h-4 w-4" />
            </button>
          </>
        ) : null}
      </div>
    </article>
  );
}

function PageButton({
  children,
  active = false,
  disabled = false,
  onClick,
}: {
  children: ReactNode;
  active?: boolean;
  disabled?: boolean;
  onClick: () => void;
}) {
  return (
    <button
      type="button"
      disabled={disabled}
      onClick={onClick}
      className={cn(
        'flex h-9 min-w-9 items-center justify-center rounded-xl border px-3 text-sm font-bold transition',
        active ? 'border-amber-500 bg-amber-500 text-white' : 'border-slate-200 bg-white text-slate-600 hover:border-amber-300',
        disabled && 'cursor-not-allowed opacity-50'
      )}
    >
      {children}
    </button>
  );
}

function buildVisiblePages(currentPage: number, totalPages: number, maxVisiblePages: number): number[] {
  const windowSize = Math.max(1, maxVisiblePages);
  const start = Math.max(1, Math.min(currentPage - Math.floor(windowSize / 2), totalPages - windowSize + 1));
  const end = Math.min(totalPages, start + windowSize - 1);
  return Array.from({ length: end - start + 1 }, (_, index) => start + index);
}
