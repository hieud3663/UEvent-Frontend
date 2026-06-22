"use client";

import type { LucideIcon } from "lucide-react";
import { Activity, CalendarDays, Download, FileSpreadsheet, Headphones, RefreshCcw, Ticket, TrendingUp, Users } from "lucide-react";
import { AdminSelect, Badge, Button, Card, CardContent, Input } from "@/core/components";
import { cn } from "@/core/lib/utils";
import { GROUP_BY_OPTIONS } from "../constants";
import type { ReportFilters, ReportGroupBy } from "../types";
import type { ReportExportHandler, ReportTab } from "../types/workspace";
import { formatReportDate } from "../utils/report-formatters";

const TABS: Array<{ id: ReportTab; label: string; icon: LucideIcon }> = [
  { id: "overview", label: "Tổng quan", icon: Activity },
  { id: "growth", label: "Tăng trưởng", icon: TrendingUp },
  { id: "events", label: "Sự kiện", icon: CalendarDays },
  { id: "tickets", label: "Vé & check-in", icon: Ticket },
  { id: "users", label: "Người dùng", icon: Users },
  { id: "operations", label: "Vận hành", icon: Headphones },
  { id: "export", label: "Xuất dữ liệu", icon: Download },
];

export function ReportHeader({ filters, isExporting, onRefresh, onExport }: {
  filters: ReportFilters;
  isExporting: boolean;
  onRefresh: () => void;
  onExport: ReportExportHandler;
}) {
  return (
    <div className="flex flex-col gap-4 xl:flex-row xl:items-start xl:justify-between">
      <div>
        <h1 className="text-2xl font-bold tracking-tight text-on-surface">Báo cáo & Thống kê</h1>
        <p className="mt-1 text-sm text-on-surface-variant">Phân tích hoạt động sự kiện, người dùng và hiệu quả vận hành.</p>
        {filters.fromDate && filters.toDate ? (
          <Badge variant="neutral" className="mt-3 normal-case">{formatReportDate(filters.fromDate)} - {formatReportDate(filters.toDate)}</Badge>
        ) : null}
      </div>
      <div className="flex flex-wrap gap-2">
        <Button variant="secondary" leftIcon={<RefreshCcw className="h-4 w-4" />} onClick={onRefresh}>Làm mới</Button>
        <Button variant="outline" isLoading={isExporting} leftIcon={<Download className="h-4 w-4" />} onClick={() => void onExport("csv")}>CSV</Button>
        <Button variant="outline" isLoading={isExporting} leftIcon={<FileSpreadsheet className="h-4 w-4" />} onClick={() => void onExport("xlsx")}>Excel</Button>
      </div>
    </div>
  );
}

export function ReportControls({ filters, onChange, onApply }: {
  filters: ReportFilters;
  onChange: (filters: ReportFilters) => void;
  onApply: () => void;
}) {
  const invalidRange = Boolean(filters.fromDate && filters.toDate && filters.fromDate > filters.toDate);
  return (
    <Card className="p-4">
      <CardContent>
        <div className="grid gap-3 sm:grid-cols-2 xl:grid-cols-[1fr_1fr_180px_auto] xl:items-end">
          <Input type="date" label="Từ ngày" value={filters.fromDate ?? ""} onChange={(event) => onChange({ ...filters, fromDate: event.target.value })} className="h-10 rounded-xl border border-slate-200 bg-white/60 px-3 py-0 text-sm" />
          <Input type="date" label="Đến ngày" value={filters.toDate ?? ""} onChange={(event) => onChange({ ...filters, toDate: event.target.value })} error={invalidRange ? "Ngày kết thúc phải sau ngày bắt đầu." : undefined} className="h-10 rounded-xl border border-slate-200 bg-white/60 px-3 py-0 text-sm" />
          <div className="space-y-2">
            <label className="ml-1 block text-xs font-bold uppercase tracking-widest text-on-surface-variant">Nhóm dữ liệu</label>
            <AdminSelect options={GROUP_BY_OPTIONS} value={filters.groupBy ?? "day"} onChange={(value) => onChange({ ...filters, groupBy: value as ReportGroupBy })} ariaLabel="Nhóm dữ liệu theo thời gian" />
          </div>
          <Button disabled={invalidRange || !filters.fromDate || !filters.toDate} onClick={onApply} className="w-full xl:w-auto">Áp dụng</Button>
        </div>
      </CardContent>
    </Card>
  );
}

export function ReportTabs({ activeTab, onChange }: { activeTab: ReportTab; onChange: (tab: ReportTab) => void }) {
  return (
    <div className="overflow-x-auto pb-1" role="tablist" aria-label="Nhóm báo cáo">
      <div className="inline-flex min-w-full gap-1 rounded-2xl border border-white/60 bg-white/45 p-1.5 shadow-sm backdrop-blur-xl">
        {TABS.map((tab) => {
          const Icon = tab.icon;
          return (
            <button key={tab.id} type="button" role="tab" aria-selected={activeTab === tab.id} aria-controls={`report-panel-${tab.id}`} onClick={() => onChange(tab.id)} className={cn("inline-flex h-10 flex-1 items-center justify-center gap-2 whitespace-nowrap rounded-xl px-3 text-sm font-semibold transition-colors focus:outline-none focus:ring-2 focus:ring-amber-500", activeTab === tab.id ? "bg-amber-500 text-white shadow-sm" : "text-slate-600 hover:bg-white/70 hover:text-slate-950")}>
              <Icon className="h-4 w-4" />{tab.label}
            </button>
          );
        })}
      </div>
    </div>
  );
}
