"use client";

import { AppLoadingScreen, EmptyState, ErrorState } from "@/core/components";
import { useReportsWorkspace } from "../hooks/useReportsWorkspace";
import type { ReportTab } from "../types/workspace";
import { ReportControls, ReportHeader, ReportTabs } from "./ReportToolbar";
import { EventsReportTab } from "./tabs/EventsReportTab";
import { ExportReportTab } from "./tabs/ExportReportTab";
import { GrowthReportTab } from "./tabs/GrowthReportTab";
import { OperationsReportTab } from "./tabs/OperationsReportTab";
import { OverviewReportTab } from "./tabs/OverviewReportTab";
import { TicketsReportTab } from "./tabs/TicketsReportTab";
import { UsersReportTab } from "./tabs/UsersReportTab";

export function ReportsWorkspace() {
  const reports = useReportsWorkspace();

  if (reports.isLoading && !reports.overview) {
    return <AppLoadingScreen title="Đang tải báo cáo" description="Đang tổng hợp dữ liệu vận hành..." />;
  }

  if (reports.error) {
    return <ErrorState title="Không thể tải báo cáo" message={reports.error} retryLabel="Thử lại" onRetry={() => void reports.refresh()} />;
  }

  if (!reports.overview) {
    return <EmptyState title="Chưa có dữ liệu báo cáo" description="Hệ thống chưa trả về dữ liệu cho kỳ đã chọn." />;
  }

  return (
    <div className="space-y-6">
      <ReportHeader filters={reports.filters} isExporting={reports.isExporting} onRefresh={() => void reports.refresh()} onExport={reports.exportReport} />
      <ReportControls filters={reports.draftFilters} onChange={reports.setDraftFilters} onApply={reports.applyFilters} />
      <ReportTabs activeTab={reports.activeTab} onChange={reports.setActiveTab} />
      <section id={`report-panel-${reports.activeTab}`} role="tabpanel" aria-label={reports.activeTab} className="min-w-0">
        <ActiveReportTab
          tab={reports.activeTab}
          overview={reports.overview}
          filters={reports.filters}
          onExport={reports.exportReport}
          isExporting={reports.isExporting}
        />
      </section>
    </div>
  );
}

function ActiveReportTab({ tab, overview, filters, onExport, isExporting }: {
  tab: ReportTab;
  overview: NonNullable<ReturnType<typeof useReportsWorkspace>["overview"]>;
  filters: ReturnType<typeof useReportsWorkspace>["filters"];
  onExport: ReturnType<typeof useReportsWorkspace>["exportReport"];
  isExporting: boolean;
}) {
  switch (tab) {
    case "growth":
      return <GrowthReportTab overview={overview} />;
    case "events":
      return <EventsReportTab overview={overview} onExport={onExport} isExporting={isExporting} />;
    case "tickets":
      return <TicketsReportTab overview={overview} />;
    case "users":
      return <UsersReportTab overview={overview} />;
    case "operations":
      return <OperationsReportTab overview={overview} onExport={onExport} isExporting={isExporting} />;
    case "export":
      return <ExportReportTab filters={filters} onExport={onExport} isExporting={isExporting} />;
    default:
      return <OverviewReportTab overview={overview} />;
  }
}
