'use client';

import type { ReactNode } from 'react';
import { useMemo, useState } from 'react';
import { Calendar, Download, RefreshCw, Save, Settings, Shield, ShieldAlert, TerminalSquare, Verified } from 'lucide-react';
import { toast } from 'sonner';
import { AdminSelect, Button, Card, EmptyState } from '@/core/components';
import { cn } from '@/core/lib/utils';
import { runActionWithToast } from '@/core/lib/runActionWithToast';
import { useSystemSettings } from '@/features/settings/hooks/useSystemSettings';
import { exportAuditLogs } from '@/features/settings/services/settings.service';
import type { LogActionType, LogDateRange, SystemSetting } from '@/features/settings/types';

interface StatsCardProps {
  icon: ReactNode;
  iconBg: string;
  iconColor: string;
  label: string;
  value: string;
  badge?: {
    text: string;
    color: 'emerald' | 'red' | 'amber';
  };
}

const DATE_RANGE_OPTIONS: Array<{ value: LogDateRange; label: string }> = [
  { value: '24hours', label: '24 giờ qua' },
  { value: '7days', label: '7 ngày qua' },
  { value: '30days', label: '30 ngày qua' },
];

const ACTION_OPTIONS: Array<{ value: LogActionType; label: string }> = [
  { value: 'all', label: 'Tất cả thao tác' },
  { value: 'settings', label: 'Cấu hình' },
  { value: 'security', label: 'Bảo mật' },
  { value: 'event', label: 'Sự kiện' },
  { value: 'error', label: 'Lỗi' },
];

const STATUS_OPTIONS = [
  { value: 'all', label: 'Mọi trạng thái' },
  { value: 'success', label: 'Thành công' },
  { value: 'failed', label: 'Thất bại' },
] as const;

function SettingsStatsCard({ icon, iconBg, iconColor, label, value, badge }: StatsCardProps) {
  return (
    <Card className="border border-white/70 bg-white/80 p-5 shadow-sm backdrop-blur-xl">
      <div className="flex items-start justify-between gap-4">
        <span className={cn('rounded-xl p-2.5', iconBg, iconColor)}>{icon}</span>
        {badge ? (
          <span
            className={cn(
              'rounded-full px-2 py-0.5 text-[10px] font-bold',
              badge.color === 'emerald' && 'bg-emerald-50 text-emerald-600',
              badge.color === 'red' && 'bg-red-50 text-red-600',
              badge.color === 'amber' && 'bg-amber-50 text-amber-600'
            )}
          >
            {badge.text}
          </span>
        ) : null}
      </div>
      <div className="mt-5">
        <p className="text-[10px] font-bold uppercase tracking-widest text-slate-500">{label}</p>
        <p className="mt-1 text-2xl font-black leading-tight text-on-surface">{value}</p>
      </div>
    </Card>
  );
}

