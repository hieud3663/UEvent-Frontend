import { apiExport, apiRequest, apiRequestEnvelope } from '@/core/lib/api';
import type {
  AuditLogFilters,
  AuditLogResult,
  AuditSummary,
  LogActionType,
  LogEntry,
  SystemSetting,
  SystemSettingsResponse,
} from '../types';

interface AdminSettingDto {
  key: string;
  group: string;
  label: string;
  description: string;
  value_type: SystemSetting['valueType'];
  value: SystemSetting['value'];
  editable: boolean;
  updated_at?: string | null;
  updated_by?: string | null;
}

interface AdminSettingsDto {
  groups: SystemSettingsResponse['groups'];
  settings: AdminSettingDto[];
}

interface AdminAuditLogDto {
  id: string;
  timestamp: string;
  actor: {
    id: string;
    name: string;
    username?: string;
    email?: string;
  };
  action_type: string;
  target: {
    type: string;
    id: string;
  };
  reason: string;
  status: 'success' | 'failed';
  level: string;
  system_module: string;
  trace_id: string;
  metadata: Record<string, unknown>;
}

interface AdminAuditSummaryDto {
  total_events: number;
  failed_events: number;
  high_risk_events: number;
  last_event_at?: string | null;
  status: 'available' | 'unavailable';
}

export async function getSystemSettings(): Promise<SystemSettingsResponse> {
  const response = await apiRequest<AdminSettingsDto>('/admin/settings/');
  return {
    groups: response.groups,
    settings: response.settings.map(mapSetting),
  };
}

export async function updateSystemSettings(
  settings: Array<{ key: string; value: SystemSetting['value'] }>,
  reason = 'Cập nhật từ trang cài đặt quản trị.'
): Promise<SystemSettingsResponse> {
  const response = await apiRequest<AdminSettingsDto>('/admin/settings/', {
    method: 'PATCH',
    body: { settings, reason },
  });
  return {
    groups: response.groups,
    settings: response.settings.map(mapSetting),
  };
}

export async function getSystemLogs(filters: AuditLogFilters): Promise<AuditLogResult> {
  const params = buildAuditQueryParams(filters);
  const envelope = await apiRequestEnvelope<AdminAuditLogDto[]>(`/admin/audit-logs/?${params.toString()}`);
  const pagination = envelope.meta.pagination;
  const logs = envelope.data.map(mapAuditLog);

  return {
    logs,
    total: pagination?.count ?? logs.length,
    page: pagination?.page ?? filters.page ?? 1,
    pageSize: pagination?.page_size ?? filters.pageSize ?? logs.length,
    totalPages: pagination?.total_pages ?? 1,
  };
}

export async function getAuditSummary(): Promise<AuditSummary> {
  const response = await apiRequest<AdminAuditSummaryDto>('/admin/audit-logs/summary/');
  return mapAuditSummary(response);
}

export async function exportAuditLogs(filters: AuditLogFilters, exportFormat: 'csv' | 'xlsx' = 'csv'): Promise<void> {
  const params = buildAuditQueryParams(filters);
  params.set('export_format', exportFormat);

  const { blob, filename } = await apiExport(`/admin/audit-logs/export/?${params.toString()}`);
  const url = URL.createObjectURL(blob);
  const link = document.createElement('a');
  link.href = url;
  link.download = filename;
  link.click();
  URL.revokeObjectURL(url);
}

function mapSetting(dto: AdminSettingDto): SystemSetting {
  return {
    key: dto.key,
    group: dto.group,
    label: dto.label,
    description: dto.description,
    valueType: dto.value_type,
    value: dto.value,
    editable: dto.editable,
    updatedAt: dto.updated_at,
    updatedBy: dto.updated_by,
  };
}

