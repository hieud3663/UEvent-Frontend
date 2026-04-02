import { mockLogs } from '../mock/mock-settings';
import type { LogActionType, LogEntry } from '../types';

export async function getSystemLogs(actionType: LogActionType): Promise<LogEntry[]> {
  if (actionType === 'error') {
    return Promise.resolve(mockLogs.filter((log) => log.status === 'failed'));
  }

  return Promise.resolve(mockLogs);
}
