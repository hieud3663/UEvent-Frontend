"use client";

import { useState } from "react";
import { Button } from "@/core/components";
import { cn } from "@/core/lib/utils";
import { SERIES_LABELS } from "../../constants";
import type { ReportOverview } from "../../types";
import { sumPoints } from "../../utils/report-formatters";
import { ColumnChart, HorizontalBarChart, TrendChart } from "../charts/ReportCharts";
import { ReportPanel } from "../ReportPrimitives";

const GROUPS = {
  acquisition: { label: "Tiếp cận", keys: ["users", "events"] },
  engagement: { label: "Tương tác", keys: ["registrations", "tickets", "checkins"] },
  operations: { label: "Vận hành", keys: ["support"] },
} as const;

export function GrowthReportTab({ overview }: { overview: ReportOverview }) {
  const [group, setGroup] = useState<keyof typeof GROUPS>("engagement");
  const selected = GROUPS[group];
  const totals = Object.entries(overview.timeSeries).map(([key, points]) => ({ label: SERIES_LABELS[key] ?? key, value: sumPoints(points) }));
  return (
    <div className="space-y-6">
      <ReportPanel
        title="Xu hướng tăng trưởng"
        description="Chọn một nhóm để so sánh các chuỗi có cùng ngữ cảnh."
        action={<div className="flex flex-wrap gap-1 rounded-xl bg-white/50 p-1">{Object.entries(GROUPS).map(([key, item]) => <Button key={key} size="sm" variant="ghost" onClick={() => setGroup(key as keyof typeof GROUPS)} className={cn(group === key && "bg-white text-slate-950 shadow-sm")}>{item.label}</Button>)}</div>}
      >
        <TrendChart timeSeries={overview.timeSeries} seriesKeys={[...selected.keys]} />
      </ReportPanel>
      <div className="grid gap-6 xl:grid-cols-2">
        <ReportPanel title="Tổng khối lượng theo module" description="Tổng số bản ghi phát sinh trong kỳ."><HorizontalBarChart rows={totals} color="#0f766e" /></ReportPanel>
        <ReportPanel title="Người dùng mới" description="Phân bố tài khoản mới theo thời gian."><ColumnChart points={overview.timeSeries.users ?? []} color="#2563eb" /></ReportPanel>
      </div>
    </div>
  );
}
