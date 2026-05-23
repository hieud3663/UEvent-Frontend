export type TicketStatus = 'valid' | 'used' | 'expired' | 'cancelled';

export interface TicketUser {
  id: string;
  username: string;
  fullName: string;
  email: string;
  studentCode?: string | null;
}

export interface TicketEvent {
  id: string;
  title: string;
  status: string;
  startAt: string;
  endAt: string;
  locationSnapshot?: string | null;
}

export interface TicketRegistration {
  id: string;
  status: string;
  registeredAt: string;
  cancelledAt?: string | null;
  cancelReason?: string | null;
}

export interface CheckinLog {
  id: string;
  result: string;
  note?: string | null;
  checkedInAt: string;
  scannerUser?: TicketUser | null;
}

export interface Ticket {
  id: string;
  ticketCode: string;
  status: TicketStatus;
  issuedAt: string;
  usedAt?: string | null;
  expiresAt: string;
  event: TicketEvent;
  user: TicketUser;
  registration: TicketRegistration;
  checkins: CheckinLog[];
}

export interface TicketStats {
  totalTickets: number;
  validTickets: number;
  usedTickets: number;
  cancelledTickets: number;
  expiredTickets: number;
  totalRegistrations: number;
  checkedInRegistrations: number;
  checkinsToday: number;
  checkinRate: number;
}

export interface TicketFilters {
  status?: TicketStatus | 'all';
  search?: string;
  eventId?: string;
  userId?: string;
  page?: number;
  pageSize?: number;
  ordering?: string;
}

export interface TicketListResult {
  tickets: Ticket[];
  total: number;
  page: number;
  pageSize: number;
  totalPages: number;
}

export interface TicketScanPayload {
  eventId: string;
  ticketCode?: string;
  qrPayload?: string;
  qrSignature?: string;
  note?: string;
}

export interface TicketScanResult {
  result: string;
  log: CheckinLog;
  ticket?: Ticket | null;
  registration?: TicketRegistration | null;
  event: TicketEvent;
}

export interface TicketDto {
  id: string;
  ticket_code: string;
  status: TicketStatus;
  issued_at: string;
  used_at?: string | null;
  expires_at: string;
  event: TicketEventDto;
  user: TicketUserDto;
  registration: TicketRegistrationDto;
  checkins: CheckinLogDto[];
}

export interface TicketUserDto {
  id: string;
  username: string;
  full_name: string;
  email: string;
  student_code?: string | null;
}

export interface TicketEventDto {
  id: string;
  title: string;
  status: string;
  start_at: string;
  end_at: string;
  location_snapshot?: string | null;
}

export interface TicketRegistrationDto {
  id: string;
  status: string;
  registered_at: string;
  cancelled_at?: string | null;
  cancel_reason?: string | null;
}

export interface CheckinLogDto {
  id: string;
  result: string;
  note?: string | null;
  checked_in_at: string;
  scanner_user?: TicketUserDto | null;
}

export interface TicketStatsDto {
  total_tickets: number;
  valid_tickets: number;
  used_tickets: number;
  cancelled_tickets: number;
  expired_tickets: number;
  total_registrations: number;
  checked_in_registrations: number;
  checkins_today: number;
  checkin_rate: number;
}

export interface TicketScanResultDto {
  result: string;
  log: CheckinLogDto;
  ticket?: TicketDto | null;
  registration?: TicketRegistrationDto | null;
  event: TicketEventDto;
}
