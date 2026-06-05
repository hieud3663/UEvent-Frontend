'use client';

import { use, useCallback, useEffect, useState } from 'react';
import type { ReactNode } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { ArrowLeft, Calendar, Pencil, Send, Trash2, Users } from 'lucide-react';
import { Card, ConfirmActionDialog, ErrorState } from '@/core/components';
import { cn } from '@/core/lib/utils';
import { runActionWithToast } from '@/core/lib/runActionWithToast';
import {
  deleteNotificationById,
  getNotificationById,
  publishNotificationById,
} from '@/features/notifications/services/notifications.service';
import type { AudienceType, Notification, NotificationStatus, NotificationType } from '@/features/notifications/types';

const typeLabels: Record<NotificationType, string> = {
  announcement: 'Thông báo',
  alert: 'Cảnh báo',
  reminder: 'Nhắc lịch',
  promotion: 'Ưu đãi',
  invite: 'Lời mời',
  ticket_confirm: 'Xác nhận vé',
  registration_confirmed: 'Đăng ký được xác nhận',
  registration_waitlisted: 'Danh sách chờ',
  new_registration: 'Đăng ký mới',
  organizer_announcement: 'Thông báo nhà tổ chức',
  question_answered: 'Câu hỏi đã trả lời',
};

const audienceLabels: Record<AudienceType, string> = {
  all: 'Tất cả người dùng',
  students: 'Sinh viên',
  organizers: 'Nhà tổ chức',
  admins: 'Quản trị viên',
  custom: 'Tùy chọn',
};

const statusConfig: Record<NotificationStatus, { label: string; className: string }> = {
  draft: { label: 'Bản nháp', className: 'bg-slate-100 text-slate-700' },
  scheduled: { label: 'Đã lên lịch', className: 'bg-amber-100 text-amber-700' },
  sent: { label: 'Đã gửi', className: 'bg-emerald-100 text-emerald-700' },
  failed: { label: 'Thất bại', className: 'bg-red-100 text-red-700' },
};

interface PageProps {
  params: Promise<{ id: string }>;
}

