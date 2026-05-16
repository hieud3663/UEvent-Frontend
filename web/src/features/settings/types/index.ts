export interface LogEntry {
  id: string;
  timestamp: string;
  date: string;
  time: string;
  user: {
    name: string;
    subtitle?: string;
    initials: string;
    color: 'indigo' | 'amber' | 'emerald' | 'purple' | 'slate';
  };
  action: string;
  target: string;
  reason: string;
  traceId: string;
  status: 'success' | 'failed';
}

export interface SystemPreferences {
  auditAlerts: boolean;
}

export type LogDateRange = '24hours' | '7days' | '30days';
export type LogActionType = 'all' | 'error' | 'settings' | 'security' | 'event';

export interface SystemSetting {
  key: string;
  group: string;
  label: string;
  description: string;
  valueType: 'boolean' | 'integer' | 'string' | 'json';
  value: boolean | number | string | Record<string, unknown> | unknown[];
  editable: boolean;
  updatedAt?: string | null;
  updatedBy?: string | null;
}

export interface SystemSettingsResponse {
  groups: Array<{
    id: string;
    label: string;
    description: string;
  }>;
  settings: SystemSetting[];
}

export interface AuditLogFilters {
  dateRange: LogDateRange;
  actionType: LogActionType;
  actorId?: string;
  status?: 'all' | 'success' | 'failed';
  page?: number;
  pageSize?: number;
}

export interface AuditLogResult {
  logs: LogEntry[];
  total: number;
  page: number;
  pageSize: number;
  totalPages: number;
}

export interface AuditSummary {
  totalEvents: number;
  failedEvents: number;
  highRiskEvents: number;
  lastEventAt?: string | null;
  status: 'available' | 'unavailable';
}
