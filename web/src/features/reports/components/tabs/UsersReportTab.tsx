import type { ReportOverview } from "../../types";
import { ColumnChart, DonutChart, HorizontalBarChart } from "../charts/ReportCharts";
import { ReportPanel } from "../ReportPrimitives";

export function UsersReportTab({ overview }: { overview: ReportOverview }) {
  return (
    <div className="space-y-6">
      <div className="grid gap-6 xl:grid-cols-2">
        <ReportPanel title="Tăng trưởng người dùng" description="Tài khoản mới theo từng mốc thời gian."><ColumnChart points={overview.timeSeries.users ?? []} color="#2563eb" /></ReportPanel>
        <ReportPanel title="Trạng thái tài khoản" description="Phân bổ tài khoản mới theo trạng thái."><DonutChart rows={overview.breakdowns.users_by_status ?? []} /></ReportPanel>
      </div>
      <ReportPanel title="Phân bổ người tham gia theo khoa" description="Các khoa có số lượt đăng ký nổi bật trong kỳ.">
        <HorizontalBarChart rows={overview.facultyDistribution.map((item) => ({ label: item.label, value: item.count }))} color="#2563eb" />
      </ReportPanel>
    </div>
  );
}
