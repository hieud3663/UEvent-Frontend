'use client';

import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import { toast } from 'sonner';
import {
  getAuditSummary,
  getSystemLogs,
  getSystemSettings,
  updateSystemSettings,
} from '../services/settings.service';
import type {
  AuditLogFilters,
  AuditSummary,
  LogActionType,
  LogDateRange,
  LogEntry,
  SystemSetting,
  SystemSettingsResponse,
} from '../types';

const AUDIT_ALERTS_KEY = 'uevent_admin_audit_alerts';

interface SystemSettingsState {
  actionType: LogActionType;
  actorId: string;
  auditAlerts: boolean;
  auditSummary: AuditSummary | null;
  dateRange: LogDateRange;
  error: string | null;
  isAuditLoading: boolean;
  isSavingSettings: boolean;
  isSettingsLoading: boolean;
  logs: LogEntry[];
  settingGroups: SystemSettingsResponse['groups'];
  settings: SystemSetting[];
  status: 'all' | 'success' | 'failed';
  totalLogs: number;
  setActionType: (value: LogActionType) => void;
  setActorId: (value: string) => void;
  setAuditAlerts: (value: boolean) => void;
  setDateRange: (value: LogDateRange) => void;
  setSettingValue: (key: string, value: SystemSetting['value']) => void;
  setStatus: (value: 'all' | 'success' | 'failed') => void;
  refresh: () => Promise<void>;
  savePreferences: (reason?: string) => Promise<void>;
}

const DEFAULT_AUDIT_SUMMARY: AuditSummary = {
  totalEvents: 0,
  failedEvents: 0,
  highRiskEvents: 0,
  lastEventAt: null,
  status: 'unavailable',
};

function getStoredAuditAlerts(): boolean {
  if (typeof window === 'undefined') return true;
  const stored = localStorage.getItem(AUDIT_ALERTS_KEY);
  return stored === null ? true : stored === 'true';
}

