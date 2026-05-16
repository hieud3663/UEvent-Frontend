import { apiRequest } from '@/core/lib/api';
import type {
  DashboardAuditSummary,
  DashboardGrowthPoint,
  DashboardOverview,
  DashboardStatItem,
  QueueActivityItem,
} from '../types';

interface DashboardStatDto {
  id: string;
  title: string;
  value: string;
  trend_label: string;
}

interface DashboardGrowthPointDto {
  id: string;
  month: string;
  monthly_value: number;
  yearly_value: number;
  highlight?: boolean;
}

interface QueueActivityDto {
  id: string;
  title: string;
  subtitle: string;
  status: 'pending' | 'completed';
  href: string;
}

interface DashboardAuditSummaryDto {
  total_events: number;
  failed_events: number;
  high_risk_events: number;
  last_event_at?: string | null;
  status: 'available' | 'unavailable';
}

interface DashboardOverviewDto {
  stats: DashboardStatDto[];
  growth_series: DashboardGrowthPointDto[];
  queue: QueueActivityDto[];
  audit_summary: DashboardAuditSummaryDto;
}

export async function getDashboardOverview(): Promise<DashboardOverview> {
  const response = await apiRequest<DashboardOverviewDto>('/admin/dashboard/overview/');
  return {
    stats: response.stats.map(mapDashboardStat),
    growthSeries: response.growth_series.map(mapGrowthPoint),
    queue: response.queue.map(mapQueueActivity),
    auditSummary: mapAuditSummary(response.audit_summary),
  };
}

export async function getDashboardStats(): Promise<DashboardStatItem[]> {
  const response = await apiRequest<DashboardStatDto[]>('/admin/dashboard/stats/');
  return response.map(mapDashboardStat);
}

export async function getQueueActivities(): Promise<QueueActivityItem[]> {
  const response = await apiRequest<QueueActivityDto[]>('/admin/dashboard/queues/');
  return response.map(mapQueueActivity);
}

export async function getDashboardGrowthSeries(): Promise<DashboardGrowthPoint[]> {
  const response = await apiRequest<DashboardGrowthPointDto[]>('/admin/dashboard/growth/');
  return response.map(mapGrowthPoint);
}

function mapDashboardStat(dto: DashboardStatDto): DashboardStatItem {
  return {
    id: dto.id,
    title: dto.title,
    value: dto.value,
    trendLabel: dto.trend_label,
  };
}

function mapGrowthPoint(dto: DashboardGrowthPointDto): DashboardGrowthPoint {
  return {
    id: dto.id,
    month: dto.month,
    monthlyValue: dto.monthly_value,
    yearlyValue: dto.yearly_value,
    highlight: dto.highlight,
  };
}

function mapQueueActivity(dto: QueueActivityDto): QueueActivityItem {
  return {
    id: dto.id,
    title: dto.title,
    subtitle: dto.subtitle,
    status: dto.status,
    href: dto.href,
  };
}

function mapAuditSummary(dto: DashboardAuditSummaryDto): DashboardAuditSummary {
  return {
    totalEvents: dto.total_events,
    failedEvents: dto.failed_events,
    highRiskEvents: dto.high_risk_events,
    lastEventAt: dto.last_event_at,
    status: dto.status,
  };
}
