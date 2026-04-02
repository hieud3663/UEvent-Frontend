// File: src/features/notifications/types/index.ts

export type NotificationType = 'announcement' | 'alert' | 'reminder' | 'promotion';
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
    reachPercentage: number;
    openRate: number;
  };
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
