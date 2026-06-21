import type { ReportOverview } from "../../types";
import { percentage, sumPoints } from "../../utils/report-formatters";
import { ColumnChart, DonutChart, TrendChart } from "../charts/ReportCharts";
import { ReportPanel, SummaryTiles } from "../ReportPrimitives";

export function TicketsReportTab({ overview }: { overview: ReportOverview }) {
  const registrations = sumPoints(overview.timeSeries.registrations ?? []);
  const tickets = sumPoints(overview.timeSeries.tickets ?? []);
  const checkins = sumPoints(overview.timeSeries.checkins ?? []);
  return (
    <div className="space-y-6">
      <SummaryTiles items={[
        { label: "Đăng ký", value: registrations },
        { label: "Vé phát hành", value: tickets },
        { label: "Check-in", value: checkins },
        { label: "Tỷ lệ check-in", value: `${percentage(checkins, registrations).toLocaleString("vi-VN")}%` },
      ]} />
      <ReportPanel title="Luồng đăng ký và check-in" description="So sánh đăng ký, vé phát hành và check-in theo thời gian."><TrendChart timeSeries={overview.timeSeries} seriesKeys={["registrations", "tickets", "checkins"]} /></ReportPanel>
      <div className="grid gap-6 xl:grid-cols-2">
        <ReportPanel title="Trạng thái đăng ký" description="Cơ cấu lượt đăng ký trong kỳ."><DonutChart rows={overview.breakdowns.registrations_by_status ?? []} /></ReportPanel>
        <ReportPanel title="Trạng thái vé" description="Cơ cấu vé theo trạng thái sử dụng."><DonutChart rows={overview.breakdowns.tickets_by_status ?? []} /></ReportPanel>
      </div>
      <ReportPanel title="Nhịp độ check-in" description="Số lượt check-in tại từng mốc thời gian."><ColumnChart points={overview.timeSeries.checkins ?? []} color="#16a34a" /></ReportPanel>
    </div>
  );
}
