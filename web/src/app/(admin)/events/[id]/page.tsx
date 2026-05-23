// File: src/app/(admin)/events/[id]/page.tsx
'use client';

import { useEffect, useState } from 'react';
import Image from 'next/image';
import Link from 'next/link';
import { useParams, useRouter } from 'next/navigation';
import {
  ChevronLeft,
  AlertTriangle,
  Calendar,
  MapPin,
  Users,
  Flag,
  Archive,
  RotateCw,
  Trash2,
} from 'lucide-react';
import { ConfirmActionDialog, ErrorState, ListSkeleton } from '@/core/components';
import { runActionWithToast } from '@/core/lib/runActionWithToast';
import {
  deleteEventById,
  getEventById,
  moderateEventStatus,
} from '@/features/events/services/events.service';
import type { Event } from '@/features/events/types';

const FALLBACK_EVENT_IMAGE =
  'https://lh3.googleusercontent.com/aida-public/AB6AXuAs4b_L9QgWf1XDH0qx4gM5_00TpPdC1Klew3A-z8zhcyac4mFYrzPpnVWxU2hh9IC3TqNhMnqkeRO-e-jKUu39WMa5GbbZDljjvyUb3JfhqPLtf8yAEeHSZlpem6qFS2vbRJpc2SFZHQgc2vtnlhdWh70dYdQHT9eAMFasMPLfvTA3y5iKFWKrAqQBXbha-ttNDKcLlJVCY0LJVK3zlB8EAEUs-5gab1dWrWcMQ8Jk7Kuk-kTB3ag13oVHmucQgBEKGgNaPn4ipyg';
type EventReviewAction = 'approve' | 'decline' | 'cancel' | 'archive' | 'reopen' | 'delete';
type EventStatusAction = Exclude<EventReviewAction, 'delete'>;

