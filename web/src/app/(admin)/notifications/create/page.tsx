// File: src/app/(admin)/notifications/create/page.tsx
'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { toast } from 'sonner';
import { AdminSelect, ConfirmActionDialog } from '@/core/components';
import {
  getNotificationById,
  publishNotification,
  saveNotificationDraft,
  updateNotificationById,
} from '@/features/notifications/services/notifications.service';
import type { AudienceType, Notification, NotificationType } from '@/features/notifications/types';
import { runActionWithToast } from '@/core/lib/runActionWithToast';
import {
  ChevronRight,
  Send,
  Clock,
  RocketIcon,
  Wifi,
  Battery,
  Signal,
  Star,
} from 'lucide-react';

type ScheduleType = 'now' | 'later';

export default function CreateNotificationPage() {
  const router = useRouter();
  const [notificationId, setNotificationId] = useState<string | null>(null);
  const [title, setTitle] = useState('');
  const [audience, setAudience] = useState<AudienceType>('all');
  const [notificationType, setNotificationType] = useState<NotificationType>('announcement');
  const [message, setMessage] = useState('');
  const [scheduleType, setScheduleType] = useState<ScheduleType>('now');
  const [scheduleDate, setScheduleDate] = useState('');
  const [scheduleTime, setScheduleTime] = useState('');
  const [pendingAction, setPendingAction] = useState<'draft' | 'send' | 'update' | null>(null);
  const [isLoadingNotification, setIsLoadingNotification] = useState(false);
  const audienceOptions = [
    { value: 'all', label: 'Tất cả người dùng' },
    { value: 'students', label: 'Sinh viên' },
    { value: 'organizers', label: 'Nhà tổ chức' },
    { value: 'admins', label: 'Quản trị viên' },
  ] as const;
  const notificationTypeOptions = [
    { value: 'announcement', label: 'Thông báo' },
    { value: 'alert', label: 'Cảnh báo' },
    { value: 'reminder', label: 'Nhắc lịch' },
    { value: 'promotion', label: 'Ưu đãi' },
    { value: 'invite', label: 'Lời mời' },
    { value: 'ticket_confirm', label: 'Xác nhận vé' },
  ] as const;
  const baseInputClass =
    'w-full rounded-2xl border border-slate-200 bg-white/70 px-4 py-3.5 text-sm font-medium text-slate-800 outline-none transition-all placeholder:text-slate-400 focus:border-[#FFB800] focus:ring-4 focus:ring-[#FFB800]/10';

  const buildNotificationPayload = () => ({
    title,
    message,
    audience,
    type: notificationType,
    scheduleType,
    scheduleDate,
    scheduleTime,
  });

  const isEditMode = notificationId !== null;

  useEffect(() => {
    const notificationIdParam = new URLSearchParams(window.location.search).get('notificationId');
    setNotificationId(notificationIdParam);

    if (!notificationIdParam) {
      return;
    }

    const resolvedNotificationId = notificationIdParam;
    let isMounted = true;

    async function loadNotification() {
      try {
        setIsLoadingNotification(true);
        const notification = await getNotificationById(resolvedNotificationId);

        if (!isMounted) {
          return;
        }

        if (notification.status !== 'draft' && notification.status !== 'scheduled') {
          toast.error('Chỉ được chỉnh sửa thông báo bản nháp hoặc đã lên lịch.');
          router.push('/notifications');
          return;
        }

        hydrateNotificationForm(notification);
      } catch (error) {
        toast.error(error instanceof Error ? error.message : 'Không thể tải thông báo.');
        router.push('/notifications');
      } finally {
        if (isMounted) {
          setIsLoadingNotification(false);
        }
      }
    }

    void loadNotification();

    return () => {
      isMounted = false;
    };
  }, [router]);

  const hydrateNotificationForm = (notification: Notification) => {
    setTitle(notification.title);
    setMessage(notification.message);
    setAudience(notification.audience);
    setNotificationType(notification.type);

    if (notification.scheduledAt) {
      const { date, time } = getLocalDateTimeParts(notification.scheduledAt);
      setScheduleType('later');
      setScheduleDate(date);
      setScheduleTime(time);
      return;
    }

    setScheduleType('now');
    setScheduleDate('');
    setScheduleTime('');
  };

  const validateNotificationForm = () => {
    if (!title.trim() || !message.trim()) {
      toast.error('Vui lòng nhập tiêu đề và nội dung thông báo.');
      return false;
    }

    if (scheduleType === 'later' && (!scheduleDate || !scheduleTime)) {
      toast.error('Vui lòng chọn ngày và giờ lên lịch.');
      return false;
    }

    if (scheduleType === 'later' && getScheduledDateTime(scheduleDate, scheduleTime) <= new Date()) {
      toast.error('Thời điểm gửi phải ở trong tương lai.');
      return false;
    }

    return true;
  };

  const handleSaveDraft = async () => {
    await runActionWithToast(() => saveNotificationDraft(buildNotificationPayload()), {
      loading: 'Đang lưu bản nháp...',
      success: 'Đã lưu bản nháp.',
      error: 'Không thể lưu bản nháp.',
    });
  };

  const handleSendNotification = async () => {
    if (!validateNotificationForm()) {
      return;
    }

    await runActionWithToast(() => publishNotification(buildNotificationPayload()), {
      loading: scheduleType === 'now' ? 'Đang gửi thông báo...' : 'Đang lên lịch thông báo...',
      success: scheduleType === 'now' ? 'Đã gửi thông báo.' : 'Đã lên lịch thông báo.',
      error: scheduleType === 'now' ? 'Không thể gửi thông báo.' : 'Không thể lên lịch thông báo.',
    });

    router.push('/notifications');
  };

  const handleUpdateNotification = async () => {
    if (!notificationId || !validateNotificationForm()) {
      return;
    }

    await runActionWithToast(() => updateNotificationById(notificationId, buildNotificationPayload()), {
      loading: 'Đang cập nhật thông báo...',
      success: 'Đã cập nhật thông báo.',
      error: 'Không thể cập nhật thông báo.',
    });

    router.push('/notifications');
  };

  const handleRequestSaveDraft = () => {
    setPendingAction('draft');
  };

  const handleRequestSendNotification = () => {
    if (!validateNotificationForm()) {
      return;
    }

    setPendingAction('send');
  };

  const handleRequestUpdateNotification = () => {
    if (!validateNotificationForm()) {
      return;
    }

    setPendingAction('update');
  };

  const handleConfirmAction = async () => {
    if (pendingAction === 'draft') {
      await handleSaveDraft();
    }

    if (pendingAction === 'send') {
      await handleSendNotification();
    }

    if (pendingAction === 'update') {
      await handleUpdateNotification();
    }

    setPendingAction(null);
  };

  return (
    <>
      {/* Breadcrumbs & Title Section */}
      <div className="px-0 pb-4 pt-2 sm:px-4 lg:px-10 lg:pt-8">
        <nav className="flex items-center gap-2 text-[10px] font-bold uppercase tracking-widest text-slate-400 mb-2">
          <Link href="/notifications" className="hover:text-[#FFB800] transition-colors">
            Thông báo
          </Link>
          <ChevronRight className="w-3 h-3" />
          <span className="text-slate-600">{isEditMode ? 'Chỉnh sửa' : 'Tạo mới'}</span>
        </nav>
        <h2 className="text-2xl font-bold tracking-tight text-on-surface">
          {isEditMode ? 'Chỉnh sửa thông báo' : 'Tạo thông báo mới'}
        </h2>
      </div>

      {/* Form Canvas */}
      <div className="flex-1 px-0 pb-28 sm:px-4 lg:px-10">
        <div className="max-w-4xl mx-auto">
          <div className="glass-panel relative overflow-hidden rounded-[28px] p-4 shadow-xl sm:p-6 lg:rounded-[32px] lg:p-10">
            {/* Subtle Decorative Background Glow */}
            <div className="absolute -top-20 -right-20 w-64 h-64 bg-[#FFB800]/5 rounded-full blur-3xl"></div>
            <div className="absolute -bottom-20 -left-20 w-64 h-64 bg-primary-container/5 rounded-full blur-3xl"></div>

            {isLoadingNotification ? (
              <div className="relative z-10 grid gap-4">
                {Array.from({ length: 6 }).map((_, index) => (
                  <div key={index} className="h-16 animate-pulse rounded-2xl bg-white/60" />
                ))}
              </div>
            ) : (
            <form className="space-y-8 relative z-10">
              {/* Notification Title */}
              <div className="space-y-2">
                <label className="text-[10px] font-bold uppercase tracking-[0.1em] text-slate-500 ml-1">
                  Tiêu đề thông báo
                </label>
                <input
                  type="text"
                  value={title}
                  onChange={(e) => setTitle(e.target.value)}
                  className={`${baseInputClass} text-base`}
                  placeholder="Nhập tiêu đề rõ ràng..."
                />
              </div>

              <div className="grid grid-cols-1 gap-6 md:grid-cols-2 md:gap-8">
                {/* Target Audience */}
                <div className="space-y-2">
                  <label className="text-[10px] font-bold uppercase tracking-[0.1em] text-slate-500 ml-1">
                    Đối tượng nhận
                  </label>
                  <AdminSelect
                    value={audience}
                    onChange={setAudience}
                    options={audienceOptions}
                    ariaLabel="Chọn đối tượng nhận thông báo"
                    triggerClassName="h-auto cursor-pointer rounded-2xl bg-white/70 py-3.5 pl-4 pr-3 focus:border-[#FFB800] focus:ring-[#FFB800]/10"
                  />
                </div>

                <div className="space-y-2">
                  <label className="text-[10px] font-bold uppercase tracking-[0.1em] text-slate-500 ml-1">
                    Loại thông báo
                  </label>
                  <AdminSelect
                    value={notificationType}
                    onChange={setNotificationType}
                    options={notificationTypeOptions}
                    ariaLabel="Chọn loại thông báo"
                    triggerClassName="h-auto cursor-pointer rounded-2xl bg-white/70 py-3.5 pl-4 pr-3 focus:border-[#FFB800] focus:ring-[#FFB800]/10"
                  />
                </div>

              </div>

              {/* Message Body */}
              <div className="space-y-2">
                <label className="text-[10px] font-bold uppercase tracking-[0.1em] text-slate-500 ml-1">
                  Nội dung thông báo
                </label>
                <div className="bg-white/60 border border-slate-200 rounded-3xl overflow-hidden focus-within:border-[#FFB800] transition-all">
                  <textarea
                    value={message}
                    onChange={(e) => setMessage(e.target.value)}
                    className="w-full resize-none border-none bg-transparent p-6 text-sm text-slate-800 outline-none placeholder:text-slate-400"
                    placeholder="Nhập nội dung thông báo tại đây..."
                    rows={6}
                  />
                </div>
              </div>

              {/* Scheduling */}
              <div className="space-y-4">
                <label className="text-[10px] font-bold uppercase tracking-[0.1em] text-slate-500 ml-1">
                  Lịch gửi
                </label>
                <div className="flex flex-col gap-4 md:flex-row">
                  <label
                    className="flex-1 flex items-center justify-between p-4 bg-white/60 border border-slate-200 rounded-2xl cursor-pointer group hover:bg-white transition-all"
                  >
                    <div className="flex items-center gap-3">
                      <div className="p-2 bg-slate-100 rounded-lg text-slate-500">
                        <Send className="w-[18px] h-[18px]" />
                      </div>
                      <div>
                        <p className="text-sm font-bold text-slate-900">Gửi ngay</p>
                        <p className="text-[10px] text-slate-400">Gửi ngay tới đối tượng đã chọn</p>
                      </div>
                    </div>
                    <input
                      type="radio"
                      name="scheduling"
                      value="now"
                      checked={scheduleType === 'now'}
                      onChange={() => setScheduleType('now')}
                      className="w-5 h-5 text-[#FFB800] focus:ring-[#FFB800] border-slate-300"
                    />
                  </label>
                  <label
                    className="flex-1 flex items-center justify-between p-4 bg-white/60 border border-slate-200 rounded-2xl cursor-pointer group hover:bg-white transition-all"
                  >
                    <div className="flex items-center gap-3">
                      <div className="p-2 bg-slate-100 rounded-lg text-slate-500">
                        <Clock className="w-[18px] h-[18px]" />
                      </div>
                      <div>
                        <p className="text-sm font-bold text-slate-900">Lên lịch gửi</p>
                        <p className="text-[10px] text-slate-400">Chọn ngày và giờ gửi</p>
                      </div>
                    </div>
                    <input
                      type="radio"
                      name="scheduling"
                      value="later"
                      checked={scheduleType === 'later'}
                      onChange={() => setScheduleType('later')}
                      className="w-5 h-5 text-[#FFB800] focus:ring-[#FFB800] border-slate-300"
                    />
                  </label>
                </div>

                {/* Contextual Date Picker (Shown on Schedule) */}
                {scheduleType === 'later' && (
                  <div className="flex flex-col gap-4 rounded-2xl border border-dashed border-slate-200 bg-slate-50/50 p-4 sm:flex-row">
                    <div className="flex-1">
                      <input
                        type="date"
                        value={scheduleDate}
                        min={getTodayInputDate()}
                        onChange={(e) => setScheduleDate(e.target.value)}
                        className="w-full rounded-xl border border-slate-200 bg-white px-4 py-2.5 text-sm text-slate-800 outline-none transition-all focus:border-[#FFB800] focus:ring-4 focus:ring-[#FFB800]/10"
                      />
                    </div>
                    <div className="flex-1">
                      <input
                        type="time"
                        value={scheduleTime}
                        onChange={(e) => setScheduleTime(e.target.value)}
                        className="w-full rounded-xl border border-slate-200 bg-white px-4 py-2.5 text-sm text-slate-800 outline-none transition-all focus:border-[#FFB800] focus:ring-4 focus:ring-[#FFB800]/10"
                      />
                    </div>
                  </div>
                )}
              </div>

              {/* Actions */}
              <div className="flex flex-col gap-4 border-t border-slate-100 pt-6 md:flex-row md:items-center md:justify-between">
                {isEditMode ? (
                  <span className="text-xs font-semibold text-slate-400">Chỉ có thể chỉnh sửa thông báo bản nháp hoặc đã lên lịch.</span>
                ) : (
                  <button
                    type="button"
                    onClick={() => {
                      handleRequestSaveDraft();
                    }}
                    className="px-8 py-3.5 rounded-2xl border border-slate-200 bg-white/50 text-slate-600 font-bold text-sm hover:bg-white transition-all active:scale-95"
                  >
                    Lưu bản nháp
                  </button>
                )}
                <div className="flex flex-col gap-4 sm:flex-row sm:items-center">
                  <button
                    type="button"
                    onClick={() => router.back()}
                    className="text-slate-400 text-xs font-semibold hover:text-slate-600 transition-colors"
                  >
                    Hủy thay đổi
                  </button>
                  <button
                    type="button"
                    onClick={() => {
                      if (isEditMode) {
                        handleRequestUpdateNotification();
                        return;
                      }

                      handleRequestSendNotification();
                    }}
                    className="flex items-center justify-center gap-2 rounded-2xl bg-[#FFB800] px-8 py-3.5 text-sm font-bold text-white shadow-xl shadow-[#FFB800]/30 transition-all hover:scale-[1.02] hover:saturate-150 active:scale-95 sm:px-10"
                  >
                    <span>{isEditMode ? 'Cập nhật thông báo' : 'Gửi thông báo'}</span>
                    <RocketIcon className="w-[18px] h-[18px]" />
                  </button>
                </div>
              </div>
            </form>
            )}
          </div>

          {/* Preview Card */}
          <div className="mt-8">
            <div className="flex items-center justify-between mb-4">
              <h4 className="text-[10px] font-bold uppercase tracking-widest text-slate-400">
                Xem trước nhanh
              </h4>
              <span className="text-[10px] text-slate-400 font-medium">Thiết bị: iPhone 15 Pro</span>
            </div>
            <div className="glass-panel relative mx-auto flex aspect-[9/19] w-full max-w-[22rem] flex-col items-center justify-start overflow-hidden rounded-[2rem] border-[6px] border-slate-900 p-3 shadow-2xl sm:rounded-[2.5rem] sm:border-8 sm:p-4">
              {/* Screen Header */}
              <div className="w-full flex justify-between px-6 pt-2 mb-8">
                <span className="text-[10px] font-bold">9:41</span>
                <div className="flex gap-1 items-center">
                  <Signal className="w-[10px] h-[10px]" />
                  <Wifi className="w-[10px] h-[10px]" />
                  <Battery className="w-[10px] h-[10px]" />
                </div>
              </div>

              {/* Notification Toast */}
              <div className="w-full bg-white/90 backdrop-blur-md rounded-3xl p-4 shadow-lg border border-white/50 animate-pulse">
                <div className="flex items-center gap-2 mb-2">
                  <div className="w-5 h-5 bg-[#FFB800] rounded-md flex items-center justify-center">
                    <Star className="w-[12px] h-[12px] text-white fill-white" />
                  </div>
                  <span className="text-[10px] font-bold text-slate-400">UEVENTS • BÂY GIỜ</span>
                </div>
                <h5 className="text-xs font-bold text-slate-900 mb-0.5">
                  {title || 'Tiêu đề thông báo hiển thị tại đây'}
                </h5>
                <p className="text-[10px] text-slate-500 leading-relaxed">
                  {message || 'Nội dung thông báo sẽ hiển thị như thế này trên màn hình khóa của người dùng...'}
                </p>
              </div>

              {/* Background Image */}
              <div className="absolute inset-0 -z-10">
                <div className="w-full h-full bg-slate-900 overflow-hidden">
                  <div className="absolute inset-0 bg-gradient-to-br from-indigo-500/30 to-purple-600/30"></div>
                  <div className="w-full h-full bg-gradient-to-br from-indigo-600 via-purple-600 to-pink-500 opacity-50"></div>
                </div>
              </div>
            </div>
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
        title={
          pendingAction === 'draft'
            ? 'Xác nhận lưu bản nháp'
            : pendingAction === 'update'
              ? 'Xác nhận cập nhật thông báo'
              : 'Xác nhận gửi thông báo'
        }
        description={pendingAction === 'draft'
          ? 'Bạn sắp lưu bản nháp thông báo. Dữ liệu hiện tại sẽ được ghi đè vào bản nháp trước đó nếu có.'
          : pendingAction === 'update'
            ? 'Bạn sắp cập nhật thông báo bản nháp hoặc đã lên lịch. Nội dung mới sẽ thay thế dữ liệu hiện tại.'
          : 'Bạn sắp gửi hoặc lên lịch thông báo cho người dùng. Hành động này có thể không hoàn tác sau khi thực hiện.'}
        confirmLabel="Xác nhận"
        cancelLabel="Hủy"
        onConfirm={() => {
          void handleConfirmAction();
        }}
      />
    </>
  );
}

function getLocalDateTimeParts(isoDate: string): { date: string; time: string } {
  const date = new Date(isoDate);
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');
  const hour = String(date.getHours()).padStart(2, '0');
  const minute = String(date.getMinutes()).padStart(2, '0');

  return {
    date: `${year}-${month}-${day}`,
    time: `${hour}:${minute}`,
  };
}

function getScheduledDateTime(date: string, time: string): Date {
  return new Date(`${date}T${time}:00`);
}

function getTodayInputDate(): string {
  const today = new Date();
  const year = today.getFullYear();
  const month = String(today.getMonth() + 1).padStart(2, '0');
  const day = String(today.getDate()).padStart(2, '0');

  return `${year}-${month}-${day}`;
}
