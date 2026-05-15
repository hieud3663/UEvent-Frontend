'use client';

import { useCallback, useEffect, useMemo, useState } from 'react';
import type { ReactNode } from 'react';
import Link from 'next/link';
import { ChevronLeft, ChevronRight, Clock3, Filter, MessageSquareReply, RotateCcw, Search, ShieldAlert } from 'lucide-react';
import { AdminSelect, Card, EmptyState, ErrorState } from '@/core/components';
import {
  getSupportStats,
  getTicketsPage,
  type TicketFilters,
} from '@/features/support/services/support.service';
import { cn } from '@/core/lib/utils';
import type { SupportStats, Ticket, TicketCategory, TicketPriority, TicketStatus } from '@/features/support/types';

const supportStatusConfig: Record<TicketStatus, { label: string; className: string }> = {
  open: { label: 'Đang chờ', className: 'bg-amber-100 text-amber-700' },
  in_progress: { label: 'Đang xử lý', className: 'bg-blue-100 text-blue-700' },
  resolved: { label: 'Đã xử lý', className: 'bg-emerald-100 text-emerald-700' },
  closed: { label: 'Đã đóng', className: 'bg-slate-100 text-slate-700' },
};

const supportPriorityConfig: Record<TicketPriority, { label: string; className: string }> = {
  low: { label: 'Thấp', className: 'text-slate-600' },
  medium: { label: 'Trung bình', className: 'text-blue-600' },
  high: { label: 'Cao', className: 'text-red-500' },
  urgent: { label: 'Khẩn cấp', className: 'text-red-600' },
};

const categoryOptions = [
  { value: 'all', label: 'Tất cả nhóm' },
  { value: 'account', label: 'Tài khoản' },
  { value: 'event', label: 'Sự kiện' },
  { value: 'payment', label: 'Thanh toán' },
  { value: 'technical', label: 'Kỹ thuật' },
  { value: 'other', label: 'Khác' },
] as const;

const statusOptions = [
  { value: 'all', label: 'Tất cả trạng thái' },
  { value: 'open', label: 'Đang chờ' },
  { value: 'in_progress', label: 'Đang xử lý' },
  { value: 'resolved', label: 'Đã xử lý' },
  { value: 'closed', label: 'Đã đóng' },
] as const;

const priorityOptions = [
  { value: 'all', label: 'Mọi độ ưu tiên' },
  { value: 'urgent', label: 'Khẩn cấp' },
  { value: 'high', label: 'Cao' },
  { value: 'medium', label: 'Trung bình' },
  { value: 'low', label: 'Thấp' },
] as const;

const pageSize = 8;

