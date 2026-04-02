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
  assignedTo?: string;
  createdAt: string;
  updatedAt: string;
  messages: TicketMessage[];
  detailContext?: TicketDetailContext;
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
