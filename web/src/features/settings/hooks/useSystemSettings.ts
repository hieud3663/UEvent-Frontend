'use client';

import { useEffect, useMemo, useState } from 'react';
import { getSystemLogs } from '../services/settings.service';
import type { LogActionType, LogDateRange, LogEntry } from '../types';

export function useSystemSettings() {
  const [darkMode, setDarkMode] = useState(true);
  const [auditAlerts, setAuditAlerts] = useState(true);
  const [dateRange, setDateRange] = useState<LogDateRange>('24hours');
  const [actionType, setActionType] = useState<LogActionType>('all');
  const [logs, setLogs] = useState<LogEntry[]>([]);

  useEffect(() => {
    let isMounted = true;

    async function loadLogs() {
      const response = await getSystemLogs(actionType);

      if (!isMounted) {
        return;
      }

      setLogs(response);
    }

    void loadLogs();

    return () => {
      isMounted = false;
    };
  }, [actionType]);

  const visibleLogs = useMemo(() => {
    if (dateRange === '24hours') {
      return logs.slice(0, 5);
    }

    if (dateRange === '7days') {
      return logs;
    }

    return [...logs, ...logs].slice(0, 8);
  }, [dateRange, logs]);

  return {
    darkMode,
    setDarkMode,
    auditAlerts,
    setAuditAlerts,
    dateRange,
    setDateRange,
    actionType,
    setActionType,
    logs: visibleLogs,
  };
}
