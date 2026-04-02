import {
  eventModerationActivities,
  eventModerationPulse,
  eventPolicyHandbook,
  eventStats,
  mockEvents,
} from '../mock/mock-events';
import type {
  Event,
  EventModerationActivity,
  EventModerationPulse,
  EventPolicyHandbook,
  EventStatus,
} from '../types';

export interface EventFilters {
  status?: EventStatus;
  keyword?: string;
}

export async function getEvents(filters: EventFilters = {}): Promise<Event[]> {
  const normalizedKeyword = filters.keyword?.trim().toLowerCase();

  const events = mockEvents.filter((event) => {
    const statusMatch = !filters.status || event.status === filters.status;
    const keywordMatch =
      !normalizedKeyword ||
      event.title.toLowerCase().includes(normalizedKeyword) ||
      event.organizer.toLowerCase().includes(normalizedKeyword) ||
      event.category.toLowerCase().includes(normalizedKeyword);

    return statusMatch && keywordMatch;
  });

  return Promise.resolve(events);
}

export async function getEventStats() {
  return Promise.resolve(eventStats);
}

export async function getEventModerationPulse(): Promise<EventModerationPulse> {
  return Promise.resolve(eventModerationPulse);
}

export async function getEventModerationActivities(): Promise<EventModerationActivity[]> {
  return Promise.resolve(eventModerationActivities);
}

export async function getEventPolicyHandbook(): Promise<EventPolicyHandbook> {
  return Promise.resolve(eventPolicyHandbook);
}

export async function moderateEventStatus(
  eventId: string,
  status: Extract<EventStatus, 'approved' | 'rejected'>
): Promise<Event> {
  const targetEvent = mockEvents.find((item) => item.id === eventId);

  if (!targetEvent) {
    throw new Error('Event not found');
  }

  return Promise.resolve({ ...targetEvent, status });
}
