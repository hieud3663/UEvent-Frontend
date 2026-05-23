'use client';

import type { ReactNode } from 'react';
import { useEffect, useState } from 'react';
import Link from 'next/link';
import { useParams } from 'next/navigation';
import { ArrowLeft, CheckCircle2, Ticket as TicketIcon } from 'lucide-react';
import { Card, EmptyState, ErrorState, ListSkeleton } from '@/core/components';
import { cn } from '@/core/lib/utils';
import { getTicketById } from '@/features/tickets/services/tickets.service';
import type { Ticket, TicketStatus } from '@/features/tickets/types';

const statusDisplay: Record<TicketStatus, { label: string; className: string }> = {
  valid: { label: 'Còn hiệu lực', className: 'bg-emerald-50 text-emerald-700' },
  used: { label: 'Đã check-in', className: 'bg-blue-50 text-blue-700' },
  cancelled: { label: 'Đã hủy', className: 'bg-red-50 text-red-700' },
  expired: { label: 'Hết hạn', className: 'bg-slate-100 text-slate-600' },
};

export default function TicketDetailPage() {
  const params = useParams<{ id: string }>();
  const [ticket, setTicket] = useState<Ticket | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  useEffect(() => {
    let mounted = true;

    getTicketById(params.id)
      .then((result) => {
        if (mounted) setTicket(result);
      })
      .catch((error) => {
        if (mounted) setErrorMessage(error instanceof Error ? error.message : 'Không thể tải chi tiết vé.');
      })
      .finally(() => {
        if (mounted) setIsLoading(false);
      });

    return () => {
      mounted = false;
    };
  }, [params.id]);

  if (isLoading) return <ListSkeleton rows={6} />;

  if (errorMessage) {
    return <ErrorState title="Không thể tải chi tiết vé" message={errorMessage} />;
  }

  if (!ticket) {
    return <EmptyState title="Không tìm thấy vé" description="Vé không tồn tại hoặc đã bị xóa." />;
  }

  const status = statusDisplay[ticket.status];

  return (
    <div className="space-y-6">
      <Link href="/tickets" className="inline-flex items-center gap-2 text-sm font-bold text-slate-600 hover:text-amber-600">
        <ArrowLeft className="h-4 w-4" />
        Quay lại danh sách vé
      </Link>

      <div className="flex flex-col gap-4 md:flex-row md:items-end md:justify-between">
        <div>
          <p className="text-xs font-bold uppercase tracking-widest text-amber-600">Chi tiết vé</p>
          <h1 className="mt-1 text-2xl font-black text-slate-900">{ticket.ticketCode}</h1>
        </div>
        <span className={cn('w-fit rounded-full px-3 py-1 text-xs font-bold uppercase tracking-wider', status.className)}>
          {status.label}
        </span>
      </div>

      <div className="grid gap-5 lg:grid-cols-3">
        <InfoCard title="Sự kiện">
          <p className="text-lg font-bold text-slate-900">{ticket.event.title}</p>
          <p className="mt-2 text-sm text-slate-500">Bắt đầu: {formatDateTime(ticket.event.startAt)}</p>
          <p className="text-sm text-slate-500">Kết thúc: {formatDateTime(ticket.event.endAt)}</p>
          {ticket.event.locationSnapshot ? <p className="mt-2 text-sm text-slate-600">{ticket.event.locationSnapshot}</p> : null}
        </InfoCard>

        <InfoCard title="Người dùng">
          <p className="text-lg font-bold text-slate-900">{ticket.user.fullName}</p>
          <p className="mt-2 text-sm text-slate-500">{ticket.user.email}</p>
          <p className="text-sm text-slate-500">{ticket.user.studentCode || ticket.user.username}</p>
        </InfoCard>

        <InfoCard title="Đăng ký">
          <p className="text-sm text-slate-500">Trạng thái: {ticket.registration.status}</p>
          <p className="mt-2 text-sm text-slate-500">Đăng ký: {formatDateTime(ticket.registration.registeredAt)}</p>
          {ticket.registration.cancelReason ? <p className="mt-2 text-sm text-red-600">{ticket.registration.cancelReason}</p> : null}
        </InfoCard>
      </div>

      <Card className="overflow-hidden border border-white/70 bg-white/75 shadow-sm backdrop-blur-xl">
        <div className="border-b border-slate-100 px-5 py-4">
          <div className="flex items-center gap-3">
            <TicketIcon className="h-5 w-5 text-amber-500" />
            <h2 className="text-lg font-bold text-slate-900">Lịch sử check-in</h2>
          </div>
        </div>
        {ticket.checkins.length === 0 ? (
          <EmptyState title="Chưa có lượt check-in" description="Vé này chưa được quét." className="m-5 bg-white/70" />
        ) : (
          <div className="divide-y divide-slate-100">
            {ticket.checkins.map((log) => (
              <div key={log.id} className="flex flex-col gap-2 px-5 py-4 sm:flex-row sm:items-center sm:justify-between">
                <div className="flex items-center gap-3">
                  <span className="rounded-full bg-emerald-50 p-2 text-emerald-600">
                    <CheckCircle2 className="h-4 w-4" />
                  </span>
                  <div>
                    <p className="text-sm font-bold text-slate-900">{translateScanResult(log.result)}</p>
                    <p className="text-xs text-slate-500">{log.note || 'Không có ghi chú'}</p>
                  </div>
                </div>
                <p className="text-sm font-medium text-slate-500">{formatDateTime(log.checkedInAt)}</p>
              </div>
            ))}
          </div>
        )}
      </Card>
    </div>
  );
}

function InfoCard({ title, children }: { title: string; children: ReactNode }) {
  return (
    <Card className="border border-white/70 bg-white/80 p-5 shadow-sm backdrop-blur-xl">
      <p className="mb-3 text-xs font-bold uppercase tracking-widest text-slate-500">{title}</p>
      {children}
    </Card>
  );
}

function formatDateTime(value: string): string {
  return new Intl.DateTimeFormat('vi-VN', {
    hour: '2-digit',
    minute: '2-digit',
    day: 'numeric',
    month: 'numeric',
    year: 'numeric',
    hour12: false,
  }).format(new Date(value));
}

function translateScanResult(result: string): string {
  const labels: Record<string, string> = {
    success: 'Thành công',
    invalid_format: 'QR không hợp lệ',
    invalid_ticket: 'Vé không hợp lệ',
    already_checked_in: 'Đã check-in trước đó',
    event_unavailable: 'Sự kiện chưa sẵn sàng',
  };
  return labels[result] ?? result;
}
