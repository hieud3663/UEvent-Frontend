'use client';

import { useEffect, useState } from 'react';
import { getDashboardGrowthSeries, getDashboardStats, getQueueActivities } from '../services/dashboard.service';
import type { DashboardGrowthPoint, DashboardStatItem, QueueActivityItem } from '../types';

interface DashboardOverviewResult {
  stats: DashboardStatItem[];
  queue: QueueActivityItem[];
  growthSeries: DashboardGrowthPoint[];
  isLoading: boolean;
  error: string | null;
}

export function useDashboardOverview(): DashboardOverviewResult {
  const [stats, setStats] = useState<DashboardStatItem[]>([]);
  const [queue, setQueue] = useState<QueueActivityItem[]>([]);
  const [growthSeries, setGrowthSeries] = useState<DashboardGrowthPoint[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let isMounted = true;

    async function loadOverview() {
      try {
        setIsLoading(true);
        const [nextStats, nextQueue, nextGrowthSeries] = await Promise.all([
          getDashboardStats(),
          getQueueActivities(),
          getDashboardGrowthSeries(),
        ]);

        if (!isMounted) {
          return;
        }

        setStats(nextStats);
        setQueue(nextQueue);
        setGrowthSeries(nextGrowthSeries);
        setError(null);
      } catch {
        if (!isMounted) {
          return;
        }

        setError('Failed to load dashboard overview');
      } finally {
        if (isMounted) {
          setIsLoading(false);
        }
      }
    }

    void loadOverview();

    return () => {
      isMounted = false;
    };
  }, []);

  return { stats, queue, growthSeries, isLoading, error };
}
