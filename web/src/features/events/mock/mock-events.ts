// File: src/features/events/mock/mock-events.ts

import type {
  Event,
  EventModerationActivity,
  EventModerationPulse,
  EventPolicyHandbook,
} from '../types';

export const mockEvents: Event[] = [
  {
    id: '1',
    title: 'Midnight Echoes: Warehouse X',
    organizer: 'Neon Pulse Collective',
    date: 'Oct 24, 2024',
    coverImageUrl:
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDWr1ZLrB2PRjy_meeHzsve3tDJ5IqG4_V7_hbpCy4BaTbyUvUmXr0COd6ppICAccsQji3LpzrAXoZty2sVF2a-9H_eZONwwoXfNMb2_dHDyoMbFM4EzljjyHGtAZ1ZVwf0vvHIM8LyzOOAKwhZoNCzeDf9XCpYjx_H1G4W1CQ0a_oQmdfw6SzxXNwfHF08cO8Pi5FLVuvEFxMakARkq8B9hYy2Cr71yzY68IKa65embMoyBmnrbk5LXjbJ4TAkfKs89fu7em7d07E',
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
    coverImageUrl:
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDM-9hYTuO2vpG1-AV5rmjnXqj3aMQRZQag8HNz53HFoGtdIweRS4HDR7YkMC7_Mmet-yBNI764yTib5EE1QOl5sm6fpj_kaaFP1KiJu39owtykk-zkfhY22527LJST21ZpsiVh_Av4-uIBwd2-tQ1BaTMe36BqJUsLrWkGXww6MoPB9DJqjpyz9HyDPciyLxRzC_LhDIJoiVmVRUbZdhYBWZ8jPtQxuqYuIrEWYa05xApOtfaKLMFu96fnsBSBeUg4D1X_3PVnVEg',
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
    coverImageUrl:
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDHRwADeOvL-aYEGvIlevWZus2G-2vSnUrmdx-O3HvJwzxepkds5x4F1uRyEc-jD9l1snnqGlB-TdkmOjEJANEuha_wmkbhHxkkZouX-Q3rcxcqzZnBtnDKun--Y0zrWoaY2OxWdMtPVCEmy68AxIbo61LJ68Rs8fTJ2IM7zBFB4II165OWUNt5f0UBBHSUAbx_9BzpUmd1KkVtBaEqsN4PJb28XaPUegn5rI97fHj8vP8M60a-dlFmtrLO6dSiMBMBt4NUkHvvdLs',
    moderationNote:
      'Sierra Sol is a newly registered wellness collective. They are proposing a 3-day high-altitude yoga experience for 50 guests. Documentation for insurance is attached.',
    organizerTag: 'New Organizer',
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

export const eventModerationPulse: EventModerationPulse = {
  avgResponseHours: 1.4,
  queueSize: 42,
  targetLabel: 'Target: < 2h',
  targetProgress: 75,
};

export const eventModerationActivities: EventModerationActivity[] = [
  {
    id: 'activity-1',
    title: 'Jazz on the Green approved',
    description: 'by Alex Rivera • 12m ago',
    type: 'approved',
  },
  {
    id: 'activity-2',
    title: 'Secret Bunker 404 declined',
    description: 'Policy violation: Lack of permit • 45m ago',
    type: 'declined',
  },
  {
    id: 'activity-3',
    title: 'Sky Lantern Fest flagged',
    description: 'Pending safety review • 1h ago',
    type: 'flagged',
  },
];

export const eventPolicyHandbook: EventPolicyHandbook = {
  title: 'Moderator Policy Handbook',
  description:
    'Ensure all events meet the Community Standards v4.2 regarding safety, noise levels, and verified ticketing partners.',
  ctaLabel: 'Open Docs',
  ctaHref: '#',
};
