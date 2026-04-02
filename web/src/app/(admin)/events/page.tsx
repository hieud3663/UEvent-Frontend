// File: src/app/(admin)/events/page.tsx
'use client';

import { useEffect, useMemo, useState } from 'react';
import type { ElementType } from 'react';
import { AlertTriangle, CheckCircle, Filter, MoreHorizontal, Calendar, User, TrendingDown, Flag, XCircle } from 'lucide-react';
import { Card, ConfirmActionDialog } from '@/core/components';
import {
  getEvents,
  getEventModerationActivities,
  getEventModerationPulse,
  getEventPolicyHandbook,
  getEventStats,
  moderateEventStatus,
} from '@/features/events/services/events.service';
import type {
  Event,
  EventModerationActivity,
  EventModerationPulse,
  EventPolicyHandbook,
  ReportType,
} from '@/features/events/types';
import Image from 'next/image';
import Link from 'next/link';
import { toast } from 'sonner';
import { runActionWithToast } from '@/core/lib/runActionWithToast';

const reportTypeLabels: Record<NonNullable<ReportType>, string> = {
  safety: 'Safety Concern',
  copyright: 'Copyright Claim',
  spam: 'Spam Report',
  other: 'Other Issue',
};

const moderationActivityTypeConfig: Record<
  EventModerationActivity['type'],
  { icon: ElementType; iconColor: string; iconBg: string }
> = {
  approved: { icon: CheckCircle, iconColor: 'text-green-600', iconBg: 'bg-green-100' },
  declined: { icon: XCircle, iconColor: 'text-error', iconBg: 'bg-error/10' },
  flagged: { icon: Flag, iconColor: 'text-blue-600', iconBg: 'bg-blue-100' },
};

export default function EventsPage() {
  const [events, setEvents] = useState<Event[]>([]);
  const [stats, setStats] = useState<Awaited<ReturnType<typeof getEventStats>> | null>(null);
  const [moderationPulse, setModerationPulse] = useState<EventModerationPulse | null>(null);
  const [moderationActivities, setModerationActivities] = useState<EventModerationActivity[]>([]);
  const [policyHandbook, setPolicyHandbook] = useState<EventPolicyHandbook | null>(null);
  const [pendingModerationAction, setPendingModerationAction] = useState<
    { type: 'approve' | 'decline'; eventId: string; title: string } | null
  >(null);

  useEffect(() => {
    let isMounted = true;

    async function loadEventsPageData() {
      const [eventsResponse, eventsStats, pulse, activities, handbook] = await Promise.all([
        getEvents(),
        getEventStats(),
        getEventModerationPulse(),
        getEventModerationActivities(),
        getEventPolicyHandbook(),
      ]);

      if (!isMounted) {
        return;
      }

      setEvents(eventsResponse);
      setStats(eventsStats);
      setModerationPulse(pulse);
      setModerationActivities(activities);
      setPolicyHandbook(handbook);
    }

    void loadEventsPageData();

    return () => {
      isMounted = false;
    };
  }, []);

  const reportedEvents = useMemo(
    () => events.filter((item) => item.status === 'reported').slice(0, 2),
    [events]
  );

  const pendingEvents = useMemo(
    () => events.filter((item) => item.status === 'pending').slice(0, 1),
    [events]
  );

  const handleDecline = async (eventId: string, title: string) => {
    const previousEvents = events;
    setEvents((prev) => prev.map((item) => (item.id === eventId ? { ...item, status: 'rejected' } : item)));

    try {
      await runActionWithToast(() => moderateEventStatus(eventId, 'rejected'), {
        loading: `Declining ${title}...`,
        success: `Declined event: ${title}`,
        error: `Failed to decline ${title}.`,
      });
    } catch {
      setEvents(previousEvents);
    }
  };

  const handleApprove = async (eventId: string, title: string) => {
    const previousEvents = events;
    setEvents((prev) => prev.map((item) => (item.id === eventId ? { ...item, status: 'approved' } : item)));

    try {
      await runActionWithToast(() => moderateEventStatus(eventId, 'approved'), {
        loading: `Approving ${title}...`,
        success: `Approved event: ${title}`,
        error: `Failed to approve ${title}.`,
      });
    } catch {
      setEvents(previousEvents);
    }
  };

  const handleFilter = async () => {
    await runActionWithToast(async () => Promise.resolve(), {
      loading: 'Preparing filter panel...',
      success: 'Filter panel is ready.',
      error: 'Failed to open filter panel.',
    });
  };

  const handleQuickAudit = async () => {
    await runActionWithToast(async () => Promise.resolve(), {
      loading: 'Starting quick audit...',
      success: 'Quick audit started for moderation queue.',
      error: 'Failed to start quick audit.',
    });
  };

  const handleApproveRequest = (eventId: string, title: string) => {
    setPendingModerationAction({ type: 'approve', eventId, title });
  };

  const handleDeclineRequest = (eventId: string, title: string) => {
    setPendingModerationAction({ type: 'decline', eventId, title });
  };

  const handleConfirmModeration = async () => {
    if (!pendingModerationAction) {
      return;
    }

    const currentAction = pendingModerationAction;
    setPendingModerationAction(null);

    if (currentAction.type === 'approve') {
      await handleApprove(currentAction.eventId, currentAction.title);
      return;
    }

    await handleDecline(currentAction.eventId, currentAction.title);
  };

  if (!stats || !moderationPulse || !policyHandbook) {
    return <div className="p-6 text-sm text-slate-500">Loading events...</div>;
  }

  return (
    <div className="space-y-8">
      {/* Header Section */}
      <div className="flex justify-between items-end">
        <div>
          <h2 className="text-2xl font-bold tracking-tight text-on-surface">
            Event Moderation
          </h2>
          <p className="text-on-surface-variant text-sm mt-1">
            Review pending approvals and reported policy violations.
          </p>
        </div>
        <div className="flex gap-2">
          <button 
            type="button"
            onClick={() => {
              void handleFilter();
            }}
            className="px-4 py-2 rounded-full glass-card text-xs font-bold uppercase tracking-wider flex items-center gap-2 border border-white/40"
          >
            <Filter className="w-4 h-4" />
            Filter
          </button>
          <button 
            type="button"
            onClick={() => {
              void handleQuickAudit();
            }}
            className="px-4 py-2 rounded-full bg-primary-container text-on-primary-container text-xs font-bold uppercase tracking-wider"
          >
            Quick Audit
          </button>
        </div>
      </div>

      {/* Moderation Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
        {/* Main Content */}
        <div className="lg:col-span-8 space-y-4">
          {/* Urgent Reports Section */}
          <h3 className="text-xs font-bold uppercase tracking-widest text-error flex items-center gap-2 mb-4">
            <AlertTriangle className="w-4 h-4" />
            Urgent Violations ({reportedEvents.length})
          </h3>

          {reportedEvents.map((event) => (
            <ReportedEventCard
              key={event.id}
              event={event}
              onDecline={handleDeclineRequest}
            />
          ))}

          {/* Pending Approval Section */}
          <h3 className="text-xs font-bold uppercase tracking-widest text-slate-400 flex items-center gap-2 pt-6 mb-4">
            <CheckCircle className="w-4 h-4" />
            Pending Approval ({stats.pendingApproval})
          </h3>

          {pendingEvents.map((event) => (
            <PendingEventCard
              key={event.id}
              event={event}
              onApprove={handleApproveRequest}
            />
          ))}
        </div>

        {/* Right Column: Stats & Queue */}
        <div className="lg:col-span-4 space-y-6">
          {/* Moderation Pulse Card */}
          <Card className="glass-card border-none rounded-[32px] p-6">
            <h3 className="text-sm font-bold text-on-surface mb-4">Moderation Pulse</h3>
            <div className="grid grid-cols-2 gap-4">
              <div className="bg-white/50 p-4 rounded-2xl border border-white/40">
                <p className="text-[10px] font-bold text-slate-500 uppercase tracking-wider">Avg Response</p>
                <p className="text-2xl font-black text-on-surface mt-1">{moderationPulse.avgResponseHours}h</p>
              </div>
              <div className="bg-white/50 p-4 rounded-2xl border border-white/40">
                <p className="text-[10px] font-bold text-slate-500 uppercase tracking-wider">Queue Size</p>
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
            <h3 className="text-sm font-bold text-on-surface mb-6">Recent Activities</h3>
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
        title={pendingModerationAction?.type === 'approve' ? 'Xác nhận phê duyệt sự kiện' : 'Xác nhận từ chối sự kiện'}
        description={pendingModerationAction
          ? pendingModerationAction.type === 'approve'
            ? `Bạn sắp phê duyệt sự kiện ${pendingModerationAction.title}. Hành động này sẽ cập nhật trạng thái kiểm duyệt.`
            : `Bạn sắp từ chối sự kiện ${pendingModerationAction.title}. Hành động này có thể không hoàn tác.`
          : 'Xác nhận hành động kiểm duyệt.'}
        confirmLabel="Xác nhận"
        cancelLabel="Hủy"
        variant={pendingModerationAction?.type === 'decline' ? 'danger' : 'default'}
        onConfirm={() => {
          void handleConfirmModeration();
        }}
      />
    </div>
  );
}

