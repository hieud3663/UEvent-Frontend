// File: src/features/events/types/index.ts

export interface Event {
  id: string;
  title: string;
  organizer: string;
  date: string;
  image?: string;
  coverImageUrl?: string;
  moderationNote?: string;
  organizerTag?: string;
  status: 'draft' | 'pending' | 'approved' | 'active' | 'finished' | 'cancelled' | 'rejected' | 'archived';
  reportType?: 'safety' | 'copyright' | 'spam' | 'other';
  reportSnippet?: string;
  category: string;
  description?: string;
  location?: string;
  maxCapacity?: number | null;
  startAt?: string;
  endAt?: string;
  visibility?: 'public' | 'private';
  moderationLogs?: EventModerationLog[];
}

export type EventStatus = Event['status'];
export type ReportType = Event['reportType'];

export interface EventModerationPulse {
  avgResponseHours: number;
  queueSize: number;
  targetLabel: string;
  targetProgress: number;
}

export interface EventModerationActivity {
  id: string;
  title: string;
  description: string;
  type: 'approved' | 'declined' | 'flagged';
}

export interface EventPolicyHandbook {
  title: string;
  description: string;
  ctaLabel: string;
  ctaHref: string;
}

export interface EventStats {
  urgentReports: number;
  pendingApproval: number;
  approvedToday: number;
  totalEvents: number;
}

export interface EventListResult {
  events: Event[];
  total: number;
  page: number;
  pageSize: number;
  totalPages: number;
}

export interface EventModerationLog {
  id: string;
  reportType?: ReportType;
  action: string;
  reason: string;
  createdAt: string;
  adminUser?: {
    id: string;
    username: string;
    email: string;
    fullName: string;
  } | null;
}

export interface AdminEventDto {
  id: string;
  title: string;
  slug: string;
  description: string;
  visibility: 'public' | 'private';
  status: EventStatus;
  category: {
    id: string;
    name: string;
    slug: string;
    color: string | null;
    icon: string | null;
  };
  created_by: {
    id: string;
    username: string;
    email: string;
    full_name: string;
  };
  room: {
    id: string;
    name: string;
    code: string;
    building_name: string;
    campus_name: string;
  } | null;
  start_at: string;
  end_at: string;
  max_capacity: number | null;
  location_snapshot: string | null;
  cover_image_url: string | null;
  latest_report_type: ReportType | null;
  latest_moderation_reason: string;
  moderation_logs?: AdminModerationLogDto[];
}

export interface AdminModerationLogDto {
  id: string;
  admin_user: {
    id: string;
    username: string;
    email: string;
    full_name: string;
  } | null;
  report_type: ReportType | null;
  action: string;
  reason: string;
  created_at: string;
}

export interface AdminEventStatsDto {
  total_events: number;
  pending_approval: number;
  approved_today: number;
  reported_events: number;
}

export interface AdminEventModerationPulseDto {
  avg_response_hours: number;
  queue_size: number;
  target_label: string;
  target_progress: number;
}

export interface AdminEventModerationActivityDto {
  id: string;
  event_id: string;
  title: string;
  description: string;
  type: EventModerationActivity['type'];
  created_at: string;
}

export interface AdminEventPolicyHandbookDto {
  title: string;
  description: string;
  cta_label: string;
  cta_href: string;
}
