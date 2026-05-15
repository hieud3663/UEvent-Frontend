import { apiRequest, apiRequestEnvelope } from '@/core/lib/api';
import type {
  AdminSupportMessageDto,
  AdminSupportStatsDto,
  AdminSupportTicketDto,
  SupportStats,
  Ticket,
  TicketCategory,
  TicketListResult,
  TicketMessage,
  TicketPriority,
  TicketStatus,
} from '../types';

export interface TicketFilters {
  status?: TicketStatus;
  priority?: TicketPriority;
  category?: TicketCategory;
  keyword?: string;
  ordering?: 'created_at' | '-created_at' | 'updated_at' | '-updated_at' | 'priority' | '-priority' | 'status' | '-status';
  page?: number;
  pageSize?: number;
}

export interface UpdateSupportTicketPayload {
  status?: TicketStatus;
  priority?: TicketPriority;
  assignedTo?: string | null;
}

export async function getTicketsPage(filters: TicketFilters = {}): Promise<TicketListResult> {
  const params = new URLSearchParams();
  params.set('page', String(filters.page ?? 1));
  params.set('page_size', String(filters.pageSize ?? 10));

  if (filters.keyword?.trim()) {
    params.set('search', filters.keyword.trim());
  }

  if (filters.status) {
    params.set('status', filters.status);
  }

  if (filters.priority) {
    params.set('priority', filters.priority);
  }

  if (filters.category) {
    params.set('category', filters.category);
  }

  if (filters.ordering) {
    params.set('ordering', filters.ordering);
  }

  const envelope = await apiRequestEnvelope<AdminSupportTicketDto[]>(`/admin/support/tickets/?${params.toString()}`);
  const tickets = envelope.data.map(mapTicket);
  const pagination = envelope.meta.pagination;

  return {
    tickets,
    total: pagination?.count ?? tickets.length,
    page: pagination?.page ?? filters.page ?? 1,
    pageSize: pagination?.page_size ?? filters.pageSize ?? tickets.length,
    totalPages: pagination?.total_pages ?? 1,
  };
}

export async function getTickets(filters: TicketFilters = {}): Promise<Ticket[]> {
  const response = await getTicketsPage({ pageSize: 100, ...filters });
  return response.tickets;
}

export async function getSupportStats(): Promise<SupportStats> {
  const response = await apiRequest<AdminSupportStatsDto>('/admin/support/tickets/statistics/');
  return {
    openTickets: response.open_tickets,
    inProgress: response.in_progress,
    resolvedToday: response.resolved_today,
    avgResponseTime: formatResponseTime(response.avg_response_minutes),
  };
}

export async function getTicketById(ticketId: string): Promise<Ticket | null> {
  const response = await apiRequest<AdminSupportTicketDto>(`/admin/support/tickets/${ticketId}/`);
  return mapTicket(response);
}

export async function sendSupportReply(ticketId: string, content: string): Promise<Ticket> {
  const response = await apiRequest<AdminSupportTicketDto>(`/admin/support/tickets/${ticketId}/messages/`, {
    method: 'POST',
    body: { content },
  });
  return mapTicket(response);
}

export async function markSupportTicketResolved(ticketId: string, note = ''): Promise<Ticket> {
  const response = await apiRequest<AdminSupportTicketDto>(`/admin/support/tickets/${ticketId}/resolve/`, {
    method: 'POST',
    body: { note },
  });
  return mapTicket(response);
}

export async function escalateSupportTicket(ticketId: string, reason = ''): Promise<Ticket> {
  const response = await apiRequest<AdminSupportTicketDto>(`/admin/support/tickets/${ticketId}/escalate/`, {
    method: 'POST',
    body: { reason },
  });
  return mapTicket(response);
}

export async function updateSupportTicket(ticketId: string, payload: UpdateSupportTicketPayload): Promise<Ticket> {
  const response = await apiRequest<AdminSupportTicketDto>(`/admin/support/tickets/${ticketId}/`, {
    method: 'PATCH',
    body: {
      status: payload.status,
      priority: payload.priority,
      assigned_to: payload.assignedTo,
    },
  });
  return mapTicket(response);
}

function mapTicket(dto: AdminSupportTicketDto): Ticket {
  const messages = dto.messages?.map(mapMessage) ?? (dto.latest_message ? [mapMessage(dto.latest_message)] : []);
  const userName = dto.user.full_name || dto.user.username;

  return {
    id: dto.id,
    subject: dto.subject,
    description: dto.description,
    category: dto.category,
    priority: dto.priority,
    status: dto.status,
    userId: dto.user.id,
    userName,
    userEmail: dto.user.email,
    assignedToId: dto.assigned_to?.id,
    assignedTo: dto.assigned_to?.full_name || dto.assigned_to?.username,
    createdAt: dto.created_at,
    updatedAt: dto.updated_at,
    messages,
    detailContext: {
      eventsCount: dto.user_context?.events_count ?? 0,
      ticketsCount: dto.user_context?.tickets_count ?? 0,
      relatedEventName: dto.user_context?.related_event_name || 'Không có sự kiện liên quan',
      channel: dto.user_context?.channel || 'Ứng dụng web',
    },
  };
}

function mapMessage(dto: AdminSupportMessageDto): TicketMessage {
  return {
    id: dto.id,
    content: dto.content,
    isStaff: dto.is_staff,
    authorName: dto.author?.full_name || dto.author?.username || 'Hệ thống',
    createdAt: dto.created_at,
  };
}

function formatResponseTime(minutes: number): string {
  if (minutes <= 0) {
    return '0 phút';
  }

  if (minutes < 60) {
    return `${Math.round(minutes)} phút`;
  }

  return `${(minutes / 60).toFixed(1).replace('.', ',')} giờ`;
}
