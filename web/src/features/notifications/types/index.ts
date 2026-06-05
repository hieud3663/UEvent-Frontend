// File: src/features/notifications/types/index.ts

export type NotificationType =
  | 'announcement'
  | 'alert'
  | 'reminder'
  | 'promotion'
  | 'invite'
  | 'ticket_confirm'
  | 'registration_confirmed'
  | 'registration_waitlisted'
  | 'new_registration'
  | 'organizer_announcement'
  | 'question_answered';
export type NotificationStatus = 'draft' | 'scheduled' | 'sent' | 'failed';
export type AudienceType = 'all' | 'students' | 'organizers' | 'admins' | 'custom';

export interface Notification {
  id: string;
  title: string;
  message: string;
  type: NotificationType;
  status: NotificationStatus;
  audience: AudienceType;
  recipientCount: number;
  scheduledAt?: string;
  sentAt?: string;
  createdAt: string;
  createdBy: string;
  performance?: {
    recipientCount: number;
    sentCount: number;
    readCount: number;
    failedCount: number;
    reachPercentage: number;
    openRate: number;
  };
}

export interface NotificationListResult {
  notifications: Notification[];
  total: number;
  page: number;
  pageSize: number;
  totalPages: number;
}

export interface NotificationStats {
  totalSent: number;
  totalSentChange?: string;
  avgOpenRate: number;
  avgOpenRateStatus?: string;
  scheduled: number;
  scheduledNote?: string;
  activeUsers: number;
  activeUsersStatus?: string;
}

export interface NotificationPaginationConfig {
  perPage: number;
  maxVisiblePages: number;
}

export interface AdminNotificationDto {
  id: string;
  title: string;
  message: string;
  type: NotificationType;
  audience_type: AudienceType;
  status: NotificationStatus;
  scheduled_at: string | null;
  sent_at: string | null;
  created_by: {
    id: string;
    username: string;
    email: string;
    full_name: string;
  } | null;
  recipient_count: number;
  sent_count: number;
  read_count: number;
  failed_count: number;
  open_rate: number;
  performance?: {
    recipient_count: number;
    sent_count: number;
    read_count: number;
    failed_count: number;
    open_rate: number;
  };
  created_at: string;
  updated_at: string;
}

export interface AdminNotificationStatsDto {
  total_sent: number;
  avg_open_rate: number;
  scheduled: number;
  active_users: number;
}

export interface AdminNotificationPaginationConfigDto {
  per_page: number;
  max_visible_pages: number;
}