export default function EventReviewDetailPage() {
  const router = useRouter();
  const params = useParams<{ id: string }>();
  const [event, setEvent] = useState<Event | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [pendingAction, setPendingAction] = useState<EventReviewAction | null>(null);

  const handleApprove = () => {
    setPendingAction('approve');
  };

  const handleDecline = () => {
    setPendingAction('decline');
  };

  useEffect(() => {
    let isMounted = true;

    async function loadEvent() {
      try {
        setIsLoading(true);
        setError(null);
        const response = await getEventById(params.id);

        if (isMounted) {
          setEvent(response);
        }
      } catch (loadError) {
        if (isMounted) {
          setError(loadError instanceof Error ? loadError.message : 'Không thể tải sự kiện.');
        }
      } finally {
        if (isMounted) {
          setIsLoading(false);
        }
      }
    }

    void loadEvent();

    return () => {
      isMounted = false;
    };
  }, [params.id]);

  const handleConfirmModeration = async () => {
    if (!event || !pendingAction) {
      return;
    }

    const action = pendingAction;
    setPendingAction(null);

    if (action === 'delete') {
      await runActionWithToast(
        () => deleteEventById(event.id, 'Quản trị viên đã xóa từ trang chi tiết sự kiện.'),
        {
          loading: 'Đang xóa mềm sự kiện...',
          success: 'Đã xóa mềm sự kiện.',
          error: 'Không thể xóa mềm sự kiện.',
        }
      );
      router.push('/events');
      return;
    }

    const nextStatus = getStatusForAction(action);
    await runActionWithToast(
      () => moderateEventStatus(event.id, nextStatus, getReasonForAction(action)),
      {
        loading: getLoadingForAction(action),
        success: getSuccessForAction(action),
        error: getErrorForAction(action),
      }
    );
    router.push('/events');
  };

  if (isLoading) {
    return <ListSkeleton rows={6} className="p-10" />;
  }

  if (error) {
    return (
      <ErrorState
        title="Không thể tải sự kiện"
        message={error}
        onRetry={() => router.refresh()}
      />
    );
  }

  if (!event) {
    return null;
  }

  const canReview = event.status === 'pending';
  const canCancel = event.status === 'approved' || event.status === 'active';
  const canArchive = event.status === 'finished' || event.status === 'cancelled' || event.status === 'rejected';
  const canReopen = event.status === 'cancelled' || event.status === 'rejected' || event.status === 'archived';
  const canSoftDelete = event.status !== 'archived';

  return (
    <div className="min-h-screen pb-12">
      {/* TopNavBar */}
      <header className="mb-6 flex flex-col gap-4 rounded-3xl border border-white/50 bg-white/65 p-4 shadow-sm backdrop-blur-3xl sm:flex-row sm:items-center sm:justify-between sm:p-5">
        <div className="flex min-w-0 items-center gap-3 sm:gap-4">
          <Link
            href="/events"
            className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full text-slate-900 transition-colors hover:bg-black/5"
          >
            <ChevronLeft className="w-6 h-6" />
          </Link>
          <div className="min-w-0">
            <h2 className="truncate text-lg font-bold tracking-tight text-slate-900 sm:text-xl">
              Xem xét chi tiết sự kiện
            </h2>
            <p className="mt-1 text-xs font-medium text-slate-500 sm:text-sm">
              {getStatusHelperText(event.status)}
            </p>
          </div>
        </div>

        {canReview ? (
          <div className="flex flex-col gap-3 sm:flex-row sm:items-center">
            <button
              type="button"
              onClick={handleDecline}
              className="rounded-full border border-red-600 px-6 py-2 text-sm font-bold text-red-600 transition-all hover:bg-red-50 active:scale-95"
            >
              Từ chối
            </button>
            <button
              type="button"
              onClick={handleApprove}
              className="rounded-full bg-amber-500 px-6 py-2 text-sm font-bold text-white shadow-md transition-all hover:opacity-90 active:scale-95"
            >
              Phê duyệt
            </button>
          </div>
        ) : (
          <div className="flex flex-col items-start gap-2 sm:items-end">
            <span className={getStatusBadgeClassName(event.status)}>
              {formatStatusLabel(event.status)}
            </span>
          </div>
        )}
      </header>

      {/* Scrollable Content */}
      <div className="mx-auto max-w-6xl">
        {event.reportType ? (
          <div className="mb-8 flex flex-col gap-4 rounded-2xl border border-red-100 bg-red-50 p-4 sm:flex-row sm:items-start">
            <div className="w-10 h-10 rounded-full bg-red-600 flex items-center justify-center shrink-0">
              <AlertTriangle className="text-white w-5 h-5" />
            </div>
            <div className="flex-1">
              <h3 className="text-red-700 font-bold text-lg leading-tight">
                Đã gắn cờ báo cáo kiểm duyệt
              </h3>
              <p className="text-red-600/80 text-sm mt-1">
                {event.reportSnippet || 'Sự kiện này có báo cáo kiểm duyệt cần được xem xét.'}
              </p>
            </div>
            <div className="w-fit rounded-full bg-red-100 px-3 py-1 text-[10px] font-black uppercase tracking-widest text-red-700 sm:ml-auto">
              {formatReportTypeLabel(event.reportType)}
            </div>
          </div>
        ) : null}

        {/* Bento Grid Layout */}
        <div className="grid grid-cols-12 gap-6">
          {/* Hero Section: Full Event Banner (8 Cols) */}
          <div className="col-span-12 lg:col-span-8 space-y-6">
            <div className="group relative aspect-[4/3] overflow-hidden rounded-[28px] shadow-xl sm:aspect-[16/9] lg:aspect-[21/9] lg:rounded-[32px]">
              <Image
                src={event.coverImageUrl || FALLBACK_EVENT_IMAGE}
                alt="Ảnh bìa sự kiện"
                fill
                sizes="(min-width: 1024px) 66vw, 100vw"
                className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-700"
              />
              <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent"></div>
              <div className="absolute inset-x-4 bottom-4 text-white sm:inset-x-8 sm:bottom-8">
                <div className="mb-3 flex flex-wrap gap-2">
                  <span className="px-3 py-1 bg-amber-500 text-black text-[10px] font-black uppercase tracking-widest rounded-full">
                    {event.category}
                  </span>
                  <span className="px-3 py-1 bg-white/20 backdrop-blur-md text-white text-[10px] font-black uppercase tracking-widest rounded-full">
                    {formatVisibilityLabel(event.visibility)}
                  </span>
                </div>
                <h1 className="mb-2 line-clamp-3 text-2xl font-black leading-tight tracking-tight sm:text-4xl sm:leading-none">
                  {event.title}
                </h1>
                <p className="text-white/80 font-medium flex flex-wrap gap-2">
                  <span>Bởi {event.organizer}</span>
                  <span>•</span>
                  <span>{formatStatusLabel(event.status)}</span>
                </p>
              </div>
            </div>

            {/* Description Section */}
            <div className="rounded-[28px] border border-white/40 bg-white/50 p-5 shadow-sm backdrop-blur-xl sm:p-8 lg:rounded-[32px]">
              <h4 className="text-sm font-bold uppercase tracking-widest text-slate-400 mb-6">
                Mô tả sự kiện
              </h4>
              <div className="space-y-4 text-slate-700 leading-relaxed">
                <p>
                  {event.description || 'Chưa có mô tả sự kiện.'}
                </p>
                {event.reportSnippet ? (
                <div className="bg-red-50 p-4 rounded-xl border-l-4 border-red-500 italic text-red-700">
                  <p>
                    &quot;{event.reportSnippet}&quot;
                  </p>
                  <span className="block text-[10px] font-bold mt-2 not-italic text-red-600">
                    MỤC BỊ GẮN CỜ
                  </span>
                </div>
                ) : null}
              </div>
            </div>
          </div>

          {/* Details & Stats (4 Cols) */}
          <div className="col-span-12 lg:col-span-4 space-y-6">
            {/* Quick Info */}
            <div className="space-y-6 rounded-[28px] border border-white/40 bg-white/80 p-5 shadow-sm backdrop-blur-xl sm:p-6 lg:rounded-[32px]">
              <div>
                <h4 className="text-[10px] font-bold uppercase tracking-widest text-slate-400 mb-3">
                  Địa điểm
                </h4>
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-xl bg-slate-100 flex items-center justify-center">
                    <MapPin className="text-slate-600 w-5 h-5" />
                  </div>
                  <div>
                    <p className="font-bold text-slate-900">{event.location || 'Chưa đặt địa điểm'}</p>
                    <p className="text-sm text-slate-500">
                      {event.category}
                    </p>
                  </div>
                </div>
              </div>

              <div>
                <h4 className="text-[10px] font-bold uppercase tracking-widest text-slate-400 mb-3">
                  Ngày & giờ
                </h4>
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-xl bg-slate-100 flex items-center justify-center">
                    <Calendar className="text-slate-600 w-5 h-5" />
                  </div>
                  <div>
                    <p className="font-bold text-slate-900">
                      {event.startAt ? `Bắt đầu: ${formatDateTime(event.startAt)}` : event.date}
                    </p>
                    <p className="text-sm text-slate-500">
                      {event.endAt ? `Kết thúc: ${formatDateTime(event.endAt)}` : 'Chưa có thời gian kết thúc'}
                    </p>
                  </div>
                </div>
              </div>

              <div>
                <h4 className="text-[10px] font-bold uppercase tracking-widest text-slate-400 mb-3">
                  Sức chứa dự kiến
                </h4>
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-xl bg-slate-100 flex items-center justify-center">
                    <Users className="text-slate-600 w-5 h-5" />
                  </div>
                  <div>
                    <p className="font-bold text-slate-900">{event.maxCapacity ?? 'Không giới hạn'} người tham dự</p>
                    <p className="text-sm text-slate-500">Dữ liệu đăng ký sẽ được bổ sung khi backend cung cấp.</p>
                  </div>
                </div>
              </div>
            </div>

            {/* Organizer Profile */}
            <div className="rounded-[28px] border border-white/40 bg-white/80 p-5 shadow-sm backdrop-blur-xl sm:p-6 lg:rounded-[32px]">
              <h4 className="text-[10px] font-bold uppercase tracking-widest text-slate-400 mb-4">
                Tài khoản ban tổ chức
              </h4>
              <div className="flex items-center gap-4 mb-4">
                <div className="flex h-12 w-12 items-center justify-center rounded-full border-2 border-amber-500 bg-amber-50 text-sm font-black text-amber-700">
                  {event.organizer.slice(0, 2).toUpperCase()}
                </div>
                <div>
                  <p className="font-bold text-slate-900">{event.organizer}</p>
                  <p className="text-xs text-slate-500">
                    {event.organizerTag}
                  </p>
                </div>
              </div>

              <p className="rounded-2xl bg-slate-50 p-3 text-xs leading-relaxed text-slate-500">
                Hồ sơ ban tổ chức đang dùng dữ liệu tài khoản từ API sự kiện. Các chỉ số đánh giá và vi phạm sẽ chỉ hiển thị khi backend cung cấp contract chính thức.
              </p>
            </div>

            <div className="rounded-[28px] border border-white/40 bg-white/80 p-5 shadow-sm sm:p-6 lg:rounded-[32px]">
              <h4 className="mb-4 text-[10px] font-bold uppercase tracking-widest text-slate-400">
                Nhật ký kiểm duyệt
              </h4>
              <div className="space-y-4">
                {(event.moderationLogs ?? []).length > 0 ? (
                  event.moderationLogs?.map((log) => (
                    <div key={log.id} className="rounded-2xl border border-slate-100 bg-slate-50 p-4">
                      <div className="flex items-center justify-between gap-3">
                        <p className="text-sm font-bold text-slate-900">{formatModerationAction(log.action)}</p>
                        <span className="text-[10px] font-semibold text-slate-400">
                          {new Date(log.createdAt).toLocaleString('vi-VN')}
                        </span>
                      </div>
                      <p className="mt-2 text-xs leading-relaxed text-slate-500">
                        {log.reason || 'Không có ghi chú kiểm duyệt.'}
                      </p>
                      {log.adminUser ? (
                        <p className="mt-2 text-[11px] font-semibold text-slate-400">
                          Bởi {log.adminUser.fullName || log.adminUser.username}
                        </p>
                      ) : null}
                    </div>
                  ))
                ) : (
                  <p className="text-sm text-slate-500">Chưa có nhật ký kiểm duyệt cho sự kiện này.</p>
                )}
              </div>
            </div>
          </div>
        </div>

        {/* Action Footer */}
        <div className="mt-12 flex flex-col gap-5 border-t border-slate-200 pt-8 xl:flex-row xl:items-center xl:justify-between">
          <div className="flex flex-wrap gap-4">
            {canCancel ? (
              <button
                type="button"
                onClick={() => setPendingAction('cancel')}
                className="flex items-center gap-2 text-slate-500 hover:text-slate-900 font-medium transition-colors"
              >
                <Flag className="w-5 h-5" />
                Hủy sự kiện
              </button>
            ) : null}
            {canArchive ? (
              <button
                type="button"
                onClick={() => setPendingAction('archive')}
                className="flex items-center gap-2 text-slate-500 hover:text-slate-900 font-medium transition-colors"
              >
                <Archive className="w-5 h-5" />
                Lưu trữ
              </button>
            ) : null}
            {canReopen ? (
              <button
                type="button"
                onClick={() => setPendingAction('reopen')}
                className="flex items-center gap-2 text-slate-500 hover:text-slate-900 font-medium transition-colors"
              >
                <RotateCw className="w-5 h-5" />
                Kích hoạt lại
              </button>
            ) : null}
            {canSoftDelete ? (
              <button
                type="button"
                onClick={() => setPendingAction('delete')}
                className="flex items-center gap-2 text-red-500 hover:text-red-700 font-medium transition-colors"
              >
                <Trash2 className="w-5 h-5" />
                Xóa mềm
              </button>
            ) : null}
          </div>
          <div className="flex flex-col gap-3 sm:flex-row sm:gap-4">
            <Link
              href="/events"
              className="rounded-full bg-slate-200 px-8 py-3 text-center font-bold text-slate-700 transition-all hover:bg-slate-300"
            >
              Quay lại
            </Link>
            {canReview ? (
              <button
                type="button"
                onClick={handleApprove}
                className="rounded-full bg-amber-500 px-8 py-3 font-bold text-white shadow-lg shadow-amber-500/20 transition-all hover:scale-105 active:scale-95 sm:px-10"
              >
                Xác nhận & phê duyệt
              </button>
            ) : null}
          </div>
        </div>
      </div>
      <ConfirmActionDialog
        open={pendingAction !== null}
        onOpenChange={(open) => {
          if (!open) {
            setPendingAction(null);
          }
        }}
        title={getActionTitle(pendingAction)}
        description={getActionDescription(pendingAction, event.title)}
        confirmLabel="Xác nhận"
        cancelLabel="Hủy"
        variant={pendingAction === 'decline' || pendingAction === 'cancel' || pendingAction === 'delete' ? 'danger' : 'default'}
        onConfirm={() => {
          void handleConfirmModeration();
        }}
      />
    </div>
  );
}

