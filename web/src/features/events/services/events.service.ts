import { apiRequest, apiRequestEnvelope } from '@/core/lib/api';
import type {
  AdminEventDto,
  AdminEventModerationActivityDto,
  AdminEventModerationPulseDto,
  AdminEventPolicyHandbookDto,
  AdminEventStatsDto,
  AdminModerationLogDto,
  Event,
  EventListResult,
  EventModerationActivity,
  EventModerationLog,
  EventModerationPulse,
  EventPolicyHandbook,
  EventStats,
  EventStatus,
  ReportType,
} from '../types';

export interface EventFilters {
  status?: EventStatus | 'reported';
  keyword?: string;
  category?: string;
  visibility?: 'public' | 'private';
  ordering?: 'start_at' | '-start_at' | 'created_at' | '-created_at' | 'status' | '-status';
  page?: number;
  pageSize?: number;
}

export async function getEventsPage(filters: EventFilters = {}): Promise<EventListResult> {
  const params = new URLSearchParams();
  params.set('page', String(filters.page ?? 1));
  params.set('page_size', String(filters.pageSize ?? 10));

  if (filters.keyword?.trim()) {
    params.set('search', filters.keyword.trim());
  }

  if (filters.status && filters.status !== 'reported') {
    params.set('status', filters.status);
  }

  if (filters.status === 'reported') {
    params.set('reported', 'true');
  }

  if (filters.category) {
    params.set('category', filters.category);
  }

  if (filters.visibility) {
    params.set('visibility', filters.visibility);
  }

  if (filters.ordering) {
    params.set('ordering', filters.ordering);
  }

  const envelope = await apiRequestEnvelope<AdminEventDto[]>(`/admin/events/?${params.toString()}`);
  const events = envelope.data.map(mapEvent);

  const pagination = envelope.meta.pagination;
  return {
    events,
    total: pagination?.count ?? events.length,
    page: pagination?.page ?? filters.page ?? 1,
    pageSize: pagination?.page_size ?? filters.pageSize ?? events.length,
    totalPages: pagination?.total_pages ?? 1,
  };
}

export async function getEvents(filters: EventFilters = {}): Promise<Event[]> {
  const response = await getEventsPage({ pageSize: 100, ...filters });
  return response.events;
}

export async function getEventStats(): Promise<EventStats> {
  const response = await apiRequest<AdminEventStatsDto>('/admin/events/statistics/');
  return {
    urgentReports: response.reported_events,
    pendingApproval: response.pending_approval,
    approvedToday: response.approved_today,
    totalEvents: response.total_events,
  };
}

export async function getEventModerationPulse(): Promise<EventModerationPulse> {
  const response = await apiRequest<AdminEventModerationPulseDto>('/admin/events/moderation-pulse/');
  return {
    avgResponseHours: response.avg_response_hours,
    queueSize: response.queue_size,
    targetLabel: translateModerationTargetLabel(response.target_label),
    targetProgress: response.target_progress,
  };
}

export async function getEventModerationActivities(): Promise<EventModerationActivity[]> {
  const response = await apiRequest<AdminEventModerationActivityDto[]>('/admin/events/moderation-activities/');
  return response.map((item) => ({
    id: item.id,
    title: translateModerationActivityTitle(item.title),
    description: translateModerationActivityDescription(item.description),
    type: item.type,
  }));
}

export async function getEventPolicyHandbook(): Promise<EventPolicyHandbook> {
  const response = await apiRequest<AdminEventPolicyHandbookDto>('/admin/events/policy-handbook/');
  return {
    title: 'Sổ tay chính sách kiểm duyệt',
    description: 'Xem lại quy định phê duyệt sự kiện, tiêu chuẩn an toàn và quy trình xử lý vi phạm.',
    ctaLabel: 'Mở tài liệu',
    ctaHref: response.cta_href,
  };
}

