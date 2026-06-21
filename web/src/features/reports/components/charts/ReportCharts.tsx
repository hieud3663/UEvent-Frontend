"use client";

import { SERIES_COLORS, SERIES_LABELS } from "../../constants";
import type { ReportBreakdownItem, ReportTimeSeriesPoint } from "../../types";
import { formatReportLabel, formatShortDate } from "../../utils/report-formatters";

const DONUT_COLORS = ["#d97706", "#2563eb", "#0f766e", "#7c3aed", "#dc2626", "#64748b"];

function EmptyChart() {
  return (
    <div className="flex min-h-56 items-center justify-center rounded-2xl border border-dashed border-slate-200 bg-white/30 px-4 text-center text-sm text-slate-500">
      Không có dữ liệu trong kỳ lọc.
    </div>
  );
}

export function TrendChart({ timeSeries, seriesKeys }: { timeSeries: Record<string, ReportTimeSeriesPoint[]>; seriesKeys?: string[] }) {
  const names = (seriesKeys ?? Object.keys(timeSeries)).filter((name) => timeSeries[name]?.length);
  const periods = Array.from(new Set(names.flatMap((name) => timeSeries[name].map((point) => point.period)))).sort();
  const maxValue = Math.max(1, ...names.flatMap((name) => timeSeries[name].map((point) => point.count)));
  if (!names.length || !periods.length) return <EmptyChart />;

  const width = 820;
  const height = 320;
  const left = 52;
  const top = 20;
  const plotWidth = 750;
  const plotHeight = 258;

  return (
    <div>
      <div className="overflow-x-auto">
        <svg viewBox={`0 0 ${width} ${height}`} className="min-h-[280px] min-w-[720px] w-full" role="img" aria-label={`Biểu đồ xu hướng ${names.map((name) => SERIES_LABELS[name] ?? name).join(", ")}`}>
          <title>Xu hướng theo thời gian</title>
          <desc>Mỗi đường biểu diễn số lượng của một nhóm dữ liệu trong kỳ lọc.</desc>
          {[0, 0.25, 0.5, 0.75, 1].map((ratio) => {
            const y = top + plotHeight - plotHeight * ratio;
            return (
              <g key={ratio}>
                <line x1={left} x2={width - 18} y1={y} y2={y} stroke="#e2e8f0" />
                <text x={left - 10} y={y + 4} textAnchor="end" className="fill-slate-400 text-[11px]">{Math.round(maxValue * ratio).toLocaleString("vi-VN")}</text>
              </g>
            );
          })}
          {names.map((name) => {
            const values = new Map(timeSeries[name].map((point) => [point.period, point.count]));
            const points = periods.map((period, index) => ({
              period,
              value: values.get(period) ?? 0,
              x: left + (periods.length === 1 ? plotWidth / 2 : (index / (periods.length - 1)) * plotWidth),
              y: top + plotHeight - ((values.get(period) ?? 0) / maxValue) * plotHeight,
            }));
            const color = SERIES_COLORS[name] ?? "#64748b";
            return (
              <g key={name}>
                <path d={points.map((point, index) => `${index ? "L" : "M"} ${point.x} ${point.y}`).join(" ")} fill="none" stroke={color} strokeWidth="3" strokeLinecap="round" strokeLinejoin="round" />
                {points.map((point) => (
                  <circle key={`${name}-${point.period}`} cx={point.x} cy={point.y} r="3.5" fill="white" stroke={color} strokeWidth="2">
                    <title>{`${SERIES_LABELS[name] ?? name}, ${point.period}: ${point.value}`}</title>
                  </circle>
                ))}
              </g>
            );
          })}
          {periods.map((period, index) => {
            const interval = Math.max(1, Math.ceil(periods.length / 7));
            if (index % interval !== 0 && index !== periods.length - 1) return null;
            const x = left + (periods.length === 1 ? plotWidth / 2 : (index / (periods.length - 1)) * plotWidth);
            return <text key={period} x={x} y={height - 12} textAnchor="middle" className="fill-slate-500 text-[11px]">{formatShortDate(period)}</text>;
          })}
        </svg>
      </div>
      <div className="mt-4 flex flex-wrap gap-x-5 gap-y-2">
        {names.map((name) => (
          <span key={name} className="inline-flex items-center gap-2 text-xs font-medium text-slate-600">
            <span className="h-2.5 w-2.5 rounded-sm" style={{ backgroundColor: SERIES_COLORS[name] ?? "#64748b" }} />
            {SERIES_LABELS[name] ?? name}
          </span>
        ))}
      </div>
    </div>
  );
}

