export interface LogEntry {
  id: string;
  timestamp: string;
  date: string;
  time: string;
  user: {
    name: string;
    initials: string;
    color: 'indigo' | 'amber' | 'emerald' | 'purple';
  };
  action: string;
  status: 'success' | 'failed';
}

export interface SystemPreferences {
  darkMode: boolean;
  auditAlerts: boolean;
}

export type LogDateRange = '24hours' | '7days' | '30days';
export type LogActionType = 'all' | 'error';