export default function SupportPage() {
  const [tickets, setTickets] = useState<Ticket[]>([]);
  const [stats, setStats] = useState<SupportStats | null>(null);
  const [keyword, setKeyword] = useState('');
  const [status, setStatus] = useState<'all' | TicketStatus>('all');
  const [priority, setPriority] = useState<'all' | TicketPriority>('all');
  const [category, setCategory] = useState<'all' | TicketCategory>('all');
  const [currentPage, setCurrentPage] = useState(1);
  const [total, setTotal] = useState(0);
  const [totalPages, setTotalPages] = useState(1);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const filters = useMemo<TicketFilters>(
    () => ({
      keyword,
      status: status === 'all' ? undefined : status,
      priority: priority === 'all' ? undefined : priority,
      category: category === 'all' ? undefined : category,
      ordering: '-updated_at',
      page: currentPage,
      pageSize,
    }),
    [category, currentPage, keyword, priority, status]
  );

  const loadData = useCallback(async () => {
    try {
      setIsLoading(true);
      setError(null);
      const [ticketsResponse, supportStats] = await Promise.all([
        getTicketsPage(filters),
        getSupportStats(),
      ]);
      setTickets(ticketsResponse.tickets);
      setTotal(ticketsResponse.total);
      setTotalPages(ticketsResponse.totalPages);
      setStats(supportStats);
    } catch (loadError) {
      setError(loadError instanceof Error ? loadError.message : 'Không thể tải danh sách hỗ trợ.');
    } finally {
      setIsLoading(false);
    }
  }, [filters]);

  const hasActiveFilters =
    keyword.trim() !== '' ||
    status !== 'all' ||
    priority !== 'all' ||
    category !== 'all';

  const handleRefreshFilters = () => {
    if (!hasActiveFilters) {
      void loadData();
      return;
    }

    setKeyword('');
    setStatus('all');
    setPriority('all');
    setCategory('all');
    setCurrentPage(1);
  };

  useEffect(() => {
    void loadData();
  }, [loadData]);

  useEffect(() => {
    setCurrentPage(1);
  }, [category, keyword, priority, status]);

  const firstVisible = total === 0 ? 0 : (currentPage - 1) * pageSize + 1;
  const lastVisible = Math.min(currentPage * pageSize, total);
  const pageNumbers = buildVisiblePages(currentPage, totalPages);

  return (
    <div className="mx-auto flex w-full max-w-7xl flex-col gap-6 pb-24">
      <div className="flex flex-col gap-4 lg:flex-row lg:items-end lg:justify-between">
        <div className="min-w-0">
          <h1 className="text-2xl font-bold tracking-tight text-on-surface">
            Hỗ trợ người dùng
          </h1>
          <p className="mt-1 max-w-2xl text-sm font-medium text-on-surface-variant">
            Theo dõi, phân loại và xử lý ticket hỗ trợ bằng dữ liệu thật từ hệ thống.
          </p>
        </div>
      </div>

      <div className="grid gap-3 sm:grid-cols-2 xl:grid-cols-4">
        <SupportStatCard label="Đang chờ" value={stats?.openTickets ?? 0} icon={ShieldAlert} />
        <SupportStatCard label="Đang xử lý" value={stats?.inProgress ?? 0} icon={MessageSquareReply} />
        <SupportStatCard label="Đã xử lý hôm nay" value={stats?.resolvedToday ?? 0} icon={Clock3} />
        <SupportStatCard label="Phản hồi trung bình" value={stats?.avgResponseTime ?? '0 phút'} icon={Filter} />
      </div>

      <Card className="relative z-30 border border-white/70 bg-white/80 p-4 shadow-sm backdrop-blur-xl sm:p-5">
        <div className="grid gap-3 lg:grid-cols-[minmax(16rem,1fr)_11rem_11rem_11rem_auto]">
          <label className="relative block">
            <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-slate-400" />
            <input
              value={keyword}
              onChange={(event) => setKeyword(event.target.value)}
              className="h-11 w-full rounded-xl border border-slate-200 bg-white pl-10 pr-3 text-sm font-medium text-slate-800 outline-none transition focus:border-amber-500 focus:ring-4 focus:ring-amber-500/10"
              placeholder="Tìm theo tiêu đề, mô tả hoặc email"
            />
          </label>
          <AdminSelect value={status} onChange={setStatus} options={statusOptions} ariaLabel="Lọc trạng thái ticket" />
          <AdminSelect value={priority} onChange={setPriority} options={priorityOptions} ariaLabel="Lọc độ ưu tiên ticket" />
          <AdminSelect value={category} onChange={setCategory} options={categoryOptions} ariaLabel="Lọc nhóm ticket" />
          <button
            type="button"
            onClick={handleRefreshFilters}
            className="inline-flex h-11 items-center justify-center gap-2 rounded-xl border border-slate-200 bg-white px-4 text-sm font-bold text-slate-700 transition hover:border-amber-300 hover:bg-amber-50 hover:text-amber-700"
            title="Làm mới bộ lọc"
          >
            <RotateCcw className="h-4 w-4" />
            <span className="lg:sr-only xl:not-sr-only">Làm mới</span>
          </button>
        </div>
      </Card>

      {error ? (
        <ErrorState
          title="Không thể tải ticket hỗ trợ"
          message={error}
          retryLabel="Tải lại"
          onRetry={() => {
            void loadData();
          }}
        />
      ) : null}

      {!error ? (
        <Card className="relative z-0 overflow-hidden border border-white/70 bg-white/75 shadow-sm backdrop-blur-xl">
          <div className="flex flex-col gap-3 border-b border-slate-100 px-4 py-4 sm:px-6 md:flex-row md:items-center md:justify-between">
            <div>
              <p className="text-xs font-bold uppercase tracking-widest text-slate-500">Danh sách ticket</p>
              <p className="mt-1 text-sm text-slate-600">
                Hiển thị {firstVisible}-{lastVisible} trong {total.toLocaleString('vi-VN')} ticket
              </p>
            </div>
            <p className="text-sm font-bold text-slate-600">Trang {currentPage}/{totalPages}</p>
          </div>

          {isLoading ? (
            <div className="grid gap-3 p-4 sm:p-6">
              {Array.from({ length: 4 }).map((_, index) => (
                <div key={index} className="h-28 animate-pulse rounded-2xl bg-slate-100" />
              ))}
            </div>
          ) : tickets.length === 0 ? (
            <EmptyState
              title="Không có ticket phù hợp"
              description="Thử đổi bộ lọc hoặc từ khóa tìm kiếm để xem thêm yêu cầu hỗ trợ."
              className="m-4 bg-white/70 sm:m-6"
            />
          ) : (
            <div className="divide-y divide-slate-100">
              {tickets.map((ticket) => (
                <TicketRow key={ticket.id} ticket={ticket} />
              ))}
            </div>
          )}

          <div className="flex flex-col gap-3 border-t border-slate-100 px-4 py-4 sm:px-6 md:flex-row md:items-center md:justify-between">
            <p className="text-xs font-medium text-slate-500">
              Dữ liệu được phân trang từ API, không dùng danh sách mẫu.
            </p>
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
    </div>
  );
}

function SupportStatCard({
  label,
  value,
  icon: Icon,
}: {
  label: string;
  value: string | number;
  icon: typeof Clock3;
}) {
  return (
    <Card className="border border-white/70 bg-white/80 p-5 shadow-sm backdrop-blur-xl">
      <div className="flex items-start justify-between gap-4">
        <div>
          <p className="text-[10px] font-bold uppercase tracking-widest text-slate-500">{label}</p>
          <p className="mt-3 text-2xl font-black text-slate-950">{typeof value === 'number' ? value.toLocaleString('vi-VN') : value}</p>
        </div>
        <span className="rounded-2xl bg-amber-100 p-3 text-amber-600">
          <Icon className="h-5 w-5" />
        </span>
      </div>
    </Card>
  );
}

function TicketRow({ ticket }: { ticket: Ticket }) {
  const status = supportStatusConfig[ticket.status];
  const priority = supportPriorityConfig[ticket.priority];
  const preview = ticket.messages[0]?.content || ticket.description;

  return (
    <article className="grid gap-4 px-4 py-5 transition hover:bg-white/80 sm:px-6 lg:grid-cols-[minmax(0,1fr)_13rem_8rem] lg:items-center">
      <div className="min-w-0">
        <div className="flex flex-wrap items-center gap-2">
          <h2 className="min-w-0 truncate text-base font-bold text-on-surface">{ticket.subject}</h2>
          <span className={cn('rounded-full px-2.5 py-1 text-[11px] font-bold', status.className)}>
            {status.label}
          </span>
        </div>
        <p className="mt-2 line-clamp-2 text-sm text-slate-600">{preview}</p>
        <div className="mt-3 flex flex-wrap items-center gap-x-4 gap-y-1 text-xs text-slate-500">
          <span className="font-semibold text-slate-700">{ticket.userName}</span>
          <span>{ticket.userEmail}</span>
          <span>{new Intl.DateTimeFormat('vi-VN', { dateStyle: 'medium', timeStyle: 'short' }).format(new Date(ticket.createdAt))}</span>
        </div>
      </div>

      <div className="flex flex-wrap gap-2 lg:block lg:space-y-2">
        <p className={cn('text-sm font-bold', priority.className)}>Ưu tiên: {priority.label}</p>
        <p className="text-sm text-slate-600">Nhóm: {translateCategory(ticket.category)}</p>
        <p className="text-sm text-slate-600">Phụ trách: {ticket.assignedTo || 'Chưa gán'}</p>
      </div>

      <Link
        href={`/support/${ticket.id}`}
        className="inline-flex h-10 items-center justify-center rounded-xl bg-amber-500 px-4 text-sm font-bold text-white shadow-sm transition hover:bg-amber-600"
      >
        Xử lý
      </Link>
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

function buildVisiblePages(currentPage: number, totalPages: number): number[] {
  const start = Math.max(1, Math.min(currentPage - 2, totalPages - 4));
  const end = Math.min(totalPages, start + 4);
  return Array.from({ length: end - start + 1 }, (_, index) => start + index);
}

function translateCategory(category: TicketCategory): string {
  const labels: Record<TicketCategory, string> = {
    account: 'Tài khoản',
    event: 'Sự kiện',
    payment: 'Thanh toán',
    technical: 'Kỹ thuật',
    other: 'Khác',
  };
  return labels[category];
}
