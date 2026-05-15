'use client';

import { use, useCallback, useEffect, useState } from 'react';
import Link from 'next/link';
import { ArrowLeft, CircleCheck, Forward, Send, ShieldCheck, User } from 'lucide-react';
import { AdminSelect, Card, ConfirmActionDialog, ErrorState } from '@/core/components';
import {
  escalateSupportTicket,
  getTicketById,
  markSupportTicketResolved,
  sendSupportReply,
  updateSupportTicket,
} from '@/features/support/services/support.service';
import { getUsers } from '@/features/users/services/users.service';
import { cn } from '@/core/lib/utils';
import type { Ticket, TicketMessage, TicketPriority, TicketStatus } from '@/features/support/types';
import type { User as AdminUser } from '@/features/users/types';
import { toast } from 'sonner';
import { runActionWithToast } from '@/core/lib/runActionWithToast';

const UNASSIGNED_ASSIGNEE = '__unassigned';

const supportPriorityConfig: Record<TicketPriority, { label: string; color: string }> = {
  low: { label: 'Thấp', color: 'text-slate-600' },
  medium: { label: 'Trung bình', color: 'text-blue-600' },
  high: { label: 'Cao', color: 'text-red-500' },
  urgent: { label: 'Khẩn cấp', color: 'text-red-600' },
};

const supportDetailStatusConfig: Record<TicketStatus, { label: string; color: string }> = {
  open: { label: 'Đang chờ', color: 'text-blue-600' },
  in_progress: { label: 'Đang xử lý', color: 'text-amber-600' },
  resolved: { label: 'Đã xử lý', color: 'text-emerald-600' },
  closed: { label: 'Đã đóng', color: 'text-slate-600' },
};

const statusOptions = [
  { value: 'open', label: 'Đang chờ' },
  { value: 'in_progress', label: 'Đang xử lý' },
  { value: 'resolved', label: 'Đã xử lý' },
  { value: 'closed', label: 'Đã đóng' },
] as const;

const priorityOptions = [
  { value: 'low', label: 'Thấp' },
  { value: 'medium', label: 'Trung bình' },
  { value: 'high', label: 'Cao' },
  { value: 'urgent', label: 'Khẩn cấp' },
] as const;

interface PageProps {
  params: Promise<{ id: string }>;
}

