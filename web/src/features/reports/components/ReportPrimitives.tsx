import type { LucideIcon } from "lucide-react";
import { Activity, CalendarDays, Headphones, Ticket, TrendingUp, Users } from "lucide-react";
import { Badge, Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/core/components";
import type { ReportMetric, ReportOverview } from "../types";
import { formatReportLabel } from "../utils/report-formatters";

const METRIC_ICONS: Record<string, LucideIcon> = {
  users: Users,
  organizers: Users,
  events: CalendarDays,
  registrations: TrendingUp,
  tickets: Ticket,
  support: Headphones,
};

export function ReportPanel({ title, description, children, action, className }: {
  title: string;
  description?: string;
  children: React.ReactNode;
  action?: React.ReactNode;
  className?: string;
}) {
  return (
    <Card className={className}>
      <CardHeader className="flex flex-col gap-3 sm:flex-row sm:items-start sm:justify-between">
        <div>
          <CardTitle>{title}</CardTitle>
          {description ? <CardDescription className="mt-1">{description}</CardDescription> : null}
        </div>
        {action}
      </CardHeader>
      <CardContent>{children}</CardContent>
    </Card>
  );
}

export function MetricGrid({ metrics }: { metrics: ReportMetric[] }) {
  return (
    <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
      {metrics.map((metric) => {
        const Icon = METRIC_ICONS[metric.id] ?? Activity;
        return (
          <Card key={metric.id} className="p-5">
            <CardContent>
              <div className="flex items-start justify-between gap-4">
                <div className="min-w-0">
                  <p className="truncate text-sm font-medium text-slate-500">{metric.label}</p>
                  <p className="mt-1 text-3xl font-bold tabular-nums text-slate-950">{metric.value.toLocaleString("vi-VN")}</p>
                </div>
                <span className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-amber-100 text-amber-700"><Icon className="h-5 w-5" /></span>
              </div>
              <p className="mt-3 text-sm text-slate-600">{metric.helper}</p>
              <p className="mt-1 text-xs text-slate-400">{metric.description}</p>
            </CardContent>
          </Card>
        );
      })}
    </div>
  );
}

export function HealthScores({ items }: { items: ReportOverview["systemHealth"] }) {
  if (!items.length) return <p className="text-sm text-slate-500">Chưa có dữ liệu sức khỏe hệ thống.</p>;
  return (
    <div className="space-y-5">
      {items.map((item) => (
        <div key={item.id}>
          <div className="mb-2 flex items-center justify-between gap-4 text-sm">
            <span className="font-medium text-slate-700">{item.label}</span>
            <span className="font-bold text-slate-950">{item.score.toLocaleString("vi-VN")}%</span>
          </div>
          <div className="h-2.5 overflow-hidden rounded-full bg-slate-100"><div className="h-full rounded-full bg-teal-600" style={{ width: `${Math.min(100, Math.max(0, item.score))}%` }} /></div>
          <p className="mt-1 text-xs text-slate-400">{item.value.toLocaleString("vi-VN")} / {item.total.toLocaleString("vi-VN")}</p>
        </div>
      ))}
    </div>
  );
}

export function InsightList({ insights }: { insights: ReportOverview["insights"] }) {
  if (!insights.length) return <p className="text-sm text-slate-500">Không có điểm cần chú ý trong kỳ này.</p>;
  return (
    <div className="divide-y divide-slate-100">
      {insights.map((insight) => (
        <div key={`${insight.title}-${insight.description}`} className="flex gap-3 py-3 first:pt-0 last:pb-0">
          <span className="mt-2 h-2 w-2 shrink-0 rounded-full bg-amber-500" />
          <div className="min-w-0 flex-1">
            <div className="flex flex-wrap items-center justify-between gap-2">
              <p className="font-semibold text-slate-950">{insight.title}</p>
              <Badge variant={insight.severity === "warning" ? "warning" : insight.severity === "success" ? "success" : "info"}>
                {insight.severity === "warning" ? "Cần chú ý" : insight.severity === "success" ? "Tích cực" : "Thông tin"}
              </Badge>
            </div>
            <p className="mt-1 text-sm text-slate-500">{insight.description}</p>
          </div>
        </div>
      ))}
    </div>
  );
}

export function SummaryTiles({ items }: { items: Array<{ label: string; value: number | string; helper?: string }> }) {
  return (
    <div className="grid grid-cols-2 gap-3 lg:grid-cols-4">
      {items.map((item) => (
        <div key={item.label} className="rounded-xl border border-slate-200/70 bg-white/45 p-4">
          <p className="text-xs font-semibold uppercase text-slate-400">{item.label}</p>
          <p className="mt-1 text-2xl font-bold tabular-nums text-slate-950">{typeof item.value === "number" ? item.value.toLocaleString("vi-VN") : item.value}</p>
          {item.helper ? <p className="mt-1 text-xs text-slate-500">{item.helper}</p> : null}
        </div>
      ))}
    </div>
  );
}

export function TopEventsTable({ events }: { events: ReportOverview["topEvents"] }) {
  if (!events.length) return <p className="text-sm text-slate-500">Không có sự kiện trong kỳ lọc.</p>;
  return (
    <div className="overflow-x-auto">
      <table className="w-full min-w-[720px] text-left text-sm">
        <thead><tr className="border-b border-slate-200 text-xs uppercase text-slate-400">
          <th className="pb-3 pr-4 font-semibold">Sự kiện</th><th className="pb-3 pr-4 font-semibold">Danh mục</th><th className="pb-3 pr-4 text-right font-semibold">Đăng ký</th><th className="pb-3 pr-4 text-right font-semibold">Check-in</th><th className="pb-3 text-right font-semibold">Lấp đầy</th>
        </tr></thead>
        <tbody className="divide-y divide-slate-100">
          {events.map((event) => (
            <tr key={event.id} className="hover:bg-white/40">
              <td className="py-3 pr-4"><p className="font-semibold text-slate-950">{event.title}</p><p className="text-xs text-slate-400">{formatReportLabel(event.status)}</p></td>
              <td className="py-3 pr-4 text-slate-600">{event.category}</td>
              <td className="py-3 pr-4 text-right font-semibold tabular-nums">{event.registrationCount.toLocaleString("vi-VN")}</td>
              <td className="py-3 pr-4 text-right tabular-nums text-slate-600">{event.checkinRate.toLocaleString("vi-VN")}%</td>
              <td className="py-3 text-right tabular-nums text-slate-600">{event.capacityRate.toLocaleString("vi-VN")}%</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
