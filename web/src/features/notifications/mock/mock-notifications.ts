// File: src/features/notifications/mock/mock-notifications.ts
import type { Notification, NotificationStats } from '../types';

export const mockNotifications: Notification[] = [
  {
    id: '1',
    title: 'Early Bird: Summer Music Fest',
    message: 'Get your tickets now for 20% off!',
    type: 'reminder',
    status: 'sent',
    audience: 'all',
    recipientCount: 12450,
    sentAt: '2023-10-24T10:30:00Z',
    createdAt: '2023-10-23T15:30:00Z',
    createdBy: 'Alex Rivera',
    performance: {
      reachPercentage: 78,
      openRate: 32.4,
    },
  },
  {
    id: '2',
    title: 'New Organizer Guidelines',
    message: 'Updated rules for event submission',
    type: 'announcement',
    status: 'scheduled',
    audience: 'organizers',
    recipientCount: 345,
    scheduledAt: '2023-10-26T14:15:00Z',
    createdAt: '2023-10-25T09:00:00Z',
    createdBy: 'System Admin',
  },
  {
    id: '3',
    title: 'Tech Talk @ Grand Hall',
    message: 'Important venue change for attendees',
    type: 'promotion',
    status: 'sent',
    audience: 'custom',
    recipientCount: 892,
    sentAt: '2023-10-22T09:00:00Z',
    createdAt: '2023-10-21T14:00:00Z',
    createdBy: 'Alex Rivera',
    performance: {
      reachPercentage: 95,
      openRate: 64.1,
    },
  },
  {
    id: '4',
    title: 'Weekly Event Roundup',
    message: 'Top activities in your city this week',
    type: 'announcement',
    status: 'sent',
    audience: 'all',
    recipientCount: 12450,
    sentAt: '2023-10-20T08:00:00Z',
    createdAt: '2023-10-19T18:00:00Z',
    createdBy: 'Marketing Team',
    performance: {
      reachPercentage: 45,
      openRate: 12.8,
    },
  },
];

export const notificationStats: NotificationStats = {
  totalSent: 12482,
  totalSentChange: '+12%',
  avgOpenRate: 24.8,
  avgOpenRateStatus: 'Stable',
  scheduled: 18,
  scheduledNote: 'Next 7 days',
  activeUsers: 4210,
  activeUsersStatus: 'Live',
};