export default function SupportDetailPage({ params }: PageProps) {
  const resolvedParams = use(params);
  const [ticket, setTicket] = useState<Ticket | null>(null);
  const [newMessage, setNewMessage] = useState('');
  const [assignees, setAssignees] = useState<AdminUser[]>([]);
  const [pendingTicketAction, setPendingTicketAction] = useState<'resolve' | 'escalate' | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [isLoadingAssignees, setIsLoadingAssignees] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const loadTicket = useCallback(async () => {
    try {
      setIsLoading(true);
      setError(null);
      const currentTicket = await getTicketById(resolvedParams.id);
      setTicket(currentTicket);
    } catch (loadError) {
      setError(loadError instanceof Error ? loadError.message : 'Không thể tải chi tiết ticket.');
    } finally {
      setIsLoading(false);
    }
  }, [resolvedParams.id]);

  useEffect(() => {
    void loadTicket();
  }, [loadTicket]);

  useEffect(() => {
    let isMounted = true;

    async function loadAssignees() {
      try {
        setIsLoadingAssignees(true);
        const response = await getUsers({ role: 'admin', status: 'active', pageSize: 100 });
        if (isMounted) {
          setAssignees(response.users);
        }
      } catch {
        if (isMounted) {
          toast.error('Không thể tải danh sách người phụ trách.');
        }
      } finally {
        if (isMounted) {
          setIsLoadingAssignees(false);
        }
      }
    }

    void loadAssignees();

    return () => {
      isMounted = false;
    };
  }, []);

  const handleSendReply = async () => {
    if (!newMessage.trim()) {
      toast.error('Vui lòng nhập nội dung phản hồi trước khi gửi.');
      return;
    }

    if (!ticket) {
      return;
    }

    const replyContent = newMessage.trim();
    await runActionWithToast(async () => {
      const updatedTicket = await sendSupportReply(ticket.id, replyContent);
      setTicket(updatedTicket);
      setNewMessage('');
    }, {
      loading: 'Đang gửi phản hồi...',
      success: 'Đã gửi phản hồi cho người dùng.',
      error: 'Không thể gửi phản hồi.',
    });
  };

  const handleMarkResolved = async () => {
    if (!ticket) return;

    await runActionWithToast(async () => {
      const updatedTicket = await markSupportTicketResolved(ticket.id, 'Quản trị viên đã đánh dấu ticket đã xử lý.');
      setTicket(updatedTicket);
    }, {
      loading: 'Đang cập nhật trạng thái ticket...',
      success: 'Ticket đã được đánh dấu đã xử lý.',
      error: 'Không thể cập nhật trạng thái ticket.',
    });
  };

  const handleEscalate = async () => {
    if (!ticket) return;

    await runActionWithToast(async () => {
      const updatedTicket = await escalateSupportTicket(ticket.id, 'Quản trị viên nâng mức ưu tiên từ trang chi tiết.');
      setTicket(updatedTicket);
    }, {
      loading: 'Đang nâng mức ưu tiên...',
      success: 'Đã nâng mức ưu tiên ticket.',
      error: 'Không thể nâng mức ưu tiên ticket.',
    });
  };

  const handleUpdateStatus = async (status: TicketStatus) => {
    if (!ticket || status === ticket.status) return;

    await runActionWithToast(async () => {
      const updatedTicket = await updateSupportTicket(ticket.id, { status });
      setTicket(updatedTicket);
    }, {
      loading: 'Đang cập nhật trạng thái...',
      success: 'Đã cập nhật trạng thái ticket.',
      error: 'Không thể cập nhật trạng thái.',
    });
  };

  const handleUpdatePriority = async (priority: TicketPriority) => {
    if (!ticket || priority === ticket.priority) return;

    await runActionWithToast(async () => {
      const updatedTicket = await updateSupportTicket(ticket.id, { priority });
      setTicket(updatedTicket);
    }, {
      loading: 'Đang cập nhật độ ưu tiên...',
      success: 'Đã cập nhật độ ưu tiên ticket.',
      error: 'Không thể cập nhật độ ưu tiên.',
    });
  };

  const handleUpdateAssignee = async (assigneeId: string) => {
    if (!ticket) return;

    const nextAssigneeId = assigneeId === UNASSIGNED_ASSIGNEE ? null : assigneeId;
    if ((ticket.assignedToId ?? null) === nextAssigneeId) return;

    await runActionWithToast(async () => {
      const updatedTicket = await updateSupportTicket(ticket.id, { assignedTo: nextAssigneeId });
      setTicket(updatedTicket);
    }, {
      loading: 'Đang cập nhật người phụ trách...',
      success: nextAssigneeId ? 'Đã gán người phụ trách ticket.' : 'Đã bỏ gán người phụ trách ticket.',
      error: 'Không thể cập nhật người phụ trách.',
    });
  };

  const handleConfirmTicketAction = async () => {
    if (pendingTicketAction === 'resolve') {
      await handleMarkResolved();
    }

    if (pendingTicketAction === 'escalate') {
      await handleEscalate();
    }

    setPendingTicketAction(null);
  };

  if (isLoading) {
    return <div className="p-6 text-sm text-slate-500">Đang tải chi tiết ticket...</div>;
  }

  if (error || !ticket) {
    return (
      <ErrorState
        title="Không thể tải ticket"
        message={error ?? 'Ticket không tồn tại hoặc đã bị xóa.'}
        retryLabel="Tải lại"
        onRetry={() => {
          void loadTicket();
        }}
      />
    );
  }

  const priority = supportPriorityConfig[ticket.priority];
  const status = supportDetailStatusConfig[ticket.status];
  const detailContext = ticket.detailContext ?? {
    eventsCount: 0,
    ticketsCount: 0,
    relatedEventName: 'Không có sự kiện liên quan',
    channel: 'Ứng dụng web',
  };
  const assigneeOptions = [
    { value: UNASSIGNED_ASSIGNEE, label: 'Chưa gán' },
    ...assignees.map((assignee) => ({
      value: assignee.id,
      label: assignee.name,
      description: assignee.email,
    })),
  ];
  const assignedToValue = ticket.assignedToId ?? UNASSIGNED_ASSIGNEE;

  return (
    <div className="mx-auto grid w-full max-w-7xl gap-6 pb-24 xl:grid-cols-[minmax(0,1fr)_22rem]">
      <section className="min-w-0 space-y-5">
        <div className="flex flex-col gap-3 sm:flex-row sm:items-start sm:justify-between">
          <div className="min-w-0">
            <Link href="/support" className="mb-3 inline-flex items-center gap-2 text-sm font-bold text-slate-500 hover:text-amber-600">
              <ArrowLeft className="h-4 w-4" />
              Quay lại danh sách
            </Link>
            <h1 className="text-2xl font-bold tracking-tight text-on-surface">{ticket.subject}</h1>
            <p className="mt-2 max-w-2xl text-sm font-medium text-on-surface-variant">{ticket.description}</p>
          </div>
          <span className={cn('inline-flex w-fit rounded-full px-3 py-1 text-xs font-bold', status.color, 'bg-white shadow-sm')}>
            {status.label}
          </span>
        </div>

        <Card className="border border-white/70 bg-white/75 p-4 shadow-sm backdrop-blur-xl sm:p-6">
          <div className="space-y-5">
            {ticket.messages.length === 0 ? (
              <p className="text-sm text-slate-500">Ticket chưa có trao đổi nào.</p>
            ) : (
              ticket.messages.map((message) => <MessageBubble key={message.id} message={message} />)
            )}
          </div>
        </Card>

        {ticket.status !== 'closed' ? (
          <Card className="border border-white/70 bg-white/80 p-4 shadow-sm backdrop-blur-xl sm:p-5">
            <textarea
              className="min-h-28 w-full resize-none rounded-2xl border border-slate-200 bg-white px-4 py-3 text-sm text-slate-800 outline-none transition placeholder:text-slate-400 focus:border-amber-500 focus:ring-4 focus:ring-amber-500/10"
              placeholder={`Nhập phản hồi cho ${ticket.userName}...`}
              value={newMessage}
              onChange={(event) => setNewMessage(event.target.value)}
            />
            <div className="mt-4 flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
              <p className="text-xs text-slate-500">Phản hồi sẽ được lưu vào lịch sử ticket và ghi audit.</p>
              <button
                onClick={() => {
                  void handleSendReply();
                }}
                className="inline-flex h-11 items-center justify-center gap-2 rounded-xl bg-amber-500 px-5 text-sm font-bold text-white shadow-sm transition hover:bg-amber-600"
                type="button"
              >
                Gửi phản hồi
                <Send className="h-4 w-4" />
              </button>
            </div>
          </Card>
        ) : null}
      </section>

      <aside className="space-y-5 xl:sticky xl:top-6 xl:self-start">
        <Card className="border border-white/70 bg-white/80 p-5 text-center shadow-sm backdrop-blur-xl">
          <div className="mx-auto flex h-20 w-20 items-center justify-center rounded-3xl bg-slate-100 text-slate-500">
            <User className="h-10 w-10" />
          </div>
          <h2 className="mt-4 text-lg font-bold text-on-surface">{ticket.userName}</h2>
          <p className="text-sm text-slate-500">{ticket.userEmail}</p>
          <div className="mt-5 grid grid-cols-2 gap-3 border-t border-slate-100 pt-5">
            <Metric label="Sự kiện" value={detailContext.eventsCount} />
            <Metric label="Ticket" value={detailContext.ticketsCount} />
          </div>
        </Card>

        <Card className="border border-white/70 bg-white/80 p-5 shadow-sm backdrop-blur-xl">
          <h3 className="text-xs font-bold uppercase tracking-widest text-slate-500">Ngữ cảnh xử lý</h3>
          <div className="mt-4 space-y-4">
            <div>
              <p className="text-xs font-bold text-slate-500">Kênh tiếp nhận</p>
              <p className="mt-1 text-sm font-bold text-slate-900">{detailContext.channel}</p>
            </div>
            <div>
              <p className="text-xs font-bold text-slate-500">Sự kiện liên quan</p>
              <p className="mt-1 text-sm font-bold text-slate-900">{detailContext.relatedEventName}</p>
            </div>
            <div className="grid gap-3 sm:grid-cols-2 xl:grid-cols-1">
              <div>
                <p className="mb-2 text-xs font-bold text-slate-500">Trạng thái</p>
                <AdminSelect value={ticket.status} onChange={handleUpdateStatus} options={statusOptions} ariaLabel="Cập nhật trạng thái ticket" />
              </div>
              <div>
                <p className="mb-2 text-xs font-bold text-slate-500">Độ ưu tiên</p>
                <AdminSelect value={ticket.priority} onChange={handleUpdatePriority} options={priorityOptions} ariaLabel="Cập nhật độ ưu tiên ticket" />
              </div>
              <div className="sm:col-span-2 xl:col-span-1">
                <p className="mb-2 text-xs font-bold text-slate-500">Người phụ trách</p>
                <AdminSelect
                  value={assignedToValue}
                  onChange={handleUpdateAssignee}
                  options={assigneeOptions}
                  ariaLabel="Gán người phụ trách ticket"
                  disabled={isLoadingAssignees}
                />
              </div>
            </div>
            <p className="text-sm font-bold text-slate-700">
              Phụ trách hiện tại: {ticket.assignedTo ?? 'Chưa gán'}
            </p>
            <p className={cn('text-sm font-bold', priority.color)}>Ưu tiên hiện tại: {priority.label}</p>
          </div>
        </Card>

        <div className="grid gap-3 sm:grid-cols-2 xl:grid-cols-1">
          <button
            onClick={() => setPendingTicketAction('resolve')}
            className="inline-flex h-11 items-center justify-center gap-2 rounded-xl border border-white/70 bg-white/80 px-4 text-sm font-bold text-slate-700 shadow-sm transition hover:bg-white"
            type="button"
          >
            <CircleCheck className="h-4 w-4" />
            Đánh dấu đã xử lý
          </button>
          <button
            onClick={() => setPendingTicketAction('escalate')}
            className="inline-flex h-11 items-center justify-center gap-2 rounded-xl bg-red-500 px-4 text-sm font-bold text-white shadow-sm transition hover:bg-red-600"
            type="button"
          >
            <Forward className="h-4 w-4" />
            Nâng ưu tiên
          </button>
        </div>
      </aside>

      <ConfirmActionDialog
        open={pendingTicketAction !== null}
        onOpenChange={(open) => {
          if (!open) setPendingTicketAction(null);
        }}
        title={pendingTicketAction === 'resolve' ? 'Xác nhận xử lý ticket' : 'Xác nhận nâng mức ưu tiên'}
        description={
          pendingTicketAction === 'resolve'
            ? 'Ticket sẽ được chuyển sang trạng thái đã xử lý và được ghi vào audit.'
            : 'Ticket sẽ được nâng lên mức ưu tiên kế tiếp và được ghi vào audit.'
        }
        confirmLabel="Xác nhận"
        cancelLabel="Hủy"
        variant={pendingTicketAction === 'resolve' ? 'default' : 'danger'}
        onConfirm={() => {
          void handleConfirmTicketAction();
        }}
      />
    </div>
  );
}