function mapAuditLog(dto: AdminAuditLogDto): LogEntry {
  const timestamp = new Date(dto.timestamp);
  const actorName = dto.actor.name || dto.actor.username || dto.actor.email || 'Hệ thống';
  const actorSubtitle = dto.actor.email || dto.actor.username || undefined;

  return {
    id: dto.id,
    timestamp: dto.timestamp,
    date: new Intl.DateTimeFormat('vi-VN', { dateStyle: 'medium' }).format(timestamp),
    time: new Intl.DateTimeFormat('vi-VN', { timeStyle: 'medium' }).format(timestamp),
    user: {
      name: actorName,
      subtitle: actorSubtitle,
      initials: getInitials(actorName),
      color: getActorColor(actorName),
    },
    action: translateAuditAction(dto.action_type),
    target: [dto.target.type, dto.target.id].filter(Boolean).join(' • ') || 'Không xác định',
    reason: dto.reason || 'Không có ghi chú.',
    traceId: dto.trace_id,
    status: dto.status,
  };
}

function mapAuditSummary(dto: AdminAuditSummaryDto): AuditSummary {
  return {
    totalEvents: dto.total_events,
    failedEvents: dto.failed_events,
    highRiskEvents: dto.high_risk_events,
    lastEventAt: dto.last_event_at,
    status: dto.status,
  };
}

function buildAuditQueryParams(filters: AuditLogFilters): URLSearchParams {
  const { dateFrom, dateTo } = resolveDateRange(filters.dateRange);
  const params = new URLSearchParams({
    date_from: dateFrom.toISOString(),
    date_to: dateTo.toISOString(),
    page: String(filters.page ?? 1),
    page_size: String(filters.pageSize ?? 20),
  });

  const actionType = mapActionType(filters.actionType);
  if (actionType) params.set('action_type', actionType);
  if (filters.actorId?.trim()) params.set('actor_id', filters.actorId.trim());
  if (filters.actionType === 'error') {
    params.set('status', 'failed');
  } else if (filters.status && filters.status !== 'all') {
    params.set('status', filters.status);
  }

  return params;
}

function resolveDateRange(dateRange: AuditLogFilters['dateRange']): { dateFrom: Date; dateTo: Date } {
  const dateTo = new Date();
  const dateFrom = new Date(dateTo);
  const days = dateRange === '24hours' ? 1 : dateRange === '7days' ? 7 : 30;
  dateFrom.setDate(dateFrom.getDate() - days);
  return { dateFrom, dateTo };
}

function mapActionType(actionType: LogActionType): string | null {
  const actionMap: Record<LogActionType, string | null> = {
    all: null,
    error: null,
    settings: 'update_settings',
    security: 'ban_user',
    event: 'update_event_status',
  };
  return actionMap[actionType];
}

function translateAuditAction(actionType: string): string {
  const labels: Record<string, string> = {
    update_settings: 'Cập nhật cấu hình',
    export_audit_logs: 'Xuất nhật ký kiểm toán',
    ban_user: 'Khóa người dùng',
    unban_user: 'Mở khóa người dùng',
    soft_delete_user: 'Xóa mềm người dùng',
    update_event_status: 'Cập nhật trạng thái sự kiện',
    delete_event: 'Xóa sự kiện',
    publish_notification: 'Gửi thông báo',
    reply_support_ticket: 'Phản hồi ticket',
    resolve_support_ticket: 'Xử lý ticket',
  };
  return labels[actionType] ?? actionType.replaceAll('_', ' ');
}

function getInitials(name: string): string {
  return name
    .split(/\s+/)
    .filter(Boolean)
    .slice(0, 2)
    .map((part) => part[0]?.toUpperCase())
    .join('') || 'HT';
}

function getActorColor(name: string): LogEntry['user']['color'] {
  const colors: Array<LogEntry['user']['color']> = ['indigo', 'amber', 'emerald', 'purple', 'slate'];
  const index = Array.from(name).reduce((sum, char) => sum + char.charCodeAt(0), 0) % colors.length;
  return colors[index];
}