export default function SettingsPage() {
  const {
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
    settingGroups,
    settings,
    setActionType,
    setActorId,
    setAuditAlerts,
    setDateRange,
    setSettingValue,
    setStatus,
    status,
    totalLogs,
    refresh,
    savePreferences,
  } = useSystemSettings();
  const [jsonDrafts, setJsonDrafts] = useState<Record<string, string>>({});
  const [jsonErrors, setJsonErrors] = useState<Record<string, string>>({});

  const auditFilters = { dateRange, actionType, actorId, status };
  const editableSettings = useMemo(() => settings.filter((setting) => setting.editable), [settings]);

  const handleExport = async (format: 'csv' | 'xlsx') => {
    const formatLabel = format === 'xlsx' ? 'Excel' : 'CSV';
    await runActionWithToast(() => exportAuditLogs(auditFilters, format), {
      loading: `Đang xuất nhật ký kiểm toán sang ${formatLabel}...`,
      success: `Đã tải file nhật ký kiểm toán ${formatLabel}.`,
      error: `Không thể xuất nhật ký kiểm toán ${formatLabel}.`,
    });
  };

  const handleSaveSettings = async () => {
    if (Object.keys(jsonErrors).length > 0) {
      toast.error('Vui lòng sửa cấu hình JSON chưa hợp lệ trước khi lưu.');
      return;
    }

    await runActionWithToast(() => savePreferences('Cập nhật từ trang cài đặt quản trị.'), {
      loading: 'Đang lưu cấu hình hệ thống...',
      success: 'Đã lưu cấu hình hệ thống.',
      error: 'Không thể lưu cấu hình hệ thống.',
    });
  };

  const groupedSettings = settingGroups.map((group) => ({
    ...group,
    settings: settings.filter((setting) => setting.group === group.id),
  }));

  const lastAuditAt = auditSummary?.lastEventAt
    ? new Intl.DateTimeFormat('vi-VN', { dateStyle: 'medium', timeStyle: 'short' }).format(new Date(auditSummary.lastEventAt))
    : 'Chưa có dữ liệu';

  return (
    <div className="space-y-8">
      <div className="flex flex-col gap-4 md:flex-row md:items-end md:justify-between">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-on-surface">Cài đặt và nhật ký kiểm toán</h1>
          <p className="mt-1 text-sm font-medium text-on-surface-variant">
            Quản lý cấu hình vận hành, audit log và xuất dữ liệu kiểm toán.
          </p>
        </div>
        <Button
          variant="secondary"
          onClick={() => {
            void refresh();
          }}
          leftIcon={<RefreshCw className="h-4 w-4" />}
        >
          Làm mới
        </Button>
      </div>

      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-4">
        <SettingsStatsCard
          icon={<TerminalSquare className="h-5 w-5" />}
          iconBg="bg-blue-100"
          iconColor="text-blue-600"
          label="Audit trong bộ lọc"
          value={isAuditLoading ? '...' : totalLogs.toLocaleString('vi-VN')}
          badge={{ text: auditSummary?.status === 'available' ? 'Live' : 'Offline', color: auditSummary?.status === 'available' ? 'emerald' : 'amber' }}
        />
        <SettingsStatsCard
          icon={<ShieldAlert className="h-5 w-5" />}
          iconBg="bg-red-100"
          iconColor="text-red-600"
          label="Sự kiện thất bại"
          value={(auditSummary?.failedEvents ?? 0).toLocaleString('vi-VN')}
          badge={{ text: '24h', color: 'red' }}
        />
        <SettingsStatsCard
          icon={<Shield className="h-5 w-5" />}
          iconBg="bg-purple-100"
          iconColor="text-purple-600"
          label="Sự kiện rủi ro cao"
          value={(auditSummary?.highRiskEvents ?? 0).toLocaleString('vi-VN')}
        />
        <SettingsStatsCard
          icon={<Verified className="h-5 w-5" />}
          iconBg="bg-amber-100"
          iconColor="text-amber-600"
          label="Audit gần nhất"
          value={lastAuditAt}
        />
      </div>

      <section className="space-y-4">
        <div className="flex flex-col gap-3 sm:flex-row sm:items-end sm:justify-between">
          <div>
            <p className="text-xs font-bold uppercase tracking-widest text-amber-600">Cấu hình hệ thống</p>
            <h2 className="mt-1 text-xl font-black text-slate-900"></h2>
          </div>
          <Button
            onClick={() => {
              void handleSaveSettings();
            }}
            disabled={isSettingsLoading || isSavingSettings || editableSettings.length === 0}
            leftIcon={<Save className="h-4 w-4" />}
          >
            {isSavingSettings ? 'Đang lưu...' : 'Lưu cấu hình'}
          </Button>
        </div>

        <Card className="border border-white/70 bg-white/80 p-5 shadow-sm backdrop-blur-xl sm:p-6">
          <ToggleRow
            title="Cảnh báo kiểm toán"
            description="Hiện toast khi phát hiện sự kiện thất bại hoặc rủi ro cao. Tùy chọn này chỉ lưu trên trình duyệt."
            checked={auditAlerts}
            disabled={false}
            onChange={setAuditAlerts}
          />
        </Card>

        {isSettingsLoading ? (
          <div className="grid gap-3">
            {Array.from({ length: 4 }).map((_, index) => (
              <div key={index} className="h-24 animate-pulse rounded-2xl bg-white/70" />
            ))}
          </div>
        ) : groupedSettings.length === 0 ? (
          <EmptyState title="Chưa có cấu hình hệ thống" description="API chưa trả về setting nào để hiển thị." className="bg-white/70" />
        ) : (
          <div className="grid gap-5">
            {groupedSettings.map((group) => (
              <Card key={group.id} className="border border-white/70 bg-white/80 p-5 shadow-sm backdrop-blur-xl sm:p-6">
                <div className="mb-5 flex gap-3">
                  <Settings className="mt-0.5 h-5 w-5 shrink-0 text-amber-500" />
                  <div>
                    <h3 className="text-lg font-bold text-on-surface">{group.label}</h3>
                    <p className="mt-1 text-sm text-on-surface-variant">{group.description}</p>
                  </div>
                </div>
                <div className="grid gap-4">
                  {group.settings.map((setting) => (
                    <SettingField
                      key={setting.key}
                      setting={setting}
                      jsonDraft={jsonDrafts[setting.key] ?? formatJsonValue(setting.value)}
                      jsonError={jsonErrors[setting.key]}
                      onChange={(value) => setSettingValue(setting.key, value)}
                      onJsonDraftChange={(value) => {
                        setJsonDrafts((current) => ({ ...current, [setting.key]: value }));
                        try {
                          setSettingValue(setting.key, JSON.parse(value) as SystemSetting['value']);
                          setJsonErrors((current) => {
                            const next = { ...current };
                            delete next[setting.key];
                            return next;
                          });
                        } catch {
                          setJsonErrors((current) => ({ ...current, [setting.key]: 'JSON không hợp lệ.' }));
                        }
                      }}
                    />
                  ))}
                </div>
              </Card>
            ))}
          </div>
        )}
      </section>

      <section className="space-y-6">
        <div>
          <p className="text-xs font-bold uppercase tracking-widest text-slate-500">Nhật ký kiểm toán</p>
          <h2 className="mt-1 text-xl font-black text-slate-900">Truy vấn và xuất audit log</h2>
        </div>

        <Card className="relative z-30 border border-white/70 bg-white/80 p-4 shadow-sm backdrop-blur-xl sm:p-5">
          <div className="flex flex-wrap items-center gap-3">
            <div className="w-full sm:w-auto sm:min-w-[9rem]">
              <AdminSelect
                value={dateRange}
                onChange={(nextValue) => setDateRange(nextValue as LogDateRange)}
                options={DATE_RANGE_OPTIONS}
                ariaLabel="Chọn khoảng thời gian nhật ký"
                leftIcon={<Calendar className="h-[14px] w-[14px] text-slate-400" />}
              />
            </div>
            <div className="w-full sm:w-auto sm:min-w-[10rem]">
              <AdminSelect
                value={actionType}
                onChange={(nextValue) => setActionType(nextValue as LogActionType)}
                options={ACTION_OPTIONS}
                ariaLabel="Lọc loại thao tác kiểm toán"
              />
            </div>
            <div className="w-full sm:w-auto sm:min-w-[9rem]">
              <AdminSelect
                value={status}
                onChange={(nextValue) => setStatus(nextValue as 'all' | 'success' | 'failed')}
                options={STATUS_OPTIONS}
                ariaLabel="Lọc trạng thái kiểm toán"
              />
            </div>
            <input
              value={actorId}
              onChange={(event) => setActorId(event.target.value)}
              className="h-11 w-full flex-1 basis-[10rem] rounded-xl border border-slate-200 bg-white px-4 text-sm font-medium text-slate-800 outline-none transition focus:border-amber-500 focus:ring-4 focus:ring-amber-500/10 sm:w-auto"
              placeholder="Lọc theo mã quản trị viên"
            />
            <div className="flex gap-2">
              <Button
                variant="secondary"
                onClick={() => {
                  void handleExport('csv');
                }}
                leftIcon={<Download className="h-4 w-4" />}
              >
                CSV
              </Button>
              <Button
                variant="secondary"
                onClick={() => {
                  void handleExport('xlsx');
                }}
              >
                Excel
              </Button>
            </div>
          </div>
        </Card>

        {error ? (
          <div className="rounded-2xl border border-amber-200 bg-amber-50 px-4 py-3 text-sm font-medium text-amber-800">
            {error}
          </div>
        ) : null}

        <Card className="overflow-hidden border border-white/70 bg-white/75 shadow-sm backdrop-blur-xl">
          <div className="flex flex-col gap-3 border-b border-slate-100 px-4 py-4 sm:px-6 md:flex-row md:items-center md:justify-between">
            <div>
              <p className="text-xs font-bold uppercase tracking-widest text-slate-500">Nhật ký kiểm toán</p>
              <p className="mt-1 text-sm text-slate-600">Dữ liệu được truy vấn từ OpenObserve theo bộ lọc hiện tại.</p>
            </div>
            <p className="text-sm font-bold text-slate-600">{totalLogs.toLocaleString('vi-VN')} bản ghi</p>
          </div>

          {isAuditLoading ? (
            <div className="grid gap-3 p-4 sm:p-6">
              {Array.from({ length: 5 }).map((_, index) => (
                <div key={index} className="h-16 animate-pulse rounded-2xl bg-slate-100" />
              ))}
            </div>
          ) : logs.length === 0 ? (
            <EmptyState
              title="Chưa có nhật ký phù hợp"
              description="Hãy đổi khoảng thời gian hoặc bộ lọc để xem thêm bản ghi kiểm toán."
              className="m-4 bg-white/70 sm:m-6"
            />
          ) : (
            <div className="overflow-x-auto">
              <table className="min-w-[860px] w-full border-collapse text-left">
                <thead>
                  <tr className="border-b border-slate-100 bg-slate-50/60">
                    <th className="px-6 py-4 text-[10px] font-bold uppercase tracking-widest text-slate-400">Thời điểm</th>
                    <th className="px-6 py-4 text-[10px] font-bold uppercase tracking-widest text-slate-400">Người thực hiện</th>
                    <th className="px-6 py-4 text-[10px] font-bold uppercase tracking-widest text-slate-400">Thao tác</th>
                    <th className="px-6 py-4 text-[10px] font-bold uppercase tracking-widest text-slate-400">Đối tượng</th>
                    <th className="px-6 py-4 text-right text-[10px] font-bold uppercase tracking-widest text-slate-400">Trạng thái</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100">
                  {logs.map((log) => (
                    <tr key={log.id} className="transition-colors hover:bg-amber-50/30">
                      <td className="px-6 py-4">
                        <p className="text-sm font-semibold text-slate-900">{log.date}</p>
                        <p className="text-[11px] font-mono text-slate-400">{log.time}</p>
                      </td>
                      <td className="px-6 py-4">
                        <div className="flex items-center gap-3">
                          <div
                            className={cn(
                              'flex h-8 w-8 items-center justify-center rounded-full text-xs font-bold',
                              log.user.color === 'indigo' && 'bg-indigo-100 text-indigo-600',
                              log.user.color === 'amber' && 'bg-amber-100 text-amber-600',
                              log.user.color === 'emerald' && 'bg-emerald-100 text-emerald-600',
                              log.user.color === 'purple' && 'bg-purple-100 text-purple-600',
                              log.user.color === 'slate' && 'bg-slate-100 text-slate-600'
                            )}
                          >
                            {log.user.initials}
                          </div>
                          <div>
                            <p className="text-sm font-bold text-slate-900">{log.user.name}</p>
                            <p className="text-[11px] text-slate-400">{log.user.subtitle || log.traceId || 'Không có trace'}</p>
                          </div>
                        </div>
                      </td>
                      <td className="px-6 py-4">
                        <p className="text-sm font-bold text-slate-800">{log.action}</p>
                        <p className="line-clamp-1 text-xs text-slate-500">{log.reason}</p>
                      </td>
                      <td className="px-6 py-4 text-sm text-slate-600">{log.target}</td>
                      <td className="px-6 py-4 text-right">
                        <span
                          className={cn(
                            'rounded-full px-2.5 py-1 text-[10px] font-bold uppercase tracking-wider whitespace-nowrap',
                            log.status === 'success' && 'bg-emerald-100 text-emerald-700',
                            log.status === 'failed' && 'bg-red-100 text-red-700'
                          )}
                        >
                          {log.status === 'success' ? 'Thành công' : 'Thất bại'}
                        </span>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </Card>
      </section>
    </div>
  );
}

function SettingField({
  setting,
  jsonDraft,
  jsonError,
  onChange,
  onJsonDraftChange,
}: {
  setting: SystemSetting;
  jsonDraft: string;
  jsonError?: string;
  onChange: (value: SystemSetting['value']) => void;
  onJsonDraftChange: (value: string) => void;
}) {
  const disabled = !setting.editable;

  return (
    <div className="grid gap-3 rounded-2xl border border-slate-100 bg-white/70 p-4 lg:grid-cols-[1fr_22rem] lg:items-start">
      <div>
        <p className="text-sm font-bold text-slate-900">{setting.label}</p>
        <p className="mt-1 text-xs leading-relaxed text-slate-500">{setting.description || setting.key}</p>
        <p className="mt-2 text-[10px] font-bold uppercase tracking-widest text-slate-400">{setting.key}</p>
      </div>
      <div>
        {setting.valueType === 'boolean' ? (
          <ToggleRow title={String(setting.value ? 'Đang bật' : 'Đang tắt')} description="" checked={Boolean(setting.value)} disabled={disabled} onChange={onChange} />
        ) : setting.valueType === 'integer' ? (
          <input
            type="number"
            value={Number(setting.value ?? 0)}
            disabled={disabled}
            onChange={(event) => onChange(Number(event.target.value))}
            className="h-11 w-full rounded-xl border border-slate-200 bg-white px-4 text-sm font-medium text-slate-800 outline-none transition focus:border-amber-500 focus:ring-4 focus:ring-amber-500/10 disabled:cursor-not-allowed disabled:bg-slate-50 disabled:text-slate-400"
          />
        ) : setting.valueType === 'json' ? (
          <>
            <textarea
              value={jsonDraft}
              disabled={disabled}
              onChange={(event) => onJsonDraftChange(event.target.value)}
              className="min-h-28 w-full rounded-xl border border-slate-200 bg-white px-4 py-3 font-mono text-xs text-slate-800 outline-none transition focus:border-amber-500 focus:ring-4 focus:ring-amber-500/10 disabled:cursor-not-allowed disabled:bg-slate-50 disabled:text-slate-400"
            />
            {jsonError ? <p className="mt-2 text-xs font-bold text-red-600">{jsonError}</p> : null}
          </>
        ) : (
          <input
            type="text"
            value={String(setting.value ?? '')}
            disabled={disabled}
            onChange={(event) => onChange(event.target.value)}
            className="h-11 w-full rounded-xl border border-slate-200 bg-white px-4 text-sm font-medium text-slate-800 outline-none transition focus:border-amber-500 focus:ring-4 focus:ring-amber-500/10 disabled:cursor-not-allowed disabled:bg-slate-50 disabled:text-slate-400"
          />
        )}
      </div>
    </div>
  );
}

function ToggleRow({
  title,
  description,
  checked,
  disabled,
  onChange,
}: {
  title: string;
  description: string;
  checked: boolean;
  disabled: boolean;
  onChange: (value: boolean) => void;
}) {
  return (
    <div className="flex items-center justify-between gap-4">
      <div className="space-y-1">
        <p className="font-bold text-slate-900">{title}</p>
        {description ? <p className="text-xs leading-relaxed text-slate-500">{description}</p> : null}
      </div>
      <label className={cn('relative inline-flex items-center', disabled ? 'cursor-not-allowed opacity-60' : 'cursor-pointer')}>
        <input
          type="checkbox"
          className="peer sr-only"
          checked={checked}
          disabled={disabled}
          onChange={(event) => onChange(event.target.checked)}
        />
        <div className="h-6 w-11 rounded-full bg-slate-200 after:absolute after:left-[2px] after:top-[2px] after:h-5 after:w-5 after:rounded-full after:border after:border-gray-300 after:bg-white after:transition-all after:content-[''] peer-checked:bg-amber-500 peer-checked:after:translate-x-full peer-checked:after:border-white peer-focus:outline-none" />
      </label>
    </div>
  );
}

function formatJsonValue(value: SystemSetting['value']): string {
  try {
    return JSON.stringify(value ?? {}, null, 2);
  } catch {
    return '{}';
  }
}