function Metric({ label, value }: { label: string; value: number }) {
  return (
    <div>
      <p className="text-[10px] font-bold uppercase tracking-widest text-slate-400">{label}</p>
      <p className="mt-1 text-lg font-black text-slate-950">{value.toLocaleString('vi-VN')}</p>
    </div>
  );
}

function MessageBubble({ message }: { message: TicketMessage }) {
  const messageDate = new Date(message.createdAt);
  const timeText = new Intl.DateTimeFormat('vi-VN', {
    dateStyle: 'short',
    timeStyle: 'short',
  }).format(messageDate);

  if (message.isStaff) {
    return (
      <div className="flex items-start gap-3 sm:flex-row-reverse">
        <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-2xl bg-amber-500 text-white">
          <ShieldCheck className="h-5 w-5" />
        </div>
        <div className="min-w-0 sm:text-right">
          <div className="mb-1 flex flex-wrap items-center gap-2 sm:justify-end">
            <span className="text-xs font-bold text-slate-900">{message.authorName}</span>
            <span className="text-[11px] text-slate-400">{timeText}</span>
          </div>
          <div className="rounded-2xl rounded-tr-sm bg-amber-100 px-4 py-3 text-left text-sm leading-relaxed text-slate-800 shadow-sm">
            {message.content}
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="flex items-start gap-3">
      <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-2xl bg-slate-100 text-slate-500">
        <User className="h-5 w-5" />
      </div>
      <div className="min-w-0">
        <div className="mb-1 flex flex-wrap items-center gap-2">
          <span className="text-xs font-bold text-slate-900">{message.authorName}</span>
          <span className="text-[11px] text-slate-400">{timeText}</span>
        </div>
        <div className="rounded-2xl rounded-tl-sm bg-white px-4 py-3 text-sm leading-relaxed text-slate-800 shadow-sm ring-1 ring-slate-100">
          {message.content}
        </div>
      </div>
    </div>
  );
}
