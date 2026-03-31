// File: src/features/events/types/index.ts

export interface Event {
  id: string;
  title: string;
  organizer: string;
  date: string;
  image?: string;
  status: 'pending' | 'approved' | 'rejected' | 'reported';
  reportType?: 'safety' | 'copyright' | 'spam' | 'other';
  reportSnippet?: string;
  category: string;
}

export type EventStatus = Event['status'];
export type ReportType = Event['reportType'];
