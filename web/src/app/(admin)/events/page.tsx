// File: src/app/(admin)/events/page.tsx
'use client';

import { useCallback, useEffect, useState } from 'react';
import type { ElementType, FormEvent } from 'react';
import {
  Calendar,
  CheckCircle,
  ChevronLeft,
  ChevronRight,
  Filter,
  Flag,
  MoreHorizontal,
  RotateCw,
  Search,
  TrendingDown,
  User,
  XCircle,
} from 'lucide-react';
import { Card, ConfirmActionDialog, EmptyState, ErrorState, ListSkeleton } from '@/core/components';
import {
  deleteEventById,
  getEventsPage,
  getEventModerationActivities,
  getEventModerationPulse,
  getEventPolicyHandbook,
  getEventStats,
  moderateEventStatus,
} from '@/features/events/services/events.service';
import { getCategories } from '@/features/categories/services/categories.service';
import type {
  Event,
  EventListResult,
  EventModerationActivity,
  EventModerationPulse,
  EventPolicyHandbook,
  ReportType,
} from '@/features/events/types';
import type { Category } from '@/features/categories/types';
import Image from 'next/image';
import Link from 'next/link';
import { runActionWithToast } from '@/core/lib/runActionWithToast';

const reportTypeLabels: Record<NonNullable<ReportType>, string> = {
  safety: 'Vấn đề an toàn',
  copyright: 'Khiếu nại bản quyền',
  spam: 'Báo cáo spam',
  other: 'Vấn đề khác',
};

const moderationActivityTypeConfig: Record<
  EventModerationActivity['type'],
  { icon: ElementType; iconColor: string; iconBg: string }
> = {
  approved: { icon: CheckCircle, iconColor: 'text-green-600', iconBg: 'bg-green-100' },
  declined: { icon: XCircle, iconColor: 'text-error', iconBg: 'bg-error/10' },
  flagged: { icon: Flag, iconColor: 'text-blue-600', iconBg: 'bg-blue-100' },
};

const EVENTS_PER_PAGE = 6;
const MAX_VISIBLE_PAGES = 7;

type EventStatusFilter = 'all' | 'reported' | 'pending' | 'approved' | 'active' | 'rejected' | 'cancelled' | 'archived';
type EventOrdering = '-start_at' | 'start_at' | '-created_at' | 'created_at' | 'status' | '-status';
type ModerationActionType = 'approve' | 'decline' | 'cancel' | 'archive' | 'reopen' | 'delete';
type PaginationItem = number | 'ellipsis-start' | 'ellipsis-end';

const EVENT_STATUS_OPTIONS: Array<{ value: EventStatusFilter; label: string }> = [
  { value: 'all', label: 'Tất cả' },
  { value: 'reported', label: 'Bị báo cáo' },
  { value: 'pending', label: 'Chờ duyệt' },
  { value: 'approved', label: 'Đã duyệt' },
  { value: 'active', label: 'Đang diễn ra' },
  { value: 'rejected', label: 'Từ chối' },
  { value: 'cancelled', label: 'Đã hủy' },
  { value: 'archived', label: 'Lưu trữ' },
];

