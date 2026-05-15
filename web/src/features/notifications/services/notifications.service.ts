import { apiExport, apiRequest, apiRequestEnvelope } from '@/core/lib/api';
import type {
  AdminNotificationDto,
  AdminNotificationPaginationConfigDto,
  AdminNotificationStatsDto,
  AudienceType,
  Notification,
  NotificationListResult,
  NotificationPaginationConfig,
  NotificationStatus,
  NotificationStats,
  NotificationType,
} from '../types';

export interface NotificationFilters {
  status?: NotificationStatus;
  type?: NotificationType;
  audience?: AudienceType;
  keyword?: string;
  ordering?: 'created_at' | '-created_at' | 'scheduled_at' | '-scheduled_at' | 'sent_at' | '-sent_at' | 'status' | '-status';
  page?: number;
  pageSize?: number;
}

export type NotificationExportFormat = 'csv' | 'xlsx';

export interface NotificationMutationPayload {
  title: string;
  message: string;
  audience: AudienceType;
  type?: NotificationType;
  scheduleType: 'now' | 'later';
  scheduleDate?: string;
  scheduleTime?: string;
}

export async function getNotificationsPage(filters: NotificationFilters = {}): Promise<NotificationListResult> {
  const params = new URLSearchParams();
  params.set('page', String(filters.page ?? 1));
  params.set('page_size', String(filters.pageSize ?? 10));

  if (filters.status) {
    params.set('status', filters.status);
  }

  if (filters.type) {
    params.set('type', filters.type);
  }

  if (filters.audience) {
    params.set('audience_type', filters.audience);
  }

  if (filters.keyword?.trim()) {
    params.set('search', filters.keyword.trim());
  }

  if (filters.ordering) {
    params.set('ordering', filters.ordering);
  }

  const envelope = await apiRequestEnvelope<AdminNotificationDto[]>(`/admin/notifications/?${params.toString()}`);
  const notifications = envelope.data.map(mapNotification);
  const pagination = envelope.meta.pagination;

  return {
    notifications,
    total: pagination?.count ?? notifications.length,
    page: pagination?.page ?? filters.page ?? 1,
    pageSize: pagination?.page_size ?? filters.pageSize ?? notifications.length,
    totalPages: pagination?.total_pages ?? 1,
  };
}

export async function getNotifications(filters: NotificationFilters = {}): Promise<Notification[]> {
  const response = await getNotificationsPage({ pageSize: 100, ...filters });
  return response.notifications;
}

export async function getNotificationStats(): Promise<NotificationStats> {
  const response = await apiRequest<AdminNotificationStatsDto>('/admin/notifications/statistics/');
  return {
    totalSent: response.total_sent,
    avgOpenRate: response.avg_open_rate,
    scheduled: response.scheduled,
    activeUsers: response.active_users,
  };
}

export async function getNotificationPaginationConfig(): Promise<NotificationPaginationConfig> {
  const response = await apiRequest<AdminNotificationPaginationConfigDto>('/admin/notifications/pagination-config/');
  return {
    perPage: response.per_page,
    maxVisiblePages: response.max_visible_pages,
  };
}

export async function saveNotificationDraft(payload: NotificationMutationPayload): Promise<Notification> {
  const response = await apiRequest<AdminNotificationDto>('/admin/notifications/', {
    method: 'POST',
    body: {
      title: payload.title,
      message: payload.message,
      type: payload.type ?? 'announcement',
      audience_type: payload.audience,
      status: payload.scheduleType === 'later' ? 'scheduled' : 'draft',
      scheduled_at: buildScheduledAt(payload),
    },
  });
  return mapNotification(response);
}

export async function getNotificationById(notificationId: string): Promise<Notification> {
  const response = await apiRequest<AdminNotificationDto>(`/admin/notifications/${notificationId}/`);
  return mapNotification(response);
}

export async function updateNotificationById(
  notificationId: string,
  payload: NotificationMutationPayload
): Promise<Notification> {
  const response = await apiRequest<AdminNotificationDto>(`/admin/notifications/${notificationId}/`, {
    method: 'PATCH',
    body: {
      title: payload.title,
      message: payload.message,
      type: payload.type ?? 'announcement',
      audience_type: payload.audience,
      status: payload.scheduleType === 'later' ? 'scheduled' : 'draft',
      scheduled_at: buildScheduledAt(payload),
    },
  });
  return mapNotification(response);
}

export async function publishNotification(payload: NotificationMutationPayload): Promise<Notification> {
  const notification = await saveNotificationDraft({
    ...payload,
    scheduleType: payload.scheduleType === 'later' ? 'later' : 'now',
  });

  if (payload.scheduleType === 'later') {
    return notification;
  }

  const response = await apiRequest<AdminNotificationDto>(`/admin/notifications/${notification.id}/publish/`, {
    method: 'POST',
    body: {},
  });
  return mapNotification(response);
}

export async function publishNotificationById(notificationId: string): Promise<Notification> {
  const response = await apiRequest<AdminNotificationDto>(`/admin/notifications/${notificationId}/publish/`, {
    method: 'POST',
    body: {},
  });
  return mapNotification(response);
}

export async function deleteNotificationById(notificationId: string): Promise<void> {
  await apiRequest(`/admin/notifications/${notificationId}/`, {
    method: 'DELETE',
  });
}

export async function exportNotificationsHistory(
  filters: NotificationFilters = {},
  format: NotificationExportFormat = 'csv'
): Promise<void> {
  const params = new URLSearchParams();
  if (filters.status) params.set('status', filters.status);
  if (filters.type) params.set('type', filters.type);
  if (filters.audience) params.set('audience_type', filters.audience);
  params.set('export_format', format);

  const { blob, filename } = await apiExport(`/admin/notifications/export/?${params.toString()}`);
  const url = URL.createObjectURL(blob);
  const link = document.createElement('a');
  link.href = url;
  link.download = filename;
  link.click();
  URL.revokeObjectURL(url);
}

function mapNotification(dto: AdminNotificationDto): Notification {
  const openRate = dto.performance?.open_rate ?? dto.open_rate ?? 0;
  const recipientCount = dto.performance?.recipient_count ?? dto.recipient_count ?? 0;
  const sentCount = dto.performance?.sent_count ?? dto.sent_count ?? 0;

  return {
    id: dto.id,
    title: dto.title,
    message: dto.message,
    type: dto.type,
    status: dto.status,
    audience: dto.audience_type,
    recipientCount,
    scheduledAt: dto.scheduled_at ?? undefined,
    sentAt: dto.sent_at ?? undefined,
    createdAt: dto.created_at,
    createdBy: dto.created_by?.full_name || dto.created_by?.username || 'Hệ thống',
    performance:
      dto.status === 'sent'
        ? {
            recipientCount,
            sentCount,
            readCount: dto.performance?.read_count ?? dto.read_count ?? 0,
            failedCount: dto.performance?.failed_count ?? dto.failed_count ?? 0,
            reachPercentage: recipientCount ? Math.round((sentCount / recipientCount) * 100) : 0,
            openRate,
          }
        : undefined,
  };
}

function buildScheduledAt(payload: NotificationMutationPayload): string | null {
  if (payload.scheduleType !== 'later' || !payload.scheduleDate || !payload.scheduleTime) {
    return null;
  }

  return new Date(`${payload.scheduleDate}T${payload.scheduleTime}:00`).toISOString();
}
