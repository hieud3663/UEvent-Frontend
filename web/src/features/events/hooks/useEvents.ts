'use client';

import { useEffect, useState } from 'react';
import { getEvents, type EventFilters } from '../services/events.service';
import type { Event } from '../types';

interface UseEventsResult {
  events: Event[];
  isLoading: boolean;
  error: string | null;
}

export function useEvents(filters: EventFilters = {}): UseEventsResult {
  const [events, setEvents] = useState<Event[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let isMounted = true;

    async function loadEvents() {
      try {
        setIsLoading(true);
        const response = await getEvents(filters);

        if (!isMounted) {
          return;
        }

        setEvents(response);
        setError(null);
      } catch {
        if (!isMounted) {
          return;
        }

        setError('Không thể tải sự kiện');
      } finally {
        if (isMounted) {
          setIsLoading(false);
        }
      }
    }

    void loadEvents();

    return () => {
      isMounted = false;
    };
  }, [filters]);

  return { events, isLoading, error };
}