function getStatusForAction(action: EventStatusAction): 'approved' | 'rejected' | 'cancelled' | 'archived' | 'active' {
  if (action === 'approve') return 'approved';
  if (action === 'decline') return 'rejected';
  if (action === 'cancel') return 'cancelled';
  if (action === 'archive') return 'archived';
  return 'active';
}

function getReasonForAction(action: EventStatusAction): string {
  if (action === 'approve') return 'Đã phê duyệt từ trang chi tiết sự kiện.';
  if (action === 'decline') return 'Đã từ chối từ trang chi tiết sự kiện.';
  if (action === 'cancel') return 'Đã hủy từ trang chi tiết sự kiện.';
  if (action === 'archive') return 'Đã lưu trữ từ trang chi tiết sự kiện.';
  return 'Đã kích hoạt lại từ trang chi tiết sự kiện.';
}

function getLoadingForAction(action: EventStatusAction): string {
  if (action === 'approve') return 'Đang phê duyệt sự kiện...';
  if (action === 'decline') return 'Đang từ chối sự kiện...';
  if (action === 'cancel') return 'Đang hủy sự kiện...';
  if (action === 'archive') return 'Đang lưu trữ sự kiện...';
  return 'Đang kích hoạt lại sự kiện...';
}

function getSuccessForAction(action: EventStatusAction): string {
  if (action === 'approve') return 'Đã phê duyệt và xuất bản sự kiện.';
  if (action === 'decline') return 'Đã từ chối sự kiện.';
  if (action === 'cancel') return 'Đã hủy sự kiện.';
  if (action === 'archive') return 'Đã lưu trữ sự kiện.';
  return 'Đã kích hoạt lại sự kiện.';
}

