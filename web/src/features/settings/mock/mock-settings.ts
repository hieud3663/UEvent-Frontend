import type { LogEntry } from '../types';

export const mockLogs: LogEntry[] = [
  {
    id: '1',
    timestamp: '2023-10-24T14:42:01.32Z',
    date: 'Oct 24, 2023',
    time: '14:42:01.32',
    user: { name: 'Alex Rivers', initials: 'AR', color: 'indigo' },
    action: 'Settings Updated',
    status: 'success',
  },
  {
    id: '2',
    timestamp: '2023-10-24T14:35:44.92Z',
    date: 'Oct 24, 2023',
    time: '14:35:44.92',
    user: { name: 'Anonymous', initials: '?', color: 'amber' },
    action: 'Login Attempt',
    status: 'failed',
  },
  {
    id: '3',
    timestamp: '2023-10-24T13:20:15.12Z',
    date: 'Oct 24, 2023',
    time: '13:20:15.12',
    user: { name: 'Sarah Chen', initials: 'SC', color: 'emerald' },
    action: 'Event Approved',
    status: 'success',
  },
  {
    id: '4',
    timestamp: '2023-10-24T12:15:30.88Z',
    date: 'Oct 24, 2023',
    time: '12:15:30.88',
    user: { name: 'Mike Johnson', initials: 'MJ', color: 'purple' },
    action: 'User Banned',
    status: 'success',
  },
  {
    id: '5',
    timestamp: '2023-10-24T11:05:22.45Z',
    date: 'Oct 24, 2023',
    time: '11:05:22.45',
    user: { name: 'Anonymous', initials: '?', color: 'amber' },
    action: 'Login Attempt',
    status: 'failed',
  },
];
