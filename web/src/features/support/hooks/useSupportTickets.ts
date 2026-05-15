'use client';

import { useEffect, useState } from 'react';
import { getTickets, type TicketFilters } from '../services/support.service';
import type { Ticket } from '../types';

interface UseSupportTicketsResult {
  tickets: Ticket[];
  isLoading: boolean;
  error: string | null;
}

export function useSupportTickets(filters: TicketFilters = {}): UseSupportTicketsResult {
  const [tickets, setTickets] = useState<Ticket[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let isMounted = true;

    async function loadTickets() {
      try {
        setIsLoading(true);
        const response = await getTickets(filters);

        if (!isMounted) {
          return;
        }

        setTickets(response);
        setError(null);
      } catch {
        if (!isMounted) {
          return;
        }

        setError('Không thể tải danh sách ticket hỗ trợ.');
      } finally {
        if (isMounted) {
          setIsLoading(false);
        }
      }
    }

    void loadTickets();

    return () => {
      isMounted = false;
    };
  }, [filters]);

  return { tickets, isLoading, error };
}
