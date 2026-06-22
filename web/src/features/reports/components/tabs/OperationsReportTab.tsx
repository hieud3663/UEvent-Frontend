import { Button } from "@/core/components";
import type { ReportOverview } from "../../types";
import type { ReportExportHandler } from "../../types/workspace";
import { ColumnChart, DonutChart } from "../charts/ReportCharts";
import { ReportPanel, SummaryTiles } from "../ReportPrimitives";

export function OperationsReportTab({ overview, onExport, isExporting }: { overview: ReportOverview; onExport: ReportExportHandler; isExporting: boolean }) {
  const summary = overview.organizerRequestSummary;
  return (
    <div className="space-y-8">
      <section className="space-y-4" aria-labelledby="support-report-title">
        <div><h2 id="support-report-title" className="text-lg font-bold text-slate-950">Hỗ trợ người dùng</h2><p className="text-sm text-slate-500">Khối lượng, trạng thái và mức ưu tiên của ticket hỗ trợ.</p></div>
        <div className="grid gap-6 xl:grid-cols-2">
          <ReportPanel title="Xu hướng ticket" description="Ticket hỗ trợ mới theo thời gian."><ColumnChart points={overview.timeSeries.support ?? []} color="#dc2626" /></ReportPanel>
          <ReportPanel title="Trạng thái xử lý" description="Ticket đang mở, xử lý hoặc đã đóng."><DonutChart rows={overview.breakdowns.support_by_status ?? []} /></ReportPanel>
          <ReportPanel title="Mức độ ưu tiên" description="Phân bổ ticket theo độ ưu tiên."><DonutChart rows={overview.breakdowns.support_by_priority ?? []} /></ReportPanel>
        </div>
      </section>
      <section className="space-y-4" aria-labelledby="organizer-report-title">
        <div><h2 id="organizer-report-title" className="text-lg font-bold text-slate-950">Yêu cầu trở thành organizer</h2><p className="text-sm text-slate-500">Tình trạng xét duyệt quyền tổ chức sự kiện.</p></div>
        <SummaryTiles items={[{ label: "Tổng yêu cầu", value: summary.total }, { label: "Chờ duyệt", value: summary.pending }, { label: "Đã duyệt", value: summary.approved }, { label: "Tỷ lệ duyệt", value: `${summary.approvalRate.toLocaleString("vi-VN")}%` }]} />
        <ReportPanel title="Trạng thái yêu cầu" description="Phân bổ yêu cầu trong kỳ." action={<div className="flex gap-2"><Button size="sm" variant="outline" isLoading={isExporting} onClick={() => void onExport("csv", "organizer_requests")}>CSV</Button><Button size="sm" variant="outline" isLoading={isExporting} onClick={() => void onExport("xlsx", "organizer_requests")}>Excel</Button></div>}>
          <DonutChart rows={overview.breakdowns.organizer_requests_by_status ?? []} />
        </ReportPanel>
      </section>
    </div>
  );
}
