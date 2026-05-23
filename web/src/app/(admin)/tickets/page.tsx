'use client';

import type { ReactNode } from 'react';
import { Suspense, useCallback, useEffect, useState } from 'react';
import Link from 'next/link';
import { useSearchParams } from 'next/navigation';
import { CalendarDays, CheckCircle2, Download, MapPin, QrCode, RefreshCw, Search, Ticket as TicketIcon, X, XCircle } from 'lucide-react';
import { AdminSelect, Button, Card, ConfirmActionDialog, EmptyState, ErrorState, ListSkeleton } from '@/core/components';
import { cn } from '@/core/lib/utils';
import { runActionWithToast } from '@/core/lib/runActionWithToast';
import { getEventsPage } from '@/features/events/services/events.service';
import type { Event } from '@/features/events/types';
import {
  cancelTicketById,
  downloadExportFile,
  exportTickets,
  getTicketStats,
  getTickets,
  scanTicket,
} from '@/features/tickets/services/tickets.service';
import type { TicketExportFormat } from '@/features/tickets/services/tickets.service';
import type { Ticket, TicketFilters, TicketScanResult, TicketStats, TicketStatus } from '@/features/tickets/types';

const STATUS_OPTIONS: Array<{ value: TicketStatus | 'all'; label: string }> = [
  { value: 'all', label: 'Tất cả trạng thái' },
  { value: 'valid', label: 'Còn hiệu lực' },
  { value: 'used', label: 'Đã check-in' },
  { value: 'cancelled', label: 'Đã hủy' },
  { value: 'expired', label: 'Hết hạn' },
];

const statusDisplay: Record<TicketStatus, { label: string; className: string }> = {
  valid: { label: 'Còn hiệu lực', className: 'bg-emerald-50 text-emerald-700 whitespace-nowrap' },
  used: { label: 'Đã check-in', className: 'bg-blue-50 text-blue-700 whitespace-nowrap' },
  cancelled: { label: 'Đã hủy', className: 'bg-red-50 text-red-700 whitespace-nowrap' },
  expired: { label: 'Hết hạn', className: 'bg-slate-100 text-slate-600 whitespace-nowrap' },
};

const DEFAULT_CANCEL_REASON = 'Hủy bởi quản trị viên.';

interface ScanEventOption {
  id: string;
  title: string;
  startAt?: string;
  endAt?: string;
  location?: string | null;
  status?: string;
  organizer?: string;
}

export default function TicketsPage() {
  return (
    <Suspense fallback={<ListSkeleton rows={8} />}>
      <TicketsPageContent />
    </Suspense>
  );
}