export default function NotificationDetailPage({ params }: PageProps) {
  const resolvedParams = use(params);
  const router = useRouter();
  const [notification, setNotification] = useState<Notification | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [pendingAction, setPendingAction] = useState<'publish' | 'delete' | null>(null);

  const loadNotification = useCallback(async () => {
    try {
      setIsLoading(true);
      setError(null);
      const currentNotification = await getNotificationById(resolvedParams.id);
      setNotification(currentNotification);
    } catch (loadError) {
      setError(loadError instanceof Error ? loadError.message : 'Không thể tải chi tiết thông báo.');
    } finally {
      setIsLoading(false);
    }
  }, [resolvedParams.id]);

  useEffect(() => {
    void loadNotification();
  }, [loadNotification]);

  const handleConfirmAction = async () => {
    if (!notification || !pendingAction) return;

    if (pendingAction === 'publish') {
      await runActionWithToast(async () => {
        const updatedNotification = await publishNotificationById(notification.id);
        setNotification(updatedNotification);
      }, {
        loading: 'Đang gửi thông báo...',
        success: 'Đã gửi thông báo.',
        error: 'Không thể gửi thông báo.',
      });
    }

    if (pendingAction === 'delete') {
      await runActionWithToast(async () => {
        await deleteNotificationById(notification.id);
        router.push('/notifications');
      }, {
        loading: 'Đang xóa thông báo...',
        success: 'Đã xóa thông báo.',
        error: 'Không thể xóa thông báo.',
      });
    }

    setPendingAction(null);
  };

  if (isLoading) {
    return <div className="p-6 text-sm text-slate-500">Đang tải chi tiết thông báo...</div>;
  }

  if (error || !notification) {
    return (
      <ErrorState
        title="Không thể tải thông báo"
        message={error ?? 'Thông báo không tồn tại hoặc đã bị xóa.'}
        retryLabel="Tải lại"
        onRetry={() => {
          void loadNotification();
        }}
      />
    );
  }

  const status = statusConfig[notification.status];
  const isEditable = notification.status === 'draft' || notification.status === 'scheduled';
  const sentDate = notification.sentAt || notification.scheduledAt;
  const performance = notification.performance ?? {
    recipientCount: notification.recipientCount,
    sentCount: 0,
    readCount: 0,
    failedCount: 0,
    reachPercentage: 0,
    openRate: 0,
  };

  return (
    <div className="mx-auto flex w-full max-w-6xl flex-col gap-6 pb-24">
      <div className="flex flex-col gap-4 lg:flex-row lg:items-start lg:justify-between">
        <div className="min-w-0">
          <Link href="/notifications" className="mb-3 inline-flex items-center gap-2 text-sm font-bold text-slate-500 hover:text-amber-600">
            <ArrowLeft className="h-4 w-4" />
            Quay lại danh sách
          </Link>
          <div className="flex flex-wrap items-center gap-2">
            <span className={cn('rounded-full px-3 py-1 text-xs font-bold', status.className)}>{status.label}</span>
            <span className="rounded-full bg-blue-50 px-3 py-1 text-xs font-bold text-blue-700">
              {typeLabels[notification.type] ?? 'Loại khác'}
            </span>
          </div>
          <h1 className="mt-3 text-2xl font-bold tracking-tight text-on-surface">{notification.title}</h1>
          <p className="mt-2 max-w-3xl text-sm leading-relaxed text-slate-600">{notification.message}</p>
        </div>

        <div className="flex flex-wrap gap-2">
          {isEditable ? (
            <>
              <button
                type="button"
                onClick={() => setPendingAction('publish')}
                className="inline-flex h-11 items-center justify-center gap-2 rounded-xl bg-amber-500 px-4 text-sm font-bold text-white transition hover:bg-amber-600"
              >
                <Send className="h-4 w-4" />
                Gửi thủ công
              </button>
              <Link
                href={`/notifications/create?notificationId=${notification.id}`}
                className="inline-flex h-11 items-center justify-center gap-2 rounded-xl border border-slate-200 bg-white px-4 text-sm font-bold text-slate-700 transition hover:border-amber-300 hover:bg-amber-50"
              >
                <Pencil className="h-4 w-4" />
                Chỉnh sửa
              </Link>
              <button
                type="button"
                onClick={() => setPendingAction('delete')}
                className="inline-flex h-11 items-center justify-center gap-2 rounded-xl border border-red-100 bg-red-50 px-4 text-sm font-bold text-red-600 transition hover:bg-red-100"
              >
                <Trash2 className="h-4 w-4" />
                Xóa
              </button>
            </>
          ) : null}
        </div>
      </div>

      <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
        <MetricCard label="Người nhận" value={performance.recipientCount} />
        <MetricCard label="Đã gửi" value={performance.sentCount} />
        <MetricCard label="Đã đọc" value={performance.readCount} />
        <MetricCard label="Thất bại" value={performance.failedCount} />
      </div>

      <div className="grid gap-6 lg:grid-cols-[minmax(0,1fr)_22rem]">
        <Card className="border border-white/70 bg-white/80 p-5 shadow-sm backdrop-blur-xl">
          <h2 className="text-xs font-bold uppercase tracking-widest text-slate-500">Hiệu quả gửi</h2>
          <div className="mt-5 space-y-5">
            <ProgressRow label="Tỷ lệ tiếp cận" value={performance.reachPercentage} />
            <ProgressRow label="Tỷ lệ mở" value={performance.openRate} />
          </div>
        </Card>

        <Card className="border border-white/70 bg-white/80 p-5 shadow-sm backdrop-blur-xl">
          <h2 className="text-xs font-bold uppercase tracking-widest text-slate-500">Thông tin gửi</h2>
          <div className="mt-5 space-y-4">
            <InfoRow icon={<Users className="h-4 w-4" />} label="Đối tượng" value={audienceLabels[notification.audience]} />
            <InfoRow icon={<Calendar className="h-4 w-4" />} label={notification.sentAt ? 'Đã gửi lúc' : 'Lịch gửi'} value={sentDate ? formatDateTime(sentDate) : 'Chưa đặt lịch'} />
            <InfoRow label="Người tạo" value={notification.createdBy} />
            <InfoRow label="Ngày tạo" value={formatDateTime(notification.createdAt)} />
          </div>
        </Card>
      </div>

      <ConfirmActionDialog
        open={pendingAction !== null}
        onOpenChange={(open) => {
          if (!open) setPendingAction(null);
        }}
        title={pendingAction === 'publish' ? 'Xác nhận gửi thông báo' : 'Xác nhận xóa thông báo'}
        description={
          pendingAction === 'publish'
            ? 'Thông báo sẽ được gửi ngay tới nhóm người nhận đã chọn. Lịch gửi tự động vẫn được giữ cho các thông báo chưa gửi.'
            : 'Thông báo bản nháp hoặc đã lên lịch sẽ bị xóa khỏi hệ thống.'
        }
        confirmLabel="Xác nhận"
        cancelLabel="Hủy"
        variant={pendingAction === 'delete' ? 'danger' : 'default'}
        onConfirm={() => {
          void handleConfirmAction();
        }}
      />
    </div>
  );
}

function MetricCard({ label, value }: { label: string; value: number }) {
  return (
    <Card className="border border-white/70 bg-white/80 p-5 shadow-sm backdrop-blur-xl">
      <p className="text-[10px] font-bold uppercase tracking-widest text-slate-500">{label}</p>
      <p className="mt-3 text-2xl font-black text-slate-950">{value.toLocaleString('vi-VN')}</p>
    </Card>
  );
}

function ProgressRow({ label, value }: { label: string; value: number }) {
  const boundedValue = Math.max(0, Math.min(100, value));

  return (
    <div>
      <div className="mb-2 flex items-center justify-between gap-3">
        <p className="text-sm font-bold text-slate-700">{label}</p>
        <p className="text-sm font-bold text-slate-950">{boundedValue.toLocaleString('vi-VN')}%</p>
      </div>
      <div className="h-3 overflow-hidden rounded-full bg-slate-100">
        <div className="h-full rounded-full bg-amber-500" style={{ width: `${boundedValue}%` }} />
      </div>
    </div>
  );
}

function InfoRow({ icon, label, value }: { icon?: ReactNode; label: string; value: string }) {
  return (
    <div>
      <p className="flex items-center gap-2 text-xs font-bold uppercase tracking-widest text-slate-400">
        {icon}
        {label}
      </p>
      <p className="mt-1 text-sm font-bold text-slate-900">{value}</p>
    </div>
  );
}

function formatDateTime(value: string): string {
  return new Intl.DateTimeFormat('vi-VN', {
    dateStyle: 'medium',
    timeStyle: 'short',
  }).format(new Date(value));
}
