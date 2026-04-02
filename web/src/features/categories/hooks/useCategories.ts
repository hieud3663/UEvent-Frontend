'use client';

import { useEffect, useState } from 'react';
import { getCategories } from '../services/categories.service';
import type { Category } from '../types';

interface UseCategoriesResult {
  categories: Category[];
  isLoading: boolean;
  error: string | null;
}

export function useCategories(): UseCategoriesResult {
  const [categories, setCategories] = useState<Category[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let isMounted = true;

    async function loadCategories() {
      try {
        setIsLoading(true);
        const response = await getCategories();

        if (!isMounted) {
          return;
        }

        setCategories(response);
        setError(null);
      } catch {
        if (!isMounted) {
          return;
        }

        setError('Failed to load categories');
      } finally {
        if (isMounted) {
          setIsLoading(false);
        }
      }
    }

    void loadCategories();

    return () => {
      isMounted = false;
    };
  }, []);

  return { categories, isLoading, error };
}
