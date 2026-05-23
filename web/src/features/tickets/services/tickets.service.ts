import { apiExport, apiRequest, apiRequestEnvelope } from '@/core/lib/api';
import type { ExportFileResult } from '@/core/types/api';
import type {
  CheckinLog,
  CheckinLogDto,
  Ticket,
  TicketDto,
  TicketEvent,
  TicketEventDto,
  TicketFilters,
  TicketListResult,
  TicketRegistration,
  TicketRegistrationDto,
  TicketScanPayload,
  TicketScanResult,
  TicketScanResultDto,
  TicketStats,
  TicketStatsDto,
  TicketUser,
  TicketUserDto,
} from '../types';

export type TicketExportFormat = 'csv' | 'xlsx';

export async function getTickets(filters: TicketFilters = {}): Promise<TicketListResult> {
  const params = buildTicketParams(filters);
  const envelope = await apiRequestEnvelope<TicketDto[]>(`/admin/tickets/?${params.toString()}`);
  const pagination = envelope.meta.pagination;

  return {
    tickets: envelope.data.map(mapTicket),
    total: pagination?.count ?? envelope.data.length,
    page: pagination?.page ?? filters.page ?? 1,
    pageSize: pagination?.page_size ?? filters.pageSize ?? envelope.data.length,
    totalPages: pagination?.total_pages ?? 1,
  };
}

export async function getTicketStats(): Promise<TicketStats> {
  const response = await apiRequest<TicketStatsDto>('/admin/tickets/statistics/');
  return mapTicketStats(response);
}

export async function getTicketById(ticketId: string): Promise<Ticket> {
  const response = await apiRequest<TicketDto>(`/admin/tickets/${ticketId}/`);
  return mapTicket(response);
}

export async function cancelTicketById(ticketId: string, reason: string): Promise<Ticket> {
  const response = await apiRequest<TicketDto>(`/admin/tickets/${ticketId}/cancel/`, {
    method: 'POST',
    body: { reason },
  });
  return mapTicket(response);
}

export async function restoreTicketById(ticketId: string, reason: string): Promise<Ticket> {
  const response = await apiRequest<TicketDto>(`/admin/tickets/${ticketId}/restore/`, {
    method: 'POST',
    body: { reason },
  });
  return mapTicket(response);
}

export async function scanTicket(payload: TicketScanPayload): Promise<TicketScanResult> {
  const response = await apiRequest<TicketScanResultDto>('/admin/tickets/checkins/scan/', {
    method: 'POST',
    body: {
      event_id: payload.eventId,
      ticket_code: payload.ticketCode,
      qr_payload: payload.qrPayload,
      qr_signature: payload.qrSignature,
      note: payload.note,
    },
  });
  return mapScanResult(response);
}

export async function exportTickets(filters: TicketFilters = {}, format: TicketExportFormat = 'csv'): Promise<ExportFileResult> {
  const params = buildTicketParams(filters);
  params.set('export_format', format);
  return apiExport(`/admin/tickets/export/?${params.toString()}`);
}

export function downloadExportFile(result: ExportFileResult): void {
  if (typeof window === 'undefined') return;

  const url = window.URL.createObjectURL(result.blob);
  const link = document.createElement('a');
  link.href = url;
  link.download = result.filename;
  document.body.appendChild(link);
  link.click();
  link.remove();
  window.URL.revokeObjectURL(url);
}

function buildTicketParams(filters: TicketFilters): URLSearchParams {
  const params = new URLSearchParams();
  params.set('page', String(filters.page ?? 1));
  params.set('page_size', String(filters.pageSize ?? 20));

  if (filters.status && filters.status !== 'all') params.set('status', filters.status);
  if (filters.search?.trim()) params.set('search', filters.search.trim());
  if (filters.eventId?.trim()) params.set('event_id', filters.eventId.trim());
  if (filters.userId?.trim()) params.set('user_id', filters.userId.trim());
  if (filters.ordering?.trim()) params.set('ordering', filters.ordering.trim());

  return params;
}

function mapTicket(dto: TicketDto): Ticket {
  return {
    id: dto.id,
    ticketCode: dto.ticket_code,
    status: dto.status,
    issuedAt: dto.issued_at,
    usedAt: dto.used_at,
    expiresAt: dto.expires_at,
    event: mapTicketEvent(dto.event),
    user: mapTicketUser(dto.user),
    registration: mapTicketRegistration(dto.registration),
    checkins: dto.checkins.map(mapCheckinLog),
  };
}

function mapTicketUser(dto: TicketUserDto): TicketUser {
  return {
    id: dto.id,
    username: dto.username,
    fullName: dto.full_name || dto.username,
    email: dto.email,
    studentCode: dto.student_code,
  };
}

function mapTicketEvent(dto: TicketEventDto): TicketEvent {
  return {
    id: dto.id,
    title: dto.title,
    status: dto.status,
    startAt: dto.start_at,
    endAt: dto.end_at,
    locationSnapshot: dto.location_snapshot,
  };
}

function mapTicketRegistration(dto: TicketRegistrationDto): TicketRegistration {
  return {
    id: dto.id,
    status: dto.status,
    registeredAt: dto.registered_at,
    cancelledAt: dto.cancelled_at,
    cancelReason: dto.cancel_reason,
  };
}

function mapCheckinLog(dto: CheckinLogDto): CheckinLog {
  return {
    id: dto.id,
    result: dto.result,
    note: dto.note,
    checkedInAt: dto.checked_in_at,
    scannerUser: dto.scanner_user ? mapTicketUser(dto.scanner_user) : null,
  };
}

function mapTicketStats(dto: TicketStatsDto): TicketStats {
  return {
    totalTickets: dto.total_tickets,
    validTickets: dto.valid_tickets,
    usedTickets: dto.used_tickets,
    cancelledTickets: dto.cancelled_tickets,
    expiredTickets: dto.expired_tickets,
    totalRegistrations: dto.total_registrations,
    checkedInRegistrations: dto.checked_in_registrations,
    checkinsToday: dto.checkins_today,
    checkinRate: dto.checkin_rate,
  };
}

function mapScanResult(dto: TicketScanResultDto): TicketScanResult {
  return {
    result: dto.result,
    log: mapCheckinLog(dto.log),
    ticket: dto.ticket ? mapTicket(dto.ticket) : null,
    registration: dto.registration ? mapTicketRegistration(dto.registration) : null,
    event: mapTicketEvent(dto.event),
  };
}