function TicketsPageContent() {
  const searchParams = useSearchParams();
  const [tickets, setTickets] = useState<Ticket[]>([]);
  const [stats, setStats] = useState<TicketStats | null>(null);
  const [filters, setFilters] = useState<TicketFilters>({
    status: 'all',
    search: searchParams.get('search') ?? '',
    page: 1,
    pageSize: 20,
  });
  const [selectedScanEvent, setSelectedScanEvent] = useState<ScanEventOption | null>(null);
  const [isEventPickerOpen, setIsEventPickerOpen] = useState(false);
  const [scanTicketCode, setScanTicketCode] = useState('');
  const [scanNote, setScanNote] = useState('');
  const [scanResult, setScanResult] = useState<TicketScanResult | null>(null);
  const [cancelReasons, setCancelReasons] = useState<Record<string, string>>({});
  const [pendingCancelTicket, setPendingCancelTicket] = useState<Ticket | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [isLoadingInitialEvent, setIsLoadingInitialEvent] = useState(true);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  const loadData = useCallback(async () => {
    if (!filters.eventId) {
      setTickets([]);
      setIsLoading(false);
      return;
    }

    setIsLoading(true);
    setErrorMessage(null);

    try {
      const [ticketResult, ticketStats] = await Promise.all([getTickets(filters), getTicketStats()]);
      setTickets(ticketResult.tickets);
      setStats(ticketStats);
    } catch (error) {
      setErrorMessage(error instanceof Error ? error.message : 'Không thể tải danh sách vé.');
    } finally {
      setIsLoading(false);
    }
  }, [filters]);

  useEffect(() => {
    void loadData();
  }, [loadData]);

  useEffect(() => {
    let isCurrent = true;

    async function loadInitialEvent() {
      setIsLoadingInitialEvent(true);

      try {
        const response = await getEventsPage({
          page: 1,
          pageSize: 1,
          ordering: '-start_at',
        });
        const firstEvent = response.events[0];

        if (!isCurrent || !firstEvent) return;

        const nextEvent = mapEventToScanOption(firstEvent);
        setSelectedScanEvent(nextEvent);
        setFilters((current) => ({ ...current, eventId: nextEvent.id }));
      } catch (error) {
        if (isCurrent) {
          setErrorMessage(error instanceof Error ? error.message : 'Không thể tải sự kiện để lọc vé.');
        }
      } finally {
        if (isCurrent) {
          setIsLoadingInitialEvent(false);
        }
      }
    }

    void loadInitialEvent();

    return () => {
      isCurrent = false;
    };
  }, []);

  const updateFilter = (next: Partial<TicketFilters>) => {
    setFilters((current) => ({ ...current, ...next, page: next.page ?? 1 }));
  };

  const handleSelectEvent = (event: Event) => {
    const nextEvent = mapEventToScanOption(event);
    setSelectedScanEvent(nextEvent);
    setFilters((current) => ({ ...current, eventId: nextEvent.id, page: 1 }));
    setScanResult(null);
    setIsEventPickerOpen(false);
  };

  const handleExport = async (format: TicketExportFormat) => {
    const formatLabel = format === 'xlsx' ? 'Excel' : 'CSV';
    const result = await runActionWithToast(() => exportTickets(filters, format), {
      loading: `Đang xuất vé ${formatLabel}...`,
      success: `File vé ${formatLabel} đã sẵn sàng.`,
      error: `Không thể xuất vé ${formatLabel}.`,
    });
    downloadExportFile(result);
  };

  const requestCancel = (ticket: Ticket) => {
    if (!cancelReasons[ticket.id]?.trim()) {
      setCancelReasons((current) => ({ ...current, [ticket.id]: DEFAULT_CANCEL_REASON }));
    }
    setPendingCancelTicket(ticket);
  };

  const handleCancel = async (ticket: Ticket) => {
    const reason = cancelReasons[ticket.id]?.trim() || DEFAULT_CANCEL_REASON;
    if (!reason) {
      return;
    }

    await runActionWithToast(() => cancelTicketById(ticket.id, reason), {
      loading: `Đang hủy vé ${ticket.ticketCode}...`,
      success: `Đã hủy vé ${ticket.ticketCode}.`,
      error: `Không thể hủy vé ${ticket.ticketCode}.`,
    });
    setPendingCancelTicket(null);
    await loadData();
  };

  const handleScan = async () => {
    const ticketCode = scanTicketCode.trim();
    if (!selectedScanEvent || !ticketCode) return;

    const result = await runActionWithToast(
      () => scanTicket({ eventId: selectedScanEvent.id, ticketCode, note: scanNote.trim() || undefined }),
      {
        loading: 'Đang xử lý check-in...',
        success: 'Đã ghi nhận lượt quét check-in.',
        error: 'Không thể xử lý check-in.',
      }
    );
    setScanResult(result);
    setScanTicketCode('');
    await loadData();
  };

  if ((isLoadingInitialEvent || isLoading) && tickets.length === 0) {
    return <ListSkeleton rows={8} />;
  }

  if (errorMessage && tickets.length === 0) {
    return (
      <ErrorState
        title="Không thể tải vé"
        message={errorMessage}
        retryLabel="Tải lại"
        onRetry={() => {
          void loadData();
        }}
      />
    );
  }

  return (
    <div className="space-y-8">
      <div className="flex flex-col gap-4 md:flex-row md:items-end md:justify-between">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-on-surface">Quản lý vé và check-in</h1>
          <p className="mt-1 text-sm font-medium text-on-surface-variant">
            Theo dõi vé, hủy vé, quét check-in và xuất dữ liệu đăng ký.
          </p>
        </div>
        <div className="flex flex-wrap gap-2">
          <Button
            variant="secondary"
            onClick={() => {
              void loadData();
            }}
            leftIcon={<RefreshCw className="h-4 w-4" />}
          >
            Làm mới
          </Button>
          <Button
            variant="secondary"
            onClick={() => {
              void handleExport('csv');
            }}
            leftIcon={<Download className="h-4 w-4" />}
          >
            CSV
          </Button>
          <Button
            variant="secondary"
            onClick={() => {
              void handleExport('xlsx');
            }}
          >
            Excel
          </Button>
        </div>
      </div>

      <div className="grid grid-cols-1 gap-4 md:grid-cols-4 whitespace-nowrap">
        <StatsCard label="Tổng vé" value={stats?.totalTickets ?? 0} icon={<TicketIcon className="h-5 w-5" />} />
        <StatsCard label="Còn hiệu lực" value={stats?.validTickets ?? 0} icon={<CheckCircle2 className="h-5 w-5" />} />
        <StatsCard label="Check-in hôm nay" value={stats?.checkinsToday ?? 0} icon={<QrCode className="h-5 w-5" />} />
        <StatsCard label="Tỷ lệ check-in" value={`${(stats?.checkinRate ?? 0).toFixed(1)}%`} icon={<CheckCircle2 className="h-5 w-5" />} />
      </div>

      <Card className="relative z-30 border border-white/70 bg-white/80 p-5 shadow-sm backdrop-blur-xl">
        <div className="grid gap-4 lg:grid-cols-[minmax(18rem,1.15fr)_1fr_0.75fr_auto] lg:items-end">
          <label className="block">
            <span className="mb-2 block text-xs font-bold uppercase tracking-widest text-slate-500">Sự kiện</span>
            <button
              type="button"
              onClick={() => setIsEventPickerOpen(true)}
              className="flex h-11 w-full items-center justify-between gap-3 rounded-xl border border-slate-200 bg-white px-4 text-left outline-none transition hover:border-amber-300 focus:border-amber-500 focus:ring-4 focus:ring-amber-500/10"
            >
              <span className="min-w-0">
                <span className={cn('block truncate text-sm font-bold', selectedScanEvent ? 'text-slate-900' : 'text-slate-400')}>
                  {selectedScanEvent?.title ?? 'Chọn sự kiện'}
                </span>
                {selectedScanEvent?.startAt ? (
                  <span className="mt-0.5 block truncate text-xs font-medium text-slate-500">
                    {formatDateTime(selectedScanEvent.startAt)}
                  </span>
                ) : null}
              </span>
              <Search className="h-4 w-4 shrink-0 text-slate-400" />
            </button>
          </label>
          <label className="block">
            <span className="mb-2 block text-xs font-bold uppercase tracking-widest text-slate-500">Tìm kiếm</span>
            <div className="relative">
              <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-slate-400" />
              <input
                value={filters.search ?? ''}
                onChange={(event) => updateFilter({ search: event.target.value })}
                className="h-11 w-full rounded-xl border border-slate-200 bg-white pl-10 pr-4 text-sm font-medium outline-none transition focus:border-amber-500 focus:ring-4 focus:ring-amber-500/10"
                placeholder="Mã vé, email, người dùng..."
              />
            </div>
          </label>
          <label className="block">
            <span className="mb-2 block text-xs font-bold uppercase tracking-widest text-slate-500">Trạng thái</span>
            <AdminSelect
              value={filters.status ?? 'all'}
              onChange={(value) => updateFilter({ status: value as TicketFilters['status'] })}
              options={STATUS_OPTIONS}
              ariaLabel="Lọc trạng thái vé"
            />
          </label>
          <Button
            variant="secondary"
            onClick={() => updateFilter({ status: 'all', search: '' })}
          >
            Xóa lọc
          </Button>
        </div>
      </Card>

      <Card className="relative z-10 border border-white/70 bg-white/80 p-5 shadow-sm backdrop-blur-xl">
        <div className="mb-4 flex items-center gap-3">
          <QrCode className="h-5 w-5 text-amber-500" />
          <div>
            <h2 className="text-lg font-bold text-slate-900">Quét check-in</h2>
            <p className="text-sm text-slate-500">Check-in theo sự kiện đang chọn trong bộ lọc vé.</p>
          </div>
        </div>
        <div className="grid gap-3 lg:grid-cols-[minmax(18rem,1.2fr)_1fr_1fr_auto]">
          <button
            type="button"
            onClick={() => setIsEventPickerOpen(true)}
            className="flex min-h-11 items-center justify-between gap-3 rounded-xl border border-slate-200 bg-white px-4 py-2 text-left outline-none transition hover:border-amber-300 focus:border-amber-500 focus:ring-4 focus:ring-amber-500/10"
          >
            <span className="min-w-0">
              <span className={cn('block truncate text-sm font-bold', selectedScanEvent ? 'text-slate-900' : 'text-slate-400')}>
                {selectedScanEvent?.title ?? 'Chọn sự kiện trước'}
              </span>
              {selectedScanEvent?.startAt ? (
                <span className="mt-0.5 block truncate text-xs font-medium text-slate-500">
                  {formatDateTime(selectedScanEvent.startAt)}
                  {selectedScanEvent.location ? ` · ${selectedScanEvent.location}` : ''}
                </span>
              ) : null}
            </span>
            <Search className="h-4 w-4 shrink-0 text-slate-400" />
          </button>
          <input
            value={scanTicketCode}
            onChange={(event) => setScanTicketCode(event.target.value)}
            className="h-11 rounded-xl border border-slate-200 bg-white px-4 text-sm font-medium outline-none transition focus:border-amber-500 focus:ring-4 focus:ring-amber-500/10"
            placeholder="Mã vé"
          />
          <input
            value={scanNote}
            onChange={(event) => setScanNote(event.target.value)}
            className="h-11 rounded-xl border border-slate-200 bg-white px-4 text-sm font-medium outline-none transition focus:border-amber-500 focus:ring-4 focus:ring-amber-500/10"
            placeholder="Ghi chú"
          />
          <Button
            onClick={() => {
              void handleScan();
            }}
            disabled={!selectedScanEvent || !scanTicketCode.trim()}
            leftIcon={<QrCode className="h-4 w-4" />}
          >
            Check-in
          </Button>
        </div>
        {scanResult ? (
          <div className="mt-4 rounded-2xl border border-emerald-100 bg-emerald-50 px-4 py-3 text-sm font-bold text-emerald-700">
            Kết quả: {translateScanResult(scanResult.result)}
          </div>
        ) : null}
      </Card>

      <Card className="overflow-hidden border border-white/70 bg-white/75 shadow-sm backdrop-blur-xl">
        {!selectedScanEvent ? (
          <EmptyState title="Chọn sự kiện để xem vé" description="Danh sách vé luôn được lọc theo một sự kiện cụ thể." className="m-6 bg-white/70" />
        ) : tickets.length === 0 ? (
          <EmptyState title="Chưa có vé phù hợp" description="Không có vé nào khớp bộ lọc hiện tại." className="m-6 bg-white/70" />
        ) : (
          <div className="overflow-x-auto">
            <table className="min-w-[980px] w-full border-collapse text-left">
              <thead>
                <tr className="border-b border-slate-100 bg-slate-50/60">
                  <th className="px-6 py-4 text-[10px] font-bold uppercase tracking-widest text-slate-400">Vé</th>
                  <th className="px-6 py-4 text-[10px] font-bold uppercase tracking-widest text-slate-400">Sự kiện</th>
                  <th className="px-6 py-4 text-[10px] font-bold uppercase tracking-widest text-slate-400">Người dùng</th>
                  <th className="px-6 py-4 text-[10px] font-bold uppercase tracking-widest text-slate-400">Trạng thái</th>
                  <th className="px-6 py-4 text-[10px] font-bold uppercase tracking-widest text-slate-400">Hủy vé</th>
                  <th className="px-6 py-4 text-right text-[10px] font-bold uppercase tracking-widest text-slate-400">Thao tác</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {tickets.map((ticket) => (
                  <TicketRow
                    key={ticket.id}
                    ticket={ticket}
                    cancelReason={cancelReasons[ticket.id] ?? ''}
                    onReasonChange={(value) => setCancelReasons((current) => ({ ...current, [ticket.id]: value }))}
                    onCancel={() => {
                      requestCancel(ticket);
                    }}
                  />
                ))}
              </tbody>
            </table>
          </div>
        )}
      </Card>

      <EventSelectionDialog
        open={isEventPickerOpen}
        selectedEventId={selectedScanEvent?.id}
        onOpenChange={setIsEventPickerOpen}
        onSelect={handleSelectEvent}
      />

      <ConfirmActionDialog
        open={pendingCancelTicket !== null}
        onOpenChange={(open) => {
          if (!open) setPendingCancelTicket(null);
        }}
        title="Xác nhận hủy vé"
        description={
          pendingCancelTicket
            ? `Bạn sắp hủy vé ${pendingCancelTicket.ticketCode} của ${pendingCancelTicket.user.fullName}. Lý do: ${
                cancelReasons[pendingCancelTicket.id]?.trim() || DEFAULT_CANCEL_REASON
              }`
            : ''
        }
        confirmLabel="Hủy vé"
        cancelLabel="Giữ vé"
        variant="danger"
        onConfirm={() => {
          if (pendingCancelTicket) {
            void handleCancel(pendingCancelTicket);
          }
        }}
      />
    </div>
  );
}