function ReportedEventCard({
  event,
  onDecline,
}: {
  event: Event;
  onDecline: (eventId: string, title: string) => void;
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
              <span className="font-bold">Report Snippet:</span> &quot;{event.reportSnippet}&quot;
            </p>
          </div>
        )}

        <div className="mt-auto pt-4 flex gap-3">
          <Link href={`/events/${event.id}`} className="flex-grow md:flex-none px-6 py-2 bg-on-surface text-surface-container-lowest rounded-xl text-xs font-bold hover:opacity-90 transition-opacity whitespace-nowrap text-center">
            View Event
          </Link>
          <button
            type="button"
            onClick={() => {
              void onDecline(event.id, event.title);
            }}
            className="flex-grow md:flex-none px-6 py-2 bg-error text-white rounded-xl text-xs font-bold hover:bg-error/90 transition-opacity"
          >
            Decline
          </button>
          <button
            type="button"
            onClick={() => toast.info(`More actions for ${event.title} coming soon.`)}
            className="p-2 glass-card rounded-xl text-on-surface-variant hover:text-on-surface transition-colors border border-white/40"
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
  onApprove,
}: {
  event: Event;
  onApprove: (eventId: string, title: string) => void;
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
          {event.moderationNote ?? 'No additional moderation context provided for this event.'}
        </p>

        <div className="mt-auto pt-4 flex gap-3">
          <button
            type="button"
            onClick={() => {
              void onApprove(event.id, event.title);
            }}
            className="flex-grow md:flex-none px-6 py-2 bg-amber-500 text-white rounded-xl text-xs font-bold hover:bg-amber-600 transition-colors"
          >
            Approve
          </button>
          <Link href={`/events/${event.id}`} className="flex-grow md:flex-none px-6 py-2 glass-card text-on-surface rounded-xl text-xs font-bold border border-white/40 text-center">
            Review Details
          </Link>
        </div>
      </div>
    </Card>
  );
}