function getErrorForAction(action: EventStatusAction): string {
  if (action === 'approve') return 'Không thể phê duyệt sự kiện.';
  if (action === 'decline') return 'Không thể từ chối sự kiện.';
  if (action === 'cancel') return 'Không thể hủy sự kiện.';
  if (action === 'archive') return 'Không thể lưu trữ sự kiện.';
  return 'Không thể kích hoạt lại sự kiện.';
}

function getActionTitle(action: EventReviewAction | null): string {
  if (action === 'approve') return 'Xác nhận phê duyệt sự kiện';
  if (action === 'decline') return 'Xác nhận từ chối sự kiện';
  if (action === 'cancel') return 'Xác nhận hủy sự kiện';
  if (action === 'archive') return 'Xác nhận lưu trữ sự kiện';
  if (action === 'reopen') return 'Xác nhận kích hoạt lại sự kiện';
  if (action === 'delete') return 'Xác nhận xóa mềm sự kiện';
  return 'Xác nhận thao tác sự kiện';
}

function getActionDescription(action: EventReviewAction | null, title: string): string {
  if (action === 'approve') return `Bạn sắp phê duyệt sự kiện ${title}.`;
  if (action === 'decline') return `Bạn sắp từ chối sự kiện ${title}.`;
  if (action === 'cancel') return `Bạn sắp hủy sự kiện ${title}.`;
  if (action === 'archive') return `Bạn sắp lưu trữ sự kiện ${title}.`;
  if (action === 'reopen') return `Bạn sắp kích hoạt lại sự kiện ${title}.`;
  if (action === 'delete') return `Bạn sắp xóa mềm sự kiện ${title}.`;
  return 'Vui lòng xác nhận thao tác.';
}