export default function EventsPage() {
  const [events, setEvents] = useState<Event[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [pagination, setPagination] = useState<Omit<EventListResult, 'events'> | null>(null);
  const [stats, setStats] = useState<Awaited<ReturnType<typeof getEventStats>> | null>(null);
  const [moderationPulse, setModerationPulse] = useState<EventModerationPulse | null>(null);
  const [moderationActivities, setModerationActivities] = useState<EventModerationActivity[]>([]);
  const [policyHandbook, setPolicyHandbook] = useState<EventPolicyHandbook | null>(null);
  const [isContextLoading, setIsContextLoading] = useState(true);
  const [isEventsLoading, setIsEventsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [pendingModerationAction, setPendingModerationAction] = useState<
    { type: ModerationActionType; eventId: string; title: string } | null
  >(null);
  const [currentPage, setCurrentPage] = useState(1);
  const [keyword, setKeyword] = useState('');
  const [submittedKeyword, setSubmittedKeyword] = useState('');
  const [statusFilter, setStatusFilter] = useState<EventStatusFilter>('all');
  const [categoryFilter, setCategoryFilter] = useState('');
  const [visibilityFilter, setVisibilityFilter] = useState<'all' | 'public' | 'private'>('all');
  const [ordering, setOrdering] = useState<EventOrdering>('-start_at');

  const loadEventContextData = useCallback(async () => {
    try {
      setIsContextLoading(true);
      setError(null);
      const [eventsStats, pulse, activities, handbook, categoriesResponse] = await Promise.all([
        getEventStats(),
        getEventModerationPulse(),
        getEventModerationActivities(),
        getEventPolicyHandbook(),
        getCategories({ pageSize: 100 }),
      ]);

      setStats(eventsStats);
      setModerationPulse(pulse);
      setModerationActivities(activities);
      setPolicyHandbook(handbook);
      setCategories(categoriesResponse);
    } catch (loadError) {
      setError(loadError instanceof Error ? loadError.message : 'Không thể tải dữ liệu tổng quan sự kiện.');
    } finally {
      setIsContextLoading(false);
    }
  }, []);

  const loadEventsPageData = useCallback(async () => {
    try {
      setIsEventsLoading(true);
      setError(null);
      const eventsResponse = await getEventsPage({
        keyword: submittedKeyword,
        status: statusFilter === 'all' ? undefined : statusFilter,
        category: categoryFilter || undefined,
        visibility: visibilityFilter === 'all' ? undefined : visibilityFilter,
        ordering,
        page: currentPage,
        pageSize: EVENTS_PER_PAGE,
      });

      setEvents(eventsResponse.events);
      setPagination({
        total: eventsResponse.total,
        page: eventsResponse.page,
        pageSize: eventsResponse.pageSize,
        totalPages: eventsResponse.totalPages,
      });
    } catch (loadError) {
      setError(loadError instanceof Error ? loadError.message : 'Không thể tải sự kiện.');
    } finally {
      setIsEventsLoading(false);
    }
  }, [categoryFilter, currentPage, ordering, statusFilter, submittedKeyword, visibilityFilter]);

  const refreshEventsDashboard = useCallback(async () => {
    await Promise.all([loadEventsPageData(), loadEventContextData()]);
  }, [loadEventContextData, loadEventsPageData]);

  useEffect(() => {
    void loadEventsPageData();
  }, [loadEventsPageData]);

  useEffect(() => {
    void loadEventContextData();
  }, [loadEventContextData]);

  const totalPages = pagination?.totalPages ?? 1;
  const safeCurrentPage = pagination?.page ?? currentPage;
  const totalEvents = pagination?.total ?? events.length;
  const reportedCount = stats?.urgentReports ?? 0;
  const pendingCount = stats?.pendingApproval ?? 0;
  const paginationItems = getPaginationItems(safeCurrentPage, totalPages);

  useEffect(() => {
    setCurrentPage((page) => Math.min(page, totalPages));
  }, [totalPages]);

  const handleModerateStatus = async (
    eventId: string,
    title: string,
    status: 'approved' | 'rejected' | 'cancelled' | 'archived' | 'active',
    reason: string
  ) => {
    const previousEvents = events;
    setEvents((prev) => prev.map((item) => (item.id === eventId ? { ...item, status } : item)));

    try {
      await runActionWithToast(() => moderateEventStatus(eventId, status, reason), {
        loading: `Đang cập nhật ${title}...`,
        success: `Đã cập nhật trạng thái sự kiện: ${title}`,
        error: `Không thể cập nhật ${title}.`,
      });
      await refreshEventsDashboard();
    } catch {
      setEvents(previousEvents);
    }
  };

  const handleDelete = async (eventId: string, title: string) => {
    const previousEvents = events;
    setEvents((prev) => prev.filter((item) => item.id !== eventId));

    try {
      await runActionWithToast(() => deleteEventById(eventId), {
        loading: `Đang xóa ${title}...`,
        success: `Đã xóa sự kiện: ${title}`,
        error: `Không thể xóa ${title}.`,
      });
      await refreshEventsDashboard();
    } catch {
      setEvents(previousEvents);
    }
  };

  const handleQuickAudit = async () => {
    await runActionWithToast(refreshEventsDashboard, {
      loading: 'Đang làm mới hàng đợi kiểm duyệt...',
      success: 'Đã làm mới hàng đợi kiểm duyệt.',
      error: 'Không thể làm mới hàng đợi kiểm duyệt.',
    });
  };

  const handleActionRequest = (type: ModerationActionType, eventId: string, title: string) => {
    setPendingModerationAction({ type, eventId, title });
  };

  const handleConfirmModeration = async () => {
    if (!pendingModerationAction) {
      return;
    }

    const currentAction = pendingModerationAction;
    setPendingModerationAction(null);

    if (currentAction.type === 'approve') {
      await handleModerateStatus(currentAction.eventId, currentAction.title, 'approved', 'Quản trị viên đã phê duyệt từ danh sách sự kiện.');
      return;
    }

    if (currentAction.type === 'delete') {
      await handleDelete(currentAction.eventId, currentAction.title);
      return;
    }

    if (currentAction.type === 'cancel') {
      await handleModerateStatus(currentAction.eventId, currentAction.title, 'cancelled', 'Quản trị viên đã hủy từ danh sách sự kiện.');
      return;
    }

    if (currentAction.type === 'archive') {
      await handleModerateStatus(currentAction.eventId, currentAction.title, 'archived', 'Quản trị viên đã lưu trữ từ danh sách sự kiện.');
      return;
    }

    if (currentAction.type === 'reopen') {
      await handleModerateStatus(currentAction.eventId, currentAction.title, 'active', 'Quản trị viên đã kích hoạt lại từ danh sách sự kiện.');
      return;
    }

    await handleModerateStatus(currentAction.eventId, currentAction.title, 'rejected', 'Quản trị viên đã từ chối từ danh sách sự kiện.');
  };

  const handleSearchSubmit = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    setCurrentPage(1);
    setSubmittedKeyword(keyword.trim());
  };

  const handleResetFilters = () => {
    setKeyword('');
    setSubmittedKeyword('');
    setStatusFilter('all');
    setCategoryFilter('');
    setVisibilityFilter('all');
    setOrdering('-start_at');
    setCurrentPage(1);
  };

  if ((isEventsLoading || isContextLoading) && !pagination) {
    return <ListSkeleton rows={8} />;
  }

  if (error) {
    return (
      <ErrorState
        title="Không thể tải sự kiện"
        message={error}
        onRetry={() => {
          void refreshEventsDashboard();
        }}
      />
    );
  }

  if (!stats || !moderationPulse || !policyHandbook) {
    return <ListSkeleton rows={8} />;
  }

  return (
    <div className="space-y-8">
      {/* Header Section */}
      <div className="flex justify-between items-end">
        <div>
          <h2 className="text-2xl font-bold tracking-tight text-on-surface">
            Quản lý sự kiện
          </h2>
          <p className="text-on-surface-variant text-sm mt-1">
            Theo dõi, lọc và xử lý toàn bộ sự kiện trong hệ thống.
          </p>
        </div>
        <div className="flex gap-2">
          <button 
            type="button"
            onClick={handleResetFilters}
            className="px-4 py-2 rounded-full glass-card text-xs font-bold uppercase tracking-wider flex items-center gap-2 border border-white/40"
          >
            <Filter className="w-4 h-4" />
            Xóa lọc
          </button>
          <button 
            type="button"
            onClick={() => {
              void handleQuickAudit();
            }}
            className="px-4 py-2 rounded-full bg-primary-container text-on-primary-container text-xs font-bold uppercase tracking-wider"
          >
            Kiểm tra nhanh
          </button>
        </div>
      </div>

      <form
        onSubmit={handleSearchSubmit}
        className="grid grid-cols-1 gap-3 rounded-2xl border border-white/60 bg-white/70 p-4 shadow-sm md:grid-cols-[minmax(0,1fr)_160px_180px_160px_190px_auto]"
      >
        <label className="relative">
          <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-slate-400" />
          <input
            value={keyword}
            onChange={(event) => setKeyword(event.target.value)}
            placeholder="Tìm theo tiêu đề, mô tả hoặc ban tổ chức"
            className="h-10 w-full rounded-xl border border-slate-200 bg-white pl-10 pr-3 text-sm text-slate-800 outline-none focus:border-amber-500 focus:ring-4 focus:ring-amber-500/10"
          />
        </label>
        <select
          value={statusFilter}
          onChange={(event) => {
            setStatusFilter(event.target.value as EventStatusFilter);
            setCurrentPage(1);
          }}
          className="h-10 rounded-xl border border-slate-200 bg-white px-3 text-sm font-medium text-slate-700 outline-none focus:border-amber-500"
        >
          {EVENT_STATUS_OPTIONS.map((option) => (
            <option key={option.value} value={option.value}>
              {option.label}
            </option>
          ))}
        </select>
        <select
          value={categoryFilter}
          onChange={(event) => {
            setCategoryFilter(event.target.value);
            setCurrentPage(1);
          }}
          className="h-10 rounded-xl border border-slate-200 bg-white px-3 text-sm font-medium text-slate-700 outline-none focus:border-amber-500"
        >
          <option value="">Tất cả danh mục</option>
          {categories.map((category) => (
            <option key={category.id} value={category.id}>
              {category.name}
            </option>
          ))}
        </select>
        <select
          value={visibilityFilter}
          onChange={(event) => {
            setVisibilityFilter(event.target.value as 'all' | 'public' | 'private');
            setCurrentPage(1);
          }}
          className="h-10 rounded-xl border border-slate-200 bg-white px-3 text-sm font-medium text-slate-700 outline-none focus:border-amber-500"
        >
          <option value="all">Mọi hiển thị</option>
          <option value="public">Công khai</option>
          <option value="private">Riêng tư</option>
        </select>
        <select
          value={ordering}
          onChange={(event) => {
            setOrdering(event.target.value as EventOrdering);
            setCurrentPage(1);
          }}
          className="h-10 rounded-xl border border-slate-200 bg-white px-3 text-sm font-medium text-slate-700 outline-none focus:border-amber-500"
        >
          <option value="-start_at">Diễn ra mới nhất</option>
          <option value="start_at">Diễn ra sớm nhất</option>
          <option value="-created_at">Mới tạo trước</option>
          <option value="created_at">Cũ nhất trước</option>
          <option value="status">Trạng thái A-Z</option>
          <option value="-status">Trạng thái Z-A</option>
        </select>
        <div className="flex gap-2">
          <button
            type="submit"
            className="h-10 rounded-xl bg-amber-500 px-4 text-sm font-bold text-white hover:bg-amber-600"
          >
            Tìm
          </button>
          {/* <button
            type="button"
            onClick={() => {
              void handleQuickAudit();
            }}
            className="inline-flex h-10 items-center gap-2 rounded-xl border border-slate-200 bg-white px-3 text-sm font-bold text-slate-600 hover:text-amber-600"
          >
            <RotateCw className="h-4 w-4" />
            Làm mới
          </button> */}
        </div>
      </form>

      {/* Moderation Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
        {/* Main Content */}
        <div className="lg:col-span-8 space-y-4">
          <div className="flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
            <div>
              <h3 className="text-xs font-bold uppercase tracking-widest text-slate-500 flex items-center gap-2">
                <CheckCircle className="w-4 h-4" />
                Danh sách sự kiện ({totalEvents})
              </h3>
              <p className="mt-1 text-xs text-slate-500">
                {reportedCount} sự kiện bị báo cáo, {pendingCount} sự kiện chờ phê duyệt.
              </p>
            </div>
            <p className="text-xs font-semibold text-slate-500">
              {isEventsLoading ? 'Đang tải danh sách...' : `Trang ${safeCurrentPage}/${totalPages}`}
            </p>
          </div>

          {isEventsLoading ? (
            <ListSkeleton rows={3} />
          ) : (
            events.map((event) =>
              event.reportType ? (
                <ReportedEventCard
                  key={event.id}
                  event={event}
                  onAction={handleActionRequest}
                />
              ) : (
                <PendingEventCard
                  key={event.id}
                  event={event}
                  onAction={handleActionRequest}
                />
              )
            )
          )}

          {!isEventsLoading && events.length === 0 ? (
            <EmptyState
              title="Không tìm thấy sự kiện"
              description="Hãy thay đổi bộ lọc hoặc từ khóa để xem các sự kiện phù hợp."
            />
          ) : null}

          {totalEvents > EVENTS_PER_PAGE ? (
            <div className="flex flex-col gap-3 rounded-2xl border border-white/50 bg-white/60 px-4 py-3 md:flex-row md:items-center md:justify-between">
              <p className="text-xs font-medium text-slate-500">
                Hiển thị {(safeCurrentPage - 1) * EVENTS_PER_PAGE + 1}
                -{Math.min(safeCurrentPage * EVENTS_PER_PAGE, totalEvents)} trong tổng số {totalEvents} sự kiện.
              </p>
              <div className="flex flex-wrap items-center gap-2">
                <button
                  type="button"
                  onClick={() => setCurrentPage((page) => Math.max(1, page - 1))}
                  disabled={safeCurrentPage === 1}
                  className="inline-flex h-9 w-9 items-center justify-center rounded-lg border border-slate-200 bg-white text-slate-500 transition-colors hover:text-amber-600 disabled:cursor-not-allowed disabled:opacity-50"
                  aria-label="Trang trước"
                >
                  <ChevronLeft className="h-4 w-4" />
                </button>
                {paginationItems.map((item) =>
                  typeof item === 'number' ? (
                    <button
                      key={item}
                      type="button"
                      onClick={() => setCurrentPage(item)}
                      aria-current={item === safeCurrentPage ? 'page' : undefined}
                      className={item === safeCurrentPage
                        ? 'h-9 min-w-9 rounded-lg bg-amber-500 px-3 text-xs font-bold text-white shadow-sm'
                        : 'h-9 min-w-9 rounded-lg border border-slate-200 bg-white px-3 text-xs font-bold text-slate-500 hover:text-amber-600'}
                    >
                      {item}
                    </button>
                  ) : (
                    <span
                      key={item}
                      className="inline-flex h-9 min-w-9 items-center justify-center rounded-lg px-2 text-xs font-bold text-slate-400"
                    >
                      ...
                    </span>
                  )
                )}
                <button
                  type="button"
                  onClick={() => setCurrentPage((page) => Math.min(totalPages, page + 1))}
                  disabled={safeCurrentPage === totalPages}
                  className="inline-flex h-9 w-9 items-center justify-center rounded-lg border border-slate-200 bg-white text-slate-500 transition-colors hover:text-amber-600 disabled:cursor-not-allowed disabled:opacity-50"
                  aria-label="Trang sau"
                >
                  <ChevronRight className="h-4 w-4" />
                </button>
              </div>
            </div>
          ) : null}
        </div>

        {/* Right Column: Stats & Queue */}
        <div className="lg:col-span-4 space-y-6">
          {/* Moderation Pulse Card */}
          <Card className="glass-card border-none rounded-[32px] p-6">
            <h3 className="text-sm font-bold text-on-surface mb-4">Nhịp kiểm duyệt</h3>
            <div className="grid grid-cols-2 gap-4">
              <div className="bg-white/50 p-4 rounded-2xl border border-white/40">
                <p className="text-[10px] font-bold text-slate-500 uppercase tracking-wider">Phản hồi TB</p>
                <p className="text-2xl font-black text-on-surface mt-1">{moderationPulse.avgResponseHours} giờ</p>
              </div>
              <div className="bg-white/50 p-4 rounded-2xl border border-white/40">
                <p className="text-[10px] font-bold text-slate-500 uppercase tracking-wider">Quy mô hàng đợi</p>
                <p className="text-2xl font-black text-on-surface mt-1">{moderationPulse.queueSize}</p>
              </div>
            </div>
            <div className="mt-4 p-4 bg-primary-container/20 rounded-2xl border border-primary-container/30">
              <div className="flex items-center justify-between">
                <span className="text-xs font-bold text-primary">{moderationPulse.targetLabel}</span>
                <TrendingDown className="w-4 h-4 text-primary" />
              </div>
              <div className="w-full bg-primary/10 h-1.5 rounded-full mt-2">
                <div
                  className="bg-primary h-full rounded-full"
                  style={{ width: `${moderationPulse.targetProgress}%` }}
                ></div>
              </div>
            </div>
          </Card>

          {/* Recent Activities Card */}
          <Card className="glass-card border-none rounded-[32px] p-6">
            <h3 className="text-sm font-bold text-on-surface mb-6">Hoạt động gần đây</h3>
            <div className="space-y-6">
              {moderationActivities.map((activity) => {
                const config = moderationActivityTypeConfig[activity.type];
                const Icon = config.icon;

                return (
                  <div key={activity.id} className="flex gap-3">
                    <div
                      className={`w-8 h-8 rounded-full ${config.iconBg} flex items-center justify-center shrink-0`}
                    >
                      <Icon className={`w-4 h-4 ${config.iconColor}`} />
                    </div>
                    <div>
                      <p className="text-xs font-bold text-on-surface">{activity.title}</p>
                      <p className="text-[10px] text-on-surface-variant">{activity.description}</p>
                    </div>
                  </div>
                );
              })}
            </div>
          </Card>

          {/* Moderator Policy Handbook Card */}
          <div className="bg-on-surface p-6 rounded-[32px] text-surface-container-lowest">
            <div className="w-6 h-6 flex items-center justify-center mb-2">
              <svg className="w-6 h-6 text-amber-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
              </svg>
            </div>
            <h4 className="font-bold text-sm mb-2">{policyHandbook.title}</h4>
            <p className="text-[11px] text-white/60 mb-4 leading-relaxed">
              {policyHandbook.description}
            </p>
            <a
              className="inline-flex items-center gap-2 text-[10px] font-black uppercase tracking-widest text-amber-400 hover:text-amber-300 transition-colors"
              href={policyHandbook.ctaHref}
            >
              {policyHandbook.ctaLabel}
              <svg className="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
              </svg>
            </a>
          </div>
        </div>
      </div>

      <ConfirmActionDialog
        open={pendingModerationAction !== null}
        onOpenChange={(open) => {
          if (!open) {
            setPendingModerationAction(null);
          }
        }}
        title={getActionDialogTitle(pendingModerationAction?.type)}
        description={pendingModerationAction
          ? getActionDialogDescription(pendingModerationAction.type, pendingModerationAction.title)
          : 'Xác nhận hành động kiểm duyệt.'}
        confirmLabel="Xác nhận"
        cancelLabel="Hủy"
        variant={pendingModerationAction?.type === 'decline' || pendingModerationAction?.type === 'delete' || pendingModerationAction?.type === 'cancel' ? 'danger' : 'default'}
        onConfirm={() => {
          void handleConfirmModeration();
        }}
      />
    </div>
  );
}

function ReportedEventCard({
  event,
  onAction,
}: {
  event: Event;
  onAction: (type: ModerationActionType, eventId: string, title: string) => void;
}) {
  return (
    <Card className="glass-card border-none rounded-3xl p-6 flex flex-col md:flex-row gap-6 border-l-4 border-l-error">
      {/* Image */}
      <div className="w-full md:w-48 h-32 rounded-2xl overflow-hidden shrink-0 relative bg-gradient-to-br from-slate-200 to-slate-300">
        {event.coverImageUrl && (
          <Image
            src={event.coverImageUrl}
            alt={event.title}
            fill
            className="object-cover"
            sizes="(max-width: 768px) 100vw, 192px"
          />
        )}
      </div>

      {/* Content */}
      <div className="flex-grow flex flex-col">
        <div className="flex justify-between items-start">
          <div>
            <h4 className="font-bold text-lg text-on-surface">{event.title}</h4>
            <p className="text-xs text-on-surface-variant flex items-center gap-1 mt-0.5">
              <User className="w-3 h-3" />
              {event.organizer} • <Calendar className="w-3 h-3" />
              {event.date}
            </p>
          </div>
          {event.reportType && (
            <span className="px-2 py-1 rounded bg-error/10 text-error text-[10px] font-bold uppercase tracking-tighter">
              {reportTypeLabels[event.reportType]}
            </span>
          )}
        </div>

        {event.reportSnippet && (
          <div className="mt-4 bg-error-container/30 p-3 rounded-xl">
            <p className="text-xs text-on-error-container leading-relaxed">
              <span className="font-bold">Trích đoạn báo cáo:</span> &quot;{event.reportSnippet}&quot;
            </p>
          </div>
        )}

        <div className="mt-auto pt-4 flex gap-3">
          <Link href={`/events/${event.id}`} className="flex-grow md:flex-none px-6 py-2 bg-on-surface text-surface-container-lowest rounded-xl text-xs font-bold hover:opacity-90 transition-opacity whitespace-nowrap text-center">
            Xem sự kiện
          </Link>
          <button
            type="button"
            onClick={() => {
              void onAction('decline', event.id, event.title);
            }}
            className="flex-grow md:flex-none px-6 py-2 bg-error text-white rounded-xl text-xs font-bold hover:bg-error/90 transition-opacity"
          >
            Từ chối
          </button>
          <button
            type="button"
            onClick={() => onAction('archive', event.id, event.title)}
            className="flex-grow md:flex-none px-6 py-2 glass-card text-on-surface rounded-xl text-xs font-bold border border-white/40 text-center"
          >
            Lưu trữ
          </button>
          <button
            type="button"
            onClick={() => onAction('delete', event.id, event.title)}
            className="p-2 glass-card rounded-xl text-on-surface-variant hover:text-on-surface transition-colors border border-white/40"
            aria-label={`Xóa ${event.title}`}
          >
            <MoreHorizontal className="w-4 h-4" />
          </button>
        </div>
      </div>
    </Card>
  );
}

function PendingEventCard({
  event,
  onAction,
}: {
  event: Event;
  onAction: (type: ModerationActionType, eventId: string, title: string) => void;
}) {
  return (
    <Card className="glass-card border-none rounded-3xl p-6 flex flex-col md:flex-row gap-6 hover:shadow-xl transition-shadow duration-300">
      {/* Image */}
      <div className="w-full md:w-48 h-32 rounded-2xl overflow-hidden shrink-0 relative bg-gradient-to-br from-amber-100 to-amber-200">
        {event.coverImageUrl && (
          <Image
            src={event.coverImageUrl}
            alt={event.title}
            fill
            className="object-cover"
            sizes="(max-width: 768px) 100vw, 192px"
          />
        )}
      </div>

      {/* Content */}
      <div className="flex-grow flex flex-col">
        <div className="flex justify-between items-start">
          <div>
            <h4 className="font-bold text-lg text-on-surface">{event.title}</h4>
            <p className="text-xs text-on-surface-variant flex items-center gap-1 mt-0.5">
              <User className="w-3 h-3" />
              {event.organizer} • <Calendar className="w-3 h-3" />
              {event.date}
            </p>
          </div>
          {event.organizerTag ? (
            <span className="px-2 py-1 rounded bg-secondary-container/30 text-secondary text-[10px] font-bold uppercase tracking-tighter">
              {event.organizerTag}
            </span>
          ) : null}
        </div>

        <p className="text-xs text-on-surface-variant mt-4 line-clamp-2 leading-relaxed">
          {event.moderationNote ?? 'Không có thêm ngữ cảnh kiểm duyệt cho sự kiện này.'}
        </p>

        <div className="mt-auto pt-4 flex gap-3">
          <button
            type="button"
            onClick={() => {
              void onAction(getPrimaryAction(event.status), event.id, event.title);
            }}
            className="flex-grow md:flex-none px-6 py-2 bg-amber-500 text-white rounded-xl text-xs font-bold hover:bg-amber-600 transition-colors"
          >
            {getPrimaryActionLabel(event.status)}
          </button>
          <Link href={`/events/${event.id}`} className="flex-grow md:flex-none px-6 py-2 glass-card text-on-surface rounded-xl text-xs font-bold border border-white/40 text-center">
            Xem chi tiết
          </Link>
          <button
            type="button"
            onClick={() => onAction(getSecondaryAction(event.status), event.id, event.title)}
            className="flex-grow md:flex-none px-6 py-2 bg-error text-white rounded-xl text-xs font-bold hover:bg-error/90 transition-colors"
          >
            {getSecondaryActionLabel(event.status)}
          </button>
        </div>
      </div>
    </Card>
  );
}

function getPrimaryAction(status: Event['status']): ModerationActionType {
  if (status === 'approved' || status === 'active') return 'archive';
  if (status === 'rejected' || status === 'cancelled' || status === 'archived') return 'reopen';
  return 'approve';
}

function getPaginationItems(currentPage: number, totalPages: number): PaginationItem[] {
  if (totalPages <= MAX_VISIBLE_PAGES) {
    return Array.from({ length: totalPages }, (_, index) => index + 1);
  }

  const pages = new Set<number>([1, totalPages, currentPage]);
  for (let page = currentPage - 1; page <= currentPage + 1; page += 1) {
    if (page > 1 && page < totalPages) {
      pages.add(page);
    }
  }

  const sortedPages = Array.from(pages).sort((first, second) => first - second);
  return sortedPages.flatMap<PaginationItem>((page, index) => {
    const previousPage = sortedPages[index - 1];
    if (!previousPage || page - previousPage === 1) {
      return [page];
    }

    return [page - previousPage === 2 ? previousPage + 1 : index === 1 ? 'ellipsis-start' : 'ellipsis-end', page];
  });
}

function getPrimaryActionLabel(status: Event['status']): string {
  if (status === 'approved' || status === 'active') return 'Lưu trữ';
  if (status === 'rejected' || status === 'cancelled' || status === 'archived') return 'Kích hoạt lại';
  return 'Phê duyệt';
}

function getSecondaryAction(status: Event['status']): ModerationActionType {
  if (status === 'approved' || status === 'active') return 'cancel';
  if (status === 'rejected' || status === 'cancelled') return 'archive';
  if (status === 'archived') return 'reopen';
  return 'delete';
}

function getSecondaryActionLabel(status: Event['status']): string {
  if (status === 'approved' || status === 'active') return 'Hủy';
  if (status === 'rejected' || status === 'cancelled') return 'Lưu trữ';
  if (status === 'archived') return 'Kích hoạt lại';
  return 'Xóa';
}

function getActionDialogTitle(type?: ModerationActionType): string {
  if (type === 'approve') return 'Xác nhận phê duyệt sự kiện';
  if (type === 'decline') return 'Xác nhận từ chối sự kiện';
  if (type === 'cancel') return 'Xác nhận hủy sự kiện';
  if (type === 'archive') return 'Xác nhận lưu trữ sự kiện';
  if (type === 'reopen') return 'Xác nhận kích hoạt lại sự kiện';
  if (type === 'delete') return 'Xác nhận xóa sự kiện';
  return 'Xác nhận thao tác sự kiện';
}

function getActionDialogDescription(type: ModerationActionType, title: string): string {
  if (type === 'approve') return `Bạn sắp phê duyệt sự kiện ${title}. Hành động này sẽ cập nhật trạng thái kiểm duyệt.`;
  if (type === 'decline') return `Bạn sắp từ chối sự kiện ${title}. Hành động này sẽ được ghi vào nhật ký kiểm duyệt.`;
  if (type === 'cancel') return `Bạn sắp hủy sự kiện ${title}. Người dùng có thể không tiếp tục đăng ký hoặc tham gia.`;
  if (type === 'archive') return `Bạn sắp lưu trữ sự kiện ${title}. Sự kiện sẽ rời khỏi hàng đợi vận hành chính.`;
  if (type === 'reopen') return `Bạn sắp kích hoạt lại sự kiện ${title}. Sự kiện sẽ trở lại trạng thái hoạt động.`;
  return `Bạn sắp xóa mềm sự kiện ${title}. Hành động này sẽ được ghi audit.`;
}
