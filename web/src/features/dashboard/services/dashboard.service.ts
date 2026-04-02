import { dashboardGrowthSeries, dashboardStats, queueActivities } from '../mock/mock-dashboard';

export async function getDashboardStats() {
  return Promise.resolve(dashboardStats);
}

export async function getQueueActivities() {
  return Promise.resolve(queueActivities);
}

export async function getDashboardGrowthSeries() {
  return Promise.resolve(dashboardGrowthSeries);
}