function StatsCard({ label, value, icon }: { label: string; value: number | string; icon: ReactNode }) {
  return (
    <Card className="border border-white/70 bg-white/80 p-5 shadow-sm backdrop-blur-xl">
      <div className="flex items-start justify-between">
        <p className="text-[10px] font-bold uppercase tracking-widest text-slate-500">{label}</p>
        <span className="rounded-xl bg-amber-100 p-2 text-amber-600">{icon}</span>
      </div>
      <p className="mt-4 text-2xl font-black text-slate-900">{typeof value === 'number' ? value.toLocaleString('vi-VN') : value}</p>
    </Card>
  );
}

function EventSelectionDialog({
  open,
  selectedEventId,
  onOpenChange,
  onSelect,
}: {
  open: boolean;
  selectedEventId?: string;
  onOpenChange: (open: boolean) => void;
  onSelect: (event: Event) => void;
}) {
  const [search, setSearch] = useState('');
  const [events, setEvents] = useState<Event[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  useEffect(() => {
    if (!open) return;

    let isCurrent = true;
    const timeoutId = window.setTimeout(async () => {
      setIsLoading(true);
      setErrorMessage(null);

      try {
        const response = await getEventsPage({
          keyword: search,
          page: 1,
          pageSize: 8,
          ordering: '-start_at',
        });
        if (isCurrent) {
          setEvents(response.events);
        }
      } catch (error) {
        if (isCurrent) {
          setErrorMessage(error instanceof Error ? error.message : 'Không thể tải danh sách sự kiện.');
        }
      } finally {
        if (isCurrent) {
          setIsLoading(false);
        }
      }
    }, 250);

    return () => {
      isCurrent = false;
      window.clearTimeout(timeoutId);
    };
  }, [open, search]);

  if (!open) return null;

  return (
    <div className="fixed inset-0 z-[100]">
      <button
        type="button"
        aria-label="Đóng chọn sự kiện"
        className="absolute inset-0 cursor-default bg-slate-950/40 backdrop-blur-sm"
        onClick={() => onOpenChange(false)}
      />
      <div
        role="dialog"
        aria-modal="true"
        aria-labelledby="event-selection-title"
        className="absolute left-1/2 top-1/2 z-[101] flex max-h-[86vh] w-[92vw] max-w-2xl -translate-x-1/2 -translate-y-1/2 flex-col rounded-3xl border border-white/40 bg-white p-6 shadow-2xl"
      >
        <div className="flex items-start justify-between gap-4">
          <div>
            <h2 id="event-selection-title" className="text-lg font-bold tracking-tight text-slate-900">
              Chọn sự kiện
            </h2>
            <p className="mt-1 text-sm text-slate-500">Bảng vé và check-in sẽ dùng sự kiện được chọn.</p>
          </div>
          <button
            type="button"
            onClick={() => onOpenChange(false)}
            className="inline-flex h-9 w-9 shrink-0 items-center justify-center rounded-xl text-slate-500 transition hover:bg-slate-100 hover:text-slate-900"
            aria-label="Đóng"
          >
            <X className="h-4 w-4" />
          </button>
        </div>

        <div className="relative mt-5">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-slate-400" />
          <input
            value={search}
            onChange={(event) => setSearch(event.target.value)}
            className="h-11 w-full rounded-xl border border-slate-200 bg-white pl-10 pr-4 text-sm font-medium outline-none transition focus:border-amber-500 focus:ring-4 focus:ring-amber-500/10"
            placeholder="Tìm sự kiện..."
            autoFocus
          />
        </div>

        {isLoading && events.length > 0 ? (
          <p className="mt-3 text-xs font-semibold text-amber-600">Đang cập nhật kết quả...</p>
        ) : null}

        <div className="mt-4 min-h-0 flex-1 overflow-y-auto pr-1">
          {isLoading && events.length === 0 ? (
            <div className="rounded-2xl border border-slate-100 bg-slate-50 px-4 py-6 text-center text-sm font-semibold text-slate-500">
              Đang tải sự kiện...
            </div>
          ) : errorMessage ? (
            <div className="rounded-2xl border border-red-100 bg-red-50 px-4 py-6 text-center text-sm font-semibold text-red-600">
              {errorMessage}
            </div>
          ) : events.length === 0 ? (
            <div className="rounded-2xl border border-slate-100 bg-slate-50 px-4 py-6 text-center text-sm font-semibold text-slate-500">
              Không tìm thấy sự kiện phù hợp.
            </div>
          ) : (
            <div className="space-y-2">
              {events.map((event) => {
                const isSelected = event.id === selectedEventId;

                return (
                  <button
                    key={event.id}
                    type="button"
                    onClick={() => onSelect(event)}
                    className={cn(
                      'w-full rounded-2xl border px-4 py-3 text-left transition',
                      isSelected
                        ? 'border-amber-300 bg-amber-50 text-slate-950'
                        : 'border-slate-100 bg-white hover:border-amber-200 hover:bg-amber-50/60'
                    )}
                  >
                    <div className="flex items-start justify-between gap-3">
                      <div className="min-w-0">
                        <p className="truncate text-sm font-bold text-slate-900">{event.title}</p>
                        <p className="mt-1 truncate text-xs font-medium text-slate-500">{event.organizer}</p>
                      </div>
                      <span className="rounded-full bg-slate-100 px-2.5 py-1 text-[10px] font-bold uppercase tracking-wider text-slate-500">
                        {translateEventStatus(event.status)}
                      </span>
                    </div>
                    <div className="mt-3 flex flex-wrap gap-x-4 gap-y-1 text-xs font-medium text-slate-500">
                      {event.startAt ? (
                        <span className="inline-flex items-center gap-1">
                          <CalendarDays className="h-3.5 w-3.5" />
                          {formatDateTime(event.startAt)}
                        </span>
                      ) : null}
                      {event.location ? (
                        <span className="inline-flex min-w-0 items-center gap-1">
                          <MapPin className="h-3.5 w-3.5 shrink-0" />
                          <span className="truncate">{event.location}</span>
                        </span>
                      ) : null}
                    </div>
                  </button>
                );
              })}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

function TicketRow({
  ticket,
  cancelReason,
  onReasonChange,
  onCancel,
}: {
  ticket: Ticket;
  cancelReason: string;
  onReasonChange: (value: string) => void;
  onCancel: () => void;
}) {
  const status = statusDisplay[ticket.status];
  const canCancel = ticket.status === 'valid';

  return (
    <tr className="transition-colors hover:bg-amber-50/30">
      <td className="px-6 py-4">
        <p className="font-mono text-sm font-black text-slate-900">{ticket.ticketCode}</p>
        <p className="text-xs text-slate-500">Hết hạn: {formatDateTime(ticket.expiresAt)}</p>
      </td>
      <td className="px-6 py-4">
        <p className="line-clamp-1 text-sm font-bold text-slate-900">{ticket.event.title}</p>
        <p className="text-xs text-slate-500">{formatDateTime(ticket.event.startAt)}</p>
      </td>
      <td className="px-6 py-4">
        <p className="text-sm font-bold text-slate-900">{ticket.user.fullName}</p>
        <p className="text-xs text-slate-500">{ticket.user.email}</p>
      </td>
      <td className="px-6 py-4">
        <span className={cn('rounded-full px-2.5 py-1 text-[10px] font-bold uppercase tracking-wider', status.className)}>
          {status.label}
        </span>
      </td>
      <td className="px-6 py-4">
        {canCancel ? (
          <div className="flex min-w-[18rem] gap-2">
            <input
              value={cancelReason}
              onChange={(event) => onReasonChange(event.target.value)}
              className="h-10 min-w-0 flex-1 rounded-xl border border-slate-200 bg-white px-3 text-sm outline-none transition focus:border-red-400 focus:ring-4 focus:ring-red-500/10"
              placeholder="Lý do hủy"
            />
            <button
              type="button"
              onClick={onCancel}
              className="inline-flex h-10 items-center gap-1 rounded-xl bg-red-50 px-3 text-xs font-bold text-red-600 transition hover:bg-red-500 hover:text-white"
            >
              <XCircle className="h-4 w-4" />
              Hủy
            </button>
          </div>
        ) : (
          <span className="text-xs font-medium text-slate-400">Không khả dụng</span>
        )}
      </td>
      <td className="px-6 py-4 text-right">
        <Link href={`/tickets/${ticket.id}`} className="text-sm font-bold text-amber-600 hover:text-amber-700">
          Chi tiết
        </Link>
      </td>
    </tr>
  );
}

function formatDateTime(value: string): string {
  return new Intl.DateTimeFormat('vi-VN', { dateStyle: 'short', timeStyle: 'short' }).format(new Date(value));
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

function mapEventToScanOption(event: Event): ScanEventOption {
  return {
    id: event.id,
    title: event.title,
    startAt: event.startAt,
    endAt: event.endAt,
    location: event.location,
    status: event.status,
    organizer: event.organizer,
  };
}

function translateEventStatus(status: Event['status']): string {
  const labels: Record<Event['status'], string> = {
    draft: 'Nháp',
    pending: 'Chờ duyệt',
    approved: 'Đã duyệt',
    active: 'Đang mở',
    finished: 'Đã kết thúc',
    cancelled: 'Đã hủy',
    rejected: 'Từ chối',
    archived: 'Lưu trữ',
  };

  return labels[status];
}
