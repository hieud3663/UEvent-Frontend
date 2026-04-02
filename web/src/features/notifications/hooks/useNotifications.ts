'use client';

import { useEffect, useState } from 'react';
import { getNotifications, type NotificationFilters } from '../services/notifications.service';
import type { Notification } from '../types';

interface UseNotificationsResult {
  notifications: Notification[];
  isLoading: boolean;
  error: string | null;
}

export function useNotifications(filters: NotificationFilters = {}): UseNotificationsResult {
  const [notifications, setNotifications] = useState<Notification[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let isMounted = true;

    async function loadNotifications() {
      try {
        setIsLoading(true);
        const response = await getNotifications(filters);

        if (!isMounted) {
          return;
        }

        setNotifications(response);
        setError(null);
      } catch {
        if (!isMounted) {
          return;
        }

        setError('Failed to load notifications');
      } finally {
        if (isMounted) {
          setIsLoading(false);
        }
      }
    }

    void loadNotifications();

    return () => {
      isMounted = false;
    };
  }, [filters]);

  return { notifications, isLoading, error };
}