export async function moderateEventStatus(
  eventId: string,
  status: Extract<EventStatus, 'approved' | 'rejected' | 'cancelled' | 'archived' | 'active'>,
  reason = ''
): Promise<Event> {
  const response = await apiRequest<AdminEventDto>(`/admin/events/${eventId}/status/`, {
    method: 'PATCH',
    body: { status, reason },
  });
  return mapEvent(response);
}

export async function getEventById(eventId: string): Promise<Event> {
  const response = await apiRequest<AdminEventDto>(`/admin/events/${eventId}/`);
  return mapEvent(response);
}

export async function deleteEventById(eventId: string, reason = 'Quản trị viên đã xóa sự kiện từ bảng điều khiển web.'): Promise<void> {
  await apiRequest(`/admin/events/${eventId}/`, {
    method: 'DELETE',
    body: { reason },
  });
}

function mapEvent(dto: AdminEventDto): Event {
  const reportType = normalizeReportType(dto.latest_report_type);

  return {
    id: dto.id,
    title: dto.title,
    organizer: dto.created_by.full_name || dto.created_by.username,
    date: formatEventDate(dto.start_at),
    coverImageUrl: normalizeCoverImageUrl(dto.cover_image_url),
    moderationNote: dto.latest_moderation_reason || dto.description,
    organizerTag: dto.created_by.email,
    status: dto.status,
    reportType,
    reportSnippet: dto.latest_moderation_reason || undefined,
    category: dto.category.name,
    description: dto.description,
    location: dto.location_snapshot ?? formatRoom(dto.room),
    maxCapacity: dto.max_capacity,
    startAt: dto.start_at,
    endAt: dto.end_at,
    visibility: dto.visibility,
    moderationLogs: dto.moderation_logs?.map(mapModerationLog) ?? [],
  };
}

function normalizeCoverImageUrl(value: string | null): string | undefined {
  if (!value) return undefined;

  try {
    const url = new URL(value);
    const decodedPath = decodeURIComponent(url.pathname);
    const hasNestedAbsoluteUrl = decodedPath.includes('://');

    if (url.hostname.endsWith('amazonaws.com') && hasNestedAbsoluteUrl) {
      return undefined;
    }
  } catch {
    return undefined;
  }

  return value;
}

function mapModerationLog(dto: AdminModerationLogDto): EventModerationLog {
  return {
    id: dto.id,
    reportType: normalizeReportType(dto.report_type),
    action: dto.action,
    reason: dto.reason,
    createdAt: dto.created_at,
    adminUser: dto.admin_user
      ? {
          id: dto.admin_user.id,
          username: dto.admin_user.username,
          email: dto.admin_user.email,
          fullName: dto.admin_user.full_name,
        }
      : null,
  };
}

function normalizeReportType(value: ReportType | string | null): ReportType | undefined {
  if (value === 'safety' || value === 'copyright' || value === 'spam' || value === 'other') {
    return value;
  }

  return undefined;
}

function formatEventDate(value: string): string {
  return new Intl.DateTimeFormat('vi-VN', {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
  }).format(new Date(value));
}

function translateModerationTargetLabel(value: string): string {
  return value.replace('Target:', 'Mục tiêu:').replace('h', ' giờ');
}

function translateModerationActivityTitle(value: string): string {
  return value
    .replace(' approved', ' đã được phê duyệt')
    .replace(' declined', ' đã bị từ chối')
    .replace(' flagged', ' đã được gắn cờ');
}

function translateModerationActivityDescription(value: string): string {
  if (value.startsWith('Report type:')) {
    return value.replace('Report type:', 'Loại báo cáo:');
  }

  if (value.startsWith('Approved by ')) {
    return value.replace('Approved by ', 'Đã được phê duyệt bởi ');
  }

  if (value === 'Rejected by moderation team') {
    return 'Đã bị đội kiểm duyệt từ chối';
  }

  return value;
}

function formatRoom(room: AdminEventDto['room']): string | undefined {
  if (!room) return undefined;

  return [room.name, room.building_name, room.campus_name].filter(Boolean).join(', ');
}
