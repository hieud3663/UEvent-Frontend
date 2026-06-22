import { Button } from "@/core/components";
import type { ReportOverview } from "../../types";
import type { ReportExportHandler } from "../../types/workspace";
import { DonutChart, HorizontalBarChart, JourneyChart } from "../charts/ReportCharts";
import { ReportPanel, TopEventsTable } from "../ReportPrimitives";

export function EventsReportTab({ overview, onExport, isExporting }: { overview: ReportOverview; onExport: ReportExportHandler; isExporting: boolean }) {
  return (
    <div className="space-y-6">
      <div className="grid gap-6 xl:grid-cols-2">
        <ReportPanel title="Trạng thái sự kiện" description="Cơ cấu sự kiện được tạo trong kỳ."><DonutChart rows={overview.breakdowns.events_by_status ?? []} /></ReportPanel>
        <ReportPanel title="Hành trình hoạt động" description="Khối lượng tại từng bước từ tạo sự kiện đến check-in."><JourneyChart steps={overview.funnel} /></ReportPanel>
      </div>
      <ReportPanel title="Hiệu suất danh mục" description="Xếp hạng theo lượt đăng ký, kèm số sự kiện.">
        <HorizontalBarChart rows={overview.categoryPerformance.map((item) => ({ label: item.label, value: item.registrationCount, helper: `${item.eventsCount.toLocaleString("vi-VN")} sự kiện` }))} />
      </ReportPanel>
      <ReportPanel title="Top sự kiện" description="Xếp hạng theo đăng ký, tỷ lệ check-in và mức lấp đầy." action={<div className="flex gap-2"><Button size="sm" variant="outline" isLoading={isExporting} onClick={() => void onExport("csv", "events")}>CSV</Button><Button size="sm" variant="outline" isLoading={isExporting} onClick={() => void onExport("xlsx", "events")}>Excel</Button></div>}>
        <TopEventsTable events={overview.topEvents} />
      </ReportPanel>
    </div>
  );
}
