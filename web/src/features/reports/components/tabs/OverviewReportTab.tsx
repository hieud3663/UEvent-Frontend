import type { ReportOverview } from "../../types";
import { TrendChart } from "../charts/ReportCharts";
import { HealthScores, InsightList, MetricGrid, ReportPanel } from "../ReportPrimitives";

export function OverviewReportTab({ overview }: { overview: ReportOverview }) {
  return (
    <div className="space-y-6">
      <MetricGrid metrics={overview.metrics} />
      <ReportPanel title="Nhịp độ hoạt động" description="Sáu nhóm dữ liệu chính trong cùng kỳ báo cáo.">
        <TrendChart timeSeries={overview.timeSeries} />
      </ReportPanel>
      <div className="grid gap-6 xl:grid-cols-2">
        <ReportPanel title="Sức khỏe hệ thống" description="Tỷ lệ hiệu quả tổng hợp từ dữ liệu vận hành."><HealthScores items={overview.systemHealth} /></ReportPanel>
        <ReportPanel title="Điểm cần chú ý" description="Các tín hiệu cần theo dõi trong kỳ."><InsightList insights={overview.insights} /></ReportPanel>
      </div>
    </div>
  );
}
