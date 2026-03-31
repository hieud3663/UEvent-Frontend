// File: src/features/events/mock/mock-events.ts

import type { Event } from '../types';

export const mockEvents: Event[] = [
  {
    id: '1',
    title: 'Midnight Echoes: Warehouse X',
    organizer: 'Neon Pulse Collective',
    date: 'Oct 24, 2024',
    status: 'reported',
    reportType: 'safety',
    reportSnippet:
      'Organizers are advertising unverified capacity. Previous events at this venue had blocked emergency exits and no fire marshals present...',
    category: 'Music',
  },
  {
    id: '2',
    title: 'Global AI Ethics Summit',
    organizer: 'FutureLogic Labs',
    date: 'Nov 12, 2024',
    status: 'reported',
    reportType: 'copyright',
    reportSnippet:
      'The event header image and keynote titles are direct intellectual property of the "AIToday" group without licensing consent...',
    category: 'Technology',
  },
  {
    id: '3',
    title: 'Mindful Peaks Yoga Retreat',
    organizer: 'Sierra Sol Wellness',
    date: 'Dec 05, 2024',
    status: 'pending',
    category: 'Wellness',
  },
  {
    id: '4',
    title: 'Startup Pitch Night',
    organizer: 'Tech Hub Community',
    date: 'Nov 20, 2024',
    status: 'pending',
    category: 'Business',
  },
  {
    id: '5',
    title: "Spring Music Festival '24",
    organizer: 'City Events Council',
    date: 'Mar 15, 2024',
    status: 'approved',
    category: 'Music',
  },
];

export const eventStats = {
  urgentReports: 3,
  pendingApproval: 12,
  approvedToday: 8,
  totalEvents: 1204,
};