export function useSystemSettings(): SystemSettingsState {
  const [settingsResponse, setSettingsResponse] = useState<SystemSettingsResponse | null>(null);
  const [auditSummary, setAuditSummary] = useState<AuditSummary | null>(null);
  const [dateRange, setDateRange] = useState<LogDateRange>('24hours');
  const [actionType, setActionType] = useState<LogActionType>('all');
  const [status, setStatus] = useState<'all' | 'success' | 'failed'>('all');
  const [actorId, setActorId] = useState('');
  const [logs, setLogs] = useState<LogEntry[]>([]);
  const [totalLogs, setTotalLogs] = useState(0);
  const [isSettingsLoading, setIsSettingsLoading] = useState(true);
  const [isSavingSettings, setIsSavingSettings] = useState(false);
  const [isAuditLoading, setIsAuditLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [auditAlerts, setAuditAlertsState] = useState(true);

  const prevSummaryRef = useRef<AuditSummary | null>(null);
  const isFirstLoadRef = useRef(true);

  useEffect(() => {
    setAuditAlertsState(getStoredAuditAlerts());
  }, []);

  const setAuditAlerts = useCallback((value: boolean) => {
    setAuditAlertsState(value);
    localStorage.setItem(AUDIT_ALERTS_KEY, String(value));
  }, []);

  const filters = useMemo<AuditLogFilters>(
    () => ({
      dateRange,
      actionType,
      actorId,
      status,
      page: 1,
      pageSize: 20,
    }),
    [actionType, actorId, dateRange, status]
  );

  const loadSettings = useCallback(async () => {
    setIsSettingsLoading(true);
    try {
      const response = await getSystemSettings();
      setSettingsResponse(response);
    } finally {
      setIsSettingsLoading(false);
    }
  }, []);

  const checkAuditAlerts = useCallback(
    (summary: AuditSummary) => {
      if (!auditAlerts) return;
      if (isFirstLoadRef.current) {
        isFirstLoadRef.current = false;

        if (summary.failedEvents > 0) {
          toast.warning(`Có ${summary.failedEvents} sự kiện thất bại trong 24 giờ qua`, {
            description: 'Kiểm tra nhật ký kiểm toán để biết chi tiết.',
            duration: 8000,
          });
        }
        if (summary.highRiskEvents > 0) {
          toast.error(`Có ${summary.highRiskEvents} sự kiện rủi ro cao trong 24 giờ qua`, {
            description: 'Bao gồm các hành động như khóa người dùng, xóa sự kiện hoặc xuất nhật ký.',
            duration: 10000,
          });
        }
        prevSummaryRef.current = summary;
        return;
      }

      const prev = prevSummaryRef.current;
      if (prev) {
        const newFailed = summary.failedEvents - prev.failedEvents;
        const newHighRisk = summary.highRiskEvents - prev.highRiskEvents;

        if (newFailed > 0) {
          toast.warning(`Phát hiện thêm ${newFailed} sự kiện thất bại mới`, {
            description: 'Có hành động quản trị mới thất bại. Kiểm tra ngay.',
            duration: 8000,
          });
        }
        if (newHighRisk > 0) {
          toast.error(`Phát hiện thêm ${newHighRisk} sự kiện rủi ro cao mới`, {
            description: 'Có hành động nhạy cảm mới được thực hiện.',
            duration: 10000,
          });
        }
      }

      prevSummaryRef.current = summary;
    },
    [auditAlerts]
  );

  const loadAuditLogs = useCallback(async () => {
    setIsAuditLoading(true);
    try {
      const [auditResult, summary] = await Promise.all([
        getSystemLogs(filters),
        getAuditSummary().catch(() => DEFAULT_AUDIT_SUMMARY),
      ]);
      setLogs(auditResult.logs);
      setTotalLogs(auditResult.total);
      setAuditSummary(summary);
      setError(summary.status === 'unavailable' ? 'OpenSearch chưa sẵn sàng, chỉ hiển thị trạng thái rỗng.' : null);

      checkAuditAlerts(summary);
    } catch (loadError) {
      setLogs([]);
      setTotalLogs(0);
      setAuditSummary(DEFAULT_AUDIT_SUMMARY);
      setError(loadError instanceof Error ? loadError.message : 'Không thể tải nhật ký kiểm toán.');
    } finally {
      setIsAuditLoading(false);
    }
  }, [checkAuditAlerts, filters]);

  const refresh = useCallback(async () => {
    await Promise.all([loadSettings(), loadAuditLogs()]);
  }, [loadAuditLogs, loadSettings]);

  const setSettingValue = useCallback((key: string, value: SystemSetting['value']) => {
    setSettingsResponse((current) => {
      if (!current) return current;
      return {
        ...current,
        settings: current.settings.map((setting) => (setting.key === key ? { ...setting, value } : setting)),
      };
    });
  }, []);

  const savePreferences = useCallback(async (reason?: string) => {
    const settingsToSave: Array<{ key: string; value: SystemSetting['value'] }> = [];

    const currentSettings = settingsResponse?.settings ?? [];
    for (const setting of currentSettings) {
      if (setting.editable) {
        settingsToSave.push({ key: setting.key, value: setting.value });
      }
    }

    if (settingsToSave.length > 0) {
      setIsSavingSettings(true);
      try {
        const response = await updateSystemSettings(settingsToSave, reason);
        setSettingsResponse(response);
      } finally {
        setIsSavingSettings(false);
      }
    }
  }, [settingsResponse]);

  useEffect(() => {
    void loadSettings();
  }, [loadSettings]);

  useEffect(() => {
    void loadAuditLogs();
  }, [loadAuditLogs]);

  return {
    actionType,
    actorId,
    auditAlerts,
    auditSummary,
    dateRange,
    error,
    isAuditLoading,
    isSavingSettings,
    isSettingsLoading,
    logs,
    settingGroups: settingsResponse?.groups ?? [],
    settings: settingsResponse?.settings ?? [],
    status,
    totalLogs,
    setActionType,
    setActorId,
    setAuditAlerts,
    setDateRange,
    setSettingValue,
    setStatus,
    refresh,
    savePreferences,
  };
}
