import { mockTickets, supportStats } from '../mock/mock-support';
import type { Ticket, TicketMessage, TicketPriority, TicketStatus } from '../types';

export interface TicketFilters {
  status?: TicketStatus;
  priority?: TicketPriority;
  keyword?: string;
}

export async function getTickets(filters: TicketFilters = {}): Promise<Ticket[]> {
  const normalizedKeyword = filters.keyword?.trim().toLowerCase();

  const tickets = mockTickets.filter((ticket) => {
    const statusMatch = !filters.status || ticket.status === filters.status;
    const priorityMatch = !filters.priority || ticket.priority === filters.priority;
    const keywordMatch =
      !normalizedKeyword ||
      ticket.subject.toLowerCase().includes(normalizedKeyword) ||
      ticket.userName.toLowerCase().includes(normalizedKeyword) ||
      ticket.id.toLowerCase().includes(normalizedKeyword);

    return statusMatch && priorityMatch && keywordMatch;
  });

  return Promise.resolve(tickets);
}

export async function getSupportStats() {
  return Promise.resolve(supportStats);
}

export async function getTicketById(ticketId: string): Promise<Ticket | null> {
  const ticket = mockTickets.find((item) => item.id === ticketId) ?? null;
  return Promise.resolve(ticket);
}

export async function sendSupportReply(
  ticketId: string,
  content: string,
  authorName = 'Support Agent'
): Promise<TicketMessage> {
  const ticket = mockTickets.find((item) => item.id === ticketId);

  if (!ticket) {
    throw new Error('Ticket not found');
  }

  const message: TicketMessage = {
    id: `msg-${Date.now()}`,
    content,
    isStaff: true,
    authorName,
    createdAt: new Date().toISOString(),
  };

  return Promise.resolve(message);
}

export async function markSupportTicketResolved(ticketId: string): Promise<TicketStatus> {
  const ticket = mockTickets.find((item) => item.id === ticketId);

  if (!ticket) {
    throw new Error('Ticket not found');
  }

  return Promise.resolve('resolved');
}

export async function escalateSupportTicket(ticketId: string): Promise<TicketPriority> {
  const ticket = mockTickets.find((item) => item.id === ticketId);

  if (!ticket) {
    throw new Error('Ticket not found');
  }

  return Promise.resolve('urgent');
}
