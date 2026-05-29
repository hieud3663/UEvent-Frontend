// File: src/features/support/types/index.ts

export type TicketPriority = 'low' | 'medium' | 'high' | 'urgent';
export type TicketStatus = 'open' | 'in_progress' | 'resolved' | 'closed';
export type TicketCategory = 'account' | 'event' | 'payment' | 'technical' | 'other';

export interface Ticket {
  id: string;
  subject: string;
  description: string;
  category: TicketCategory;
  priority: TicketPriority;
  status: TicketStatus;
  userId: string;
  userName: string;
  userEmail: string;
  assignedToId?: string;
  assignedTo?: string;
  createdAt: string;
  updatedAt: string;
  messages: TicketMessage[];
  detailContext?: TicketDetailContext;
}

export interface TicketListResult {
  tickets: Ticket[];
  total: number;
  page: number;
  pageSize: number;
  totalPages: number;
}

export interface TicketDetailContext {
  eventsCount: number;
  ticketsCount: number;
  relatedEventName: string;
  channel: string;
}

export interface TicketMessage {
  id: string;
  content: string;
  isStaff: boolean;
  authorName: string;
  createdAt: string;
}

export interface SupportStats {
  openTickets: number;
  inProgress: number;
  avgResponseTime: string;
  resolvedToday: number;
}

export interface AdminSupportUserDto {
  id: string;
  username: string;
  email: string;
  full_name: string;
}

export interface AdminSupportMessageDto {
  id: string;
  content: string;
  is_staff: boolean;
  author: AdminSupportUserDto | null;
  created_at: string;
  updated_at: string;
}

export interface AdminSupportTicketDto {
  id: string;
  subject: string;
  description: string;
  category: TicketCategory;
  priority: TicketPriority;
  status: TicketStatus;
  user: AdminSupportUserDto;
  assigned_to: AdminSupportUserDto | null;
  latest_message?: AdminSupportMessageDto | null;
  message_count?: number;
  messages?: AdminSupportMessageDto[];
  user_context?: {
    tickets_count: number;
    events_count: number;
    related_event_name: string;
    channel: string;
  };
  created_at: string;
  updated_at: string;
}

export interface AdminSupportStatsDto {
  open_tickets: number;
  in_progress: number;
  resolved_today: number;
  avg_response_minutes: number;
}

export type HelpCenterArticleStatus = 'draft' | 'published' | 'archived';
export type HelpCenterLocale = 'vi' | 'en';
export type LegalDocumentStatus = 'draft' | 'published' | 'archived';
export type LegalDocumentType = 'privacy_policy' | 'terms_of_service';

export interface HelpCenterCategory {
  id: string;
  name: string;
  slug: string;
  description: string;
  sortOrder: number;
  isActive: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface HelpCenterArticle {
  id: string;
  category: HelpCenterCategory;
  title: string;
  slug: string;
  summary: string;
  body: string;
  locale: HelpCenterLocale;
  status: HelpCenterArticleStatus;
  sortOrder: number;
  publishedAt: string | null;
  createdAt: string;
  updatedAt: string;
}

export interface AdminSupportCategoryDto {
  id: string;
  name: string;
  slug: string;
  description: string;
  sort_order: number;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface AdminSupportArticleDto {
  id: string;
  category: AdminSupportCategoryDto;
  title: string;
  slug: string;
  summary: string;
  body: string;
  locale: HelpCenterLocale;
  status: HelpCenterArticleStatus;
  sort_order: number;
  published_at: string | null;
  created_at: string;
  updated_at: string;
}

export interface LegalDocument {
  id: string;
  documentType: LegalDocumentType;
  title: string;
  version: string;
  summary: string;
  body: string;
  locale: HelpCenterLocale;
  status: LegalDocumentStatus;
  publishedAt: string | null;
  createdAt: string;
  updatedAt: string;
}

export interface AdminLegalDocumentDto {
  id: string;
  document_type: LegalDocumentType;
  title: string;
  version: string;
  summary: string;
  body: string;
  locale: HelpCenterLocale;
  status: LegalDocumentStatus;
  published_at: string | null;
  created_at: string;
  updated_at: string;
}