export function DonutChart({ rows }: { rows: ReportBreakdownItem[] }) {
  const total = rows.reduce((sum, row) => sum + row.count, 0);
  if (!rows.length || !total) return <EmptyChart />;
  const segments = rows.reduce<Array<ReportBreakdownItem & { length: number; offset: number; color: string }>>(
    (items, row, index) => {
      const length = (row.count / total) * 264;
      const consumed = items.reduce((sum, item) => sum + item.length, 0);
      return [...items, { ...row, length, offset: 25 - consumed, color: DONUT_COLORS[index % DONUT_COLORS.length] }];
    },
    [],
  );

  return (
    <div className="grid min-h-56 gap-6 sm:grid-cols-[180px_1fr] sm:items-center">
      <svg viewBox="0 0 120 120" className="mx-auto h-44 w-44 -rotate-90" role="img" aria-label={`Biểu đồ phân bổ, tổng ${total}`}>
        <title>Phân bổ theo trạng thái</title>
        <circle cx="60" cy="60" r="42" fill="none" stroke="#e2e8f0" strokeWidth="16" />
        {segments.map((segment) => (
          <circle key={segment.label} cx="60" cy="60" r="42" fill="none" stroke={segment.color} strokeWidth="16" strokeDasharray={`${segment.length} ${264 - segment.length}`} strokeDashoffset={segment.offset}>
            <title>{`${formatReportLabel(segment.label)}: ${segment.count} (${segment.percentage}%)`}</title>
          </circle>
        ))}
        <g className="rotate-90" style={{ transformOrigin: "60px 60px" }}>
          <text x="60" y="58" textAnchor="middle" className="fill-slate-950 text-xl font-bold">{total.toLocaleString("vi-VN")}</text>
          <text x="60" y="74" textAnchor="middle" className="fill-slate-500 text-[9px]">tổng</text>
        </g>
      </svg>
      <div className="space-y-3">
        {segments.map((row) => (
          <div key={row.label} className="flex items-center justify-between gap-3 text-sm">
            <span className="flex min-w-0 items-center gap-2 text-slate-600"><span className="h-2.5 w-2.5 shrink-0 rounded-sm" style={{ backgroundColor: row.color }} /><span className="truncate">{formatReportLabel(row.label)}</span></span>
            <span className="whitespace-nowrap font-semibold text-slate-950">{row.count.toLocaleString("vi-VN")} <span className="font-normal text-slate-400">({row.percentage.toLocaleString("vi-VN")}%)</span></span>
          </div>
        ))}
      </div>
    </div>
  );
}

export function HorizontalBarChart({ rows, color = "#d97706" }: { rows: Array<{ label: string; value: number; helper?: string }>; color?: string }) {
  const max = Math.max(1, ...rows.map((row) => row.value));
  if (!rows.length) return <EmptyChart />;
  return (
    <div className="space-y-4" role="img" aria-label="Biểu đồ thanh ngang">
      {rows.map((row) => (
        <div key={row.label}>
          <div className="mb-1.5 flex items-end justify-between gap-3 text-sm">
            <div className="min-w-0"><p className="truncate font-medium text-slate-700">{formatReportLabel(row.label)}</p>{row.helper ? <p className="text-xs text-slate-400">{row.helper}</p> : null}</div>
            <span className="font-bold text-slate-950">{row.value.toLocaleString("vi-VN")}</span>
          </div>
          <div className="h-2.5 overflow-hidden rounded-full bg-slate-100"><div className="h-full rounded-full" style={{ width: `${Math.max(2, (row.value / max) * 100)}%`, backgroundColor: color }} /></div>
        </div>
      ))}
    </div>
  );
}

export function ColumnChart({ points, color = "#2563eb" }: { points: ReportTimeSeriesPoint[]; color?: string }) {
  const visible = points.slice(-18);
  const max = Math.max(1, ...visible.map((point) => point.count));
  if (!visible.length) return <EmptyChart />;
  return (
    <div className="overflow-x-auto">
      <div className="flex h-64 min-w-[540px] items-end gap-2 border-b border-slate-200 px-1 pt-6" role="img" aria-label="Biểu đồ cột theo thời gian">
        {visible.map((point, index) => (
          <div key={point.period} className="flex h-full flex-1 flex-col items-center justify-end gap-2">
            <span className="text-[10px] font-semibold text-slate-500">{point.count || ""}</span>
            <div className="w-full max-w-9 rounded-t-md" style={{ height: `${Math.max(3, (point.count / max) * 190)}px`, backgroundColor: color }} title={`${point.period}: ${point.count}`} />
            <span className="h-4 text-[10px] text-slate-400">{index % Math.max(1, Math.ceil(visible.length / 7)) === 0 || index === visible.length - 1 ? formatShortDate(point.period) : ""}</span>
          </div>
        ))}
      </div>
    </div>
  );
}

export function JourneyChart({ steps }: { steps: Array<{ id: string; label: string; value: number }> }) {
  const max = Math.max(1, ...steps.map((step) => step.value));
  if (!steps.length) return <EmptyChart />;
  return (
    <div className="space-y-4">
      {steps.map((step, index) => (
        <div key={step.id} className="grid grid-cols-[28px_1fr_auto] items-center gap-3">
          <span className="flex h-7 w-7 items-center justify-center rounded-lg bg-amber-100 text-xs font-bold text-amber-700">{index + 1}</span>
          <div className="min-w-0"><p className="mb-1.5 truncate text-sm font-medium text-slate-700">{step.label}</p><div className="h-2 overflow-hidden rounded-full bg-slate-100"><div className="h-full rounded-full bg-amber-500" style={{ width: `${Math.max(2, (step.value / max) * 100)}%` }} /></div></div>
          <span className="font-bold tabular-nums text-slate-950">{step.value.toLocaleString("vi-VN")}</span>
        </div>
      ))}
    </div>
  );
}
