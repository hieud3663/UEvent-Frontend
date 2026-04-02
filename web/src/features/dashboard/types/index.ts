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
}
