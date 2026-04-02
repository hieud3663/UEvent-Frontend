import type { DashboardGrowthPoint, DashboardStatItem, QueueActivityItem } from '../types';

export const dashboardStats: DashboardStatItem[] = [
  { id: 'users', title: 'Total Users', value: '42,891', trendLabel: '+12.5%' },
  { id: 'registrations', title: 'Registrations', value: '156,042', trendLabel: '+8.2%' },
  { id: 'events', title: 'Active Events', value: '1,204', trendLabel: 'Active Now' },
  { id: 'revenue', title: 'Total Revenue', value: '$2.4M', trendLabel: '+15.9%' },
];

export const queueActivities: QueueActivityItem[] = [
  {
    id: 'queue-1',
    title: 'Cyber Summit 2024',
    subtitle: 'New event approval requested',
    status: 'pending',
  },
  {
    id: 'queue-2',
    title: 'Creative Workshop',
    subtitle: 'Organizer verification',
    status: 'pending',
  },
  {
    id: 'queue-3',
    title: 'System Update',
    subtitle: 'Security patches applied',
    status: 'completed',
  },
];

export const dashboardGrowthSeries: DashboardGrowthPoint[] = [
  { id: 'jan', month: 'Jan', monthlyValue: 40, yearlyValue: 30 },
  { id: 'feb', month: 'Feb', monthlyValue: 60, yearlyValue: 45 },
  { id: 'mar', month: 'Mar', monthlyValue: 55, yearlyValue: 50 },
  { id: 'apr', month: 'Apr', monthlyValue: 85, yearlyValue: 60 },
  { id: 'may', month: 'May', monthlyValue: 95, yearlyValue: 70, highlight: true },
  { id: 'jun', month: 'Jun', monthlyValue: 70, yearlyValue: 65 },
  { id: 'jul', month: 'Jul', monthlyValue: 45, yearlyValue: 55 },
  { id: 'aug', month: 'Aug', monthlyValue: 30, yearlyValue: 60 },
  { id: 'sep', month: 'Sep', monthlyValue: 50, yearlyValue: 72 },
  { id: 'oct', month: 'Oct', monthlyValue: 75, yearlyValue: 80 },
  { id: 'nov', month: 'Nov', monthlyValue: 90, yearlyValue: 88 },
  { id: 'dec', month: 'Dec', monthlyValue: 65, yearlyValue: 95 },
];
