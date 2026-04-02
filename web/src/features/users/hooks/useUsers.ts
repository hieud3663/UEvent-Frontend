'use client';

import { useEffect, useState } from 'react';
import { getUsers, type UserFilters } from '../services/users.service';
import type { User } from '../types';

interface UseUsersResult {
  users: User[];
  total: number;
  isLoading: boolean;
  error: string | null;
}

export function useUsers(filters: UserFilters = {}): UseUsersResult {
  const [users, setUsers] = useState<User[]>([]);
  const [total, setTotal] = useState(0);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let isMounted = true;

    async function loadUsers() {
      try {
        setIsLoading(true);
        const response = await getUsers(filters);

        if (!isMounted) {
          return;
        }

        setUsers(response.users);
        setTotal(response.total);
        setError(null);
      } catch {
        if (!isMounted) {
          return;
        }

        setError('Failed to load users');
      } finally {
        if (isMounted) {
          setIsLoading(false);
        }
      }
    }

    void loadUsers();

    return () => {
      isMounted = false;
    };
  }, [filters]);

  return { users, total, isLoading, error };
}