function formatStatusLabel(status: Event['status']): string {
  if (status === 'pending') return 'Chờ duyệt';
  if (status === 'approved') return 'Đã duyệt';
  if (status === 'active') return 'Đang hoạt động';
  if (status === 'finished') return 'Đã kết thúc';
  if (status === 'cancelled') return 'Đã hủy';
  if (status === 'rejected') return 'Đã từ chối';
  if (status === 'archived') return 'Lưu trữ';
  return 'Bản nháp';
}

function getStatusHelperText(status: Event['status']): string {
  if (status === 'pending') return 'Sự kiện đang chờ kiểm duyệt, vui lòng chọn phê duyệt hoặc từ chối.';
  if (status === 'approved') return 'Sự kiện đã được phê duyệt, không cần thực hiện thao tác duyệt lại.';
  if (status === 'active') return 'Sự kiện đang hoạt động, chỉ hiển thị các thao tác quản trị phù hợp.';
  if (status === 'finished') return 'Sự kiện đã kết thúc, có thể lưu trữ hoặc xem lại nhật ký kiểm duyệt.';
  if (status === 'cancelled') return 'Sự kiện đã bị hủy, có thể lưu trữ hoặc kích hoạt lại khi cần.';
  if (status === 'rejected') return 'Sự kiện đã bị từ chối, có thể lưu trữ hoặc kích hoạt lại nếu đã xử lý xong.';
  if (status === 'archived') return 'Sự kiện đang ở trạng thái lưu trữ, chỉ có thể kích hoạt lại.';
  return 'Sự kiện đang ở bản nháp, chưa sẵn sàng để phê duyệt.';
}

