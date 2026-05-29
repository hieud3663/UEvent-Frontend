import { apiRequest, apiRequestEnvelope } from '@/core/lib/api';
import type {
  AdminLegalDocumentDto,
  AdminSupportArticleDto,
  AdminSupportCategoryDto,
  AdminSupportMessageDto,
  AdminSupportStatsDto,
  AdminSupportTicketDto,
  HelpCenterArticle,
  HelpCenterArticleStatus,
  HelpCenterCategory,
  HelpCenterLocale,
  LegalDocument,
  LegalDocumentStatus,
  LegalDocumentType,
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

export interface HelpCenterArticleFilters {
  status?: HelpCenterArticleStatus;
  locale?: HelpCenterLocale;
  categoryId?: string;
}

export interface SaveHelpCenterCategoryPayload {
  name: string;
  slug: string;
  description: string;
  sortOrder: number;
  isActive: boolean;
}

export interface SaveHelpCenterArticlePayload {
  categoryId: string;
  title: string;
  slug: string;
  summary: string;
  body: string;
  locale: HelpCenterLocale;
  status: HelpCenterArticleStatus;
  sortOrder: number;
}

export interface LegalDocumentFilters {
  documentType?: LegalDocumentType;
  status?: LegalDocumentStatus;
  locale?: HelpCenterLocale;
}

export interface SaveLegalDocumentPayload {
  documentType: LegalDocumentType;
  title: string;
  version: string;
  summary: string;
  body: string;
  locale: HelpCenterLocale;
  status: LegalDocumentStatus;
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

export async function getHelpCenterCategories(): Promise<HelpCenterCategory[]> {
  const response = await apiRequest<AdminSupportCategoryDto[]>('/admin/support/help-center/categories/');
  return response.map(mapHelpCenterCategory);
}

export async function createHelpCenterCategory(payload: SaveHelpCenterCategoryPayload): Promise<HelpCenterCategory> {
  const response = await apiRequest<AdminSupportCategoryDto>('/admin/support/help-center/categories/', {
    method: 'POST',
    body: mapCategoryPayload(payload),
  });
  return mapHelpCenterCategory(response);
}

export async function updateHelpCenterCategory(
  categoryId: string,
  payload: SaveHelpCenterCategoryPayload
): Promise<HelpCenterCategory> {
  const response = await apiRequest<AdminSupportCategoryDto>(`/admin/support/help-center/categories/${categoryId}/`, {
    method: 'PATCH',
    body: mapCategoryPayload(payload),
  });
  return mapHelpCenterCategory(response);
}

export async function deleteHelpCenterCategory(categoryId: string): Promise<void> {
  await apiRequest<void>(`/admin/support/help-center/categories/${categoryId}/`, {
    method: 'DELETE',
  });
}

export async function getHelpCenterArticles(filters: HelpCenterArticleFilters = {}): Promise<HelpCenterArticle[]> {
  const params = new URLSearchParams();

  if (filters.status) {
    params.set('status', filters.status);
  }

  if (filters.locale) {
    params.set('locale', filters.locale);
  }

  if (filters.categoryId) {
    params.set('category', filters.categoryId);
  }

  const query = params.toString();
  const response = await apiRequest<AdminSupportArticleDto[]>(
    `/admin/support/help-center/articles/${query ? `?${query}` : ''}`
  );
  return response.map(mapHelpCenterArticle);
}

export async function createHelpCenterArticle(payload: SaveHelpCenterArticlePayload): Promise<HelpCenterArticle> {
  const response = await apiRequest<AdminSupportArticleDto>('/admin/support/help-center/articles/', {
    method: 'POST',
    body: mapArticlePayload(payload),
  });
  return mapHelpCenterArticle(response);
}

export async function updateHelpCenterArticle(
  articleId: string,
  payload: SaveHelpCenterArticlePayload
): Promise<HelpCenterArticle> {
  const response = await apiRequest<AdminSupportArticleDto>(`/admin/support/help-center/articles/${articleId}/`, {
    method: 'PATCH',
    body: mapArticlePayload(payload),
  });
  return mapHelpCenterArticle(response);
}

export async function deleteHelpCenterArticle(articleId: string): Promise<void> {
  await apiRequest<void>(`/admin/support/help-center/articles/${articleId}/`, {
    method: 'DELETE',
  });
}

export async function publishHelpCenterArticle(articleId: string): Promise<HelpCenterArticle> {
  const response = await apiRequest<AdminSupportArticleDto>(
    `/admin/support/help-center/articles/${articleId}/publish/`,
    { method: 'POST' }
  );
  return mapHelpCenterArticle(response);
}

export async function archiveHelpCenterArticle(articleId: string): Promise<HelpCenterArticle> {
  const response = await apiRequest<AdminSupportArticleDto>(
    `/admin/support/help-center/articles/${articleId}/archive/`,
    { method: 'POST' }
  );
  return mapHelpCenterArticle(response);
}

export async function getLegalDocuments(filters: LegalDocumentFilters = {}): Promise<LegalDocument[]> {
  const params = new URLSearchParams();

  if (filters.documentType) {
    params.set('document_type', filters.documentType);
  }

  if (filters.status) {
    params.set('status', filters.status);
  }

  if (filters.locale) {
    params.set('locale', filters.locale);
  }

  const query = params.toString();
  const response = await apiRequest<AdminLegalDocumentDto[]>(
    `/admin/support/legal-documents/${query ? `?${query}` : ''}`
  );
  return response.map(mapLegalDocument);
}

export async function createLegalDocument(payload: SaveLegalDocumentPayload): Promise<LegalDocument> {
  const response = await apiRequest<AdminLegalDocumentDto>('/admin/support/legal-documents/', {
    method: 'POST',
    body: mapLegalDocumentPayload(payload),
  });
  return mapLegalDocument(response);
}

export async function updateLegalDocument(
  documentId: string,
  payload: SaveLegalDocumentPayload
): Promise<LegalDocument> {
  const response = await apiRequest<AdminLegalDocumentDto>(`/admin/support/legal-documents/${documentId}/`, {
    method: 'PATCH',
    body: mapLegalDocumentPayload(payload),
  });
  return mapLegalDocument(response);
}

export async function deleteLegalDocument(documentId: string): Promise<void> {
  await apiRequest<void>(`/admin/support/legal-documents/${documentId}/`, {
    method: 'DELETE',
  });
}

export async function publishLegalDocument(documentId: string): Promise<LegalDocument> {
  const response = await apiRequest<AdminLegalDocumentDto>(`/admin/support/legal-documents/${documentId}/publish/`, {
    method: 'POST',
  });
  return mapLegalDocument(response);
}

export async function archiveLegalDocument(documentId: string): Promise<LegalDocument> {
  const response = await apiRequest<AdminLegalDocumentDto>(`/admin/support/legal-documents/${documentId}/archive/`, {
    method: 'POST',
  });
  return mapLegalDocument(response);
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

function mapHelpCenterCategory(dto: AdminSupportCategoryDto): HelpCenterCategory {
  return {
    id: dto.id,
    name: dto.name,
    slug: dto.slug,
    description: dto.description,
    sortOrder: dto.sort_order,
    isActive: dto.is_active,
    createdAt: dto.created_at,
    updatedAt: dto.updated_at,
  };
}

function mapHelpCenterArticle(dto: AdminSupportArticleDto): HelpCenterArticle {
  return {
    id: dto.id,
    category: mapHelpCenterCategory(dto.category),
    title: dto.title,
    slug: dto.slug,
    summary: dto.summary,
    body: dto.body,
    locale: dto.locale,
    status: dto.status,
    sortOrder: dto.sort_order,
    publishedAt: dto.published_at,
    createdAt: dto.created_at,
    updatedAt: dto.updated_at,
  };
}

function mapLegalDocument(dto: AdminLegalDocumentDto): LegalDocument {
  return {
    id: dto.id,
    documentType: dto.document_type,
    title: dto.title,
    version: dto.version,
    summary: dto.summary,
    body: dto.body,
    locale: dto.locale,
    status: dto.status,
    publishedAt: dto.published_at,
    createdAt: dto.created_at,
    updatedAt: dto.updated_at,
  };
}

function mapCategoryPayload(payload: SaveHelpCenterCategoryPayload) {
  return {
    name: payload.name,
    slug: payload.slug,
    description: payload.description,
    sort_order: payload.sortOrder,
    is_active: payload.isActive,
  };
}

function mapArticlePayload(payload: SaveHelpCenterArticlePayload) {
  return {
    category_id: payload.categoryId,
    title: payload.title,
    slug: payload.slug,
    summary: payload.summary,
    body: payload.body,
    locale: payload.locale,
    status: payload.status,
    sort_order: payload.sortOrder,
  };
}

function mapLegalDocumentPayload(payload: SaveLegalDocumentPayload) {
  return {
    document_type: payload.documentType,
    title: payload.title,
    version: payload.version,
    summary: payload.summary,
    body: payload.body,
    locale: payload.locale,
    status: payload.status,
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
