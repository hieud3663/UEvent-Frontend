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
  status: 'pending' | 'approved' | 'rejected' | 'reported';
  reportType?: 'safety' | 'copyright' | 'spam' | 'other';
  reportSnippet?: string;
  category: string;
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