function getStatusBadgeClassName(status: Event['status']): string {
  const baseClassName = 'w-fit rounded-full px-4 py-2 text-xs font-black uppercase tracking-widest';

  if (status === 'approved' || status === 'active') {
    return `${baseClassName} bg-emerald-100 text-emerald-700`;
  }

  if (status === 'pending') {
    return `${baseClassName} bg-amber-100 text-amber-700`;
  }

  if (status === 'cancelled' || status === 'rejected') {
    return `${baseClassName} bg-red-100 text-red-700`;
  }

  if (status === 'finished') {
    return `${baseClassName} bg-blue-100 text-blue-700`;
  }

  return `${baseClassName} bg-slate-100 text-slate-700`;
}

function formatModerationAction(action: string): string {
  if (action === 'approve') return 'Phê duyệt';
  if (action === 'reject') return 'Từ chối';
  if (action === 'request_revision') return 'Yêu cầu chỉnh sửa';
  if (action === 'lock') return 'Khóa hoặc hủy';
  if (action === 'delete') return 'Xóa mềm';
  if (action === 'reopen') return 'Mở lại';
  if (action === 'escalate') return 'Chuyển cấp xử lý';
  return action;
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

function formatVisibilityLabel(visibility?: string | null): string {
  if (visibility === 'private') return 'Riêng tư';
  if (visibility === 'unlisted') return 'Không niêm yết';
  return 'Công khai';
}

function formatReportTypeLabel(reportType?: Event['reportType']): string {
  if (reportType === 'safety') return 'An toàn';
  if (reportType === 'copyright') return 'Bản quyền';
  if (reportType === 'spam') return 'Spam';
  return 'Khác';
}
