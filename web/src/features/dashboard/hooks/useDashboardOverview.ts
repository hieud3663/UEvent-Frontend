'use client';

import { useEffect, useState } from 'react';
import { getDashboardOverview } from '../services/dashboard.service';
import type { DashboardAuditSummary, DashboardGrowthPoint, DashboardStatItem, QueueActivityItem } from '../types';

interface DashboardOverviewResult {
  stats: DashboardStatItem[];
  queue: QueueActivityItem[];
  growthSeries: DashboardGrowthPoint[];
  auditSummary: DashboardAuditSummary | null;
  isLoading: boolean;
  error: string | null;
}

export function useDashboardOverview(): DashboardOverviewResult {
  const [stats, setStats] = useState<DashboardStatItem[]>([]);
  const [queue, setQueue] = useState<QueueActivityItem[]>([]);
  const [growthSeries, setGrowthSeries] = useState<DashboardGrowthPoint[]>([]);
  const [auditSummary, setAuditSummary] = useState<DashboardAuditSummary | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let isMounted = true;

    async function loadOverview() {
      try {
        setIsLoading(true);
        const overview = await getDashboardOverview();

        if (!isMounted) {
          return;
        }

        setStats(overview.stats);
        setQueue(overview.queue);
        setGrowthSeries(overview.growthSeries);
        setAuditSummary(overview.auditSummary);
        setError(null);
      } catch (loadError) {
        if (!isMounted) {
          return;
        }

        setError(loadError instanceof Error ? loadError.message : 'Không thể tải tổng quan hệ thống.');
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

  return { stats, queue, growthSeries, auditSummary, isLoading, error };
}
