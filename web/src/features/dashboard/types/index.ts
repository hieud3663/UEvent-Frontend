export interface DashboardStatItem {
  id: string;
  title: string;
  value: string;
  trendLabel: string;
}

export interface DashboardGrowthPoint {
  id: string;
  month: string;
  monthlyValue: number;
  yearlyValue: number;
  highlight?: boolean;
}

export interface QueueActivityItem {
  id: string;
  title: string;
  subtitle: string;
  status: 'pending' | 'completed';
  href: string;
}

export interface DashboardAuditSummary {
  totalEvents: number;
  failedEvents: number;
  highRiskEvents: number;
  lastEventAt?: string | null;
  status: 'available' | 'unavailable';
}

export interface DashboardOverview {
  stats: DashboardStatItem[];
  growthSeries: DashboardGrowthPoint[];
  queue: QueueActivityItem[];
  auditSummary: DashboardAuditSummary;
}
