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

  return (
    <div className="min-h-screen pb-12">
      {/* TopNavBar */}
      <header className="fixed top-0 left-64 right-0 z-40 flex items-center justify-between px-8 h-[64px] bg-white/65 backdrop-blur-[40px] saturate-180 border-b-[0.5px] border-black/10">
        <div className="flex items-center gap-4">
          <Link
            href="/events"
            className="w-10 h-10 flex items-center justify-center rounded-full hover:bg-black/5 transition-colors text-slate-900"
          >
            <ChevronLeft className="w-6 h-6" />
          </Link>
          <h2 className="text-xl font-bold text-slate-900 tracking-tight">
            Xem xét chi tiết sự kiện
          </h2>
        </div>

        <div className="flex items-center gap-3">
          <button
            type="button"
            onClick={handleDecline}
            className="px-6 py-2 rounded-full border border-red-600 text-red-600 font-bold text-sm hover:bg-red-50 transition-all active:scale-95"
          >
            Từ chối
          </button>
          <button
            type="button"
            onClick={handleApprove}
            className="px-6 py-2 rounded-full bg-amber-500 text-white font-bold text-sm shadow-md hover:opacity-90 transition-all active:scale-95"
          >
            Phê duyệt
          </button>
        </div>
      </header>

      {/* Scrollable Content */}
      <div className="pt-[88px] px-8 max-w-6xl mx-auto">
        {event.reportType ? (
          <div className="mb-8 p-4 rounded-2xl bg-red-50 border border-red-100 flex items-start gap-4">
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
            <div className="px-3 py-1 bg-red-100 text-red-700 text-[10px] font-black uppercase tracking-widest rounded-full">
              {formatReportTypeLabel(event.reportType)}
            </div>
          </div>
        ) : null}

        {/* Bento Grid Layout */}
        <div className="grid grid-cols-12 gap-6">
          {/* Hero Section: Full Event Banner (8 Cols) */}
          <div className="col-span-12 lg:col-span-8 space-y-6">
            <div className="relative aspect-[21/9] rounded-[32px] overflow-hidden shadow-xl group">
              <Image
                src={event.coverImageUrl || FALLBACK_EVENT_IMAGE}
                alt="Ảnh bìa sự kiện"
                fill
                sizes="(min-width: 1024px) 66vw, 100vw"
                className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-700"
              />
              <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent"></div>
              <div className="absolute bottom-8 left-8 right-8 text-white">
                <div className="flex gap-2 mb-3">
                  <span className="px-3 py-1 bg-amber-500 text-black text-[10px] font-black uppercase tracking-widest rounded-full">
                    {event.category}
                  </span>
                  <span className="px-3 py-1 bg-white/20 backdrop-blur-md text-white text-[10px] font-black uppercase tracking-widest rounded-full">
                    {formatVisibilityLabel(event.visibility)}
                  </span>
                </div>
                <h1 className="text-4xl font-black tracking-tight leading-none mb-2">
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
            <div className="bg-white/50 backdrop-blur-xl rounded-[32px] p-8 border border-white/40 shadow-sm">
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
            <div className="bg-white/80 backdrop-blur-xl rounded-[32px] p-6 border border-white/40 shadow-sm space-y-6">
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
                    <p className="font-bold text-slate-900">{event.date}</p>
                    <p className="text-sm text-slate-500">{event.startAt ? new Date(event.startAt).toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' }) : ''}</p>
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
            <div className="bg-white/80 backdrop-blur-xl rounded-[32px] p-6 border border-white/40 shadow-sm">
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

            <div className="rounded-[32px] border border-white/40 bg-white/80 p-6 shadow-sm">
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
        <div className="mt-12 pt-8 border-t border-slate-200 flex justify-between items-center">
          <div className="flex gap-4">
            <button
              type="button"
              onClick={() => setPendingAction('cancel')}
              className="flex items-center gap-2 text-slate-500 hover:text-slate-900 font-medium transition-colors"
            >
              <Flag className="w-5 h-5" />
              Hủy sự kiện
            </button>
            <button
              type="button"
              onClick={() => setPendingAction('archive')}
              className="flex items-center gap-2 text-slate-500 hover:text-slate-900 font-medium transition-colors"
            >
              <Archive className="w-5 h-5" />
              Lưu trữ
            </button>
            <button
              type="button"
              onClick={() => setPendingAction('reopen')}
              className="flex items-center gap-2 text-slate-500 hover:text-slate-900 font-medium transition-colors"
            >
              <RotateCw className="w-5 h-5" />
              Kích hoạt lại
            </button>
            <button
              type="button"
              onClick={() => setPendingAction('delete')}
              className="flex items-center gap-2 text-red-500 hover:text-red-700 font-medium transition-colors"
            >
              <Trash2 className="w-5 h-5" />
              Xóa mềm
            </button>
          </div>
          <div className="flex gap-4">
            <Link
              href="/events"
              className="px-8 py-3 rounded-full bg-slate-200 text-slate-700 font-bold hover:bg-slate-300 transition-all text-center"
            >
              Quay lại
            </Link>
            <button
              type="button"
              onClick={handleApprove}
              className="px-10 py-3 rounded-full bg-amber-500 text-white font-bold shadow-lg shadow-amber-500/20 hover:scale-105 active:scale-95 transition-all"
            >
              Xác nhận & phê duyệt
            </button>
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
