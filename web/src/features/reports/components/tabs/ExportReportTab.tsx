import { Download, FileSpreadsheet } from "lucide-react";
import { Button, Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/core/components";
import { EXPORT_OPTIONS, GROUP_BY_OPTIONS } from "../../constants";
import type { ReportFilters } from "../../types";
import type { ReportExportHandler } from "../../types/workspace";
import { formatReportDate } from "../../utils/report-formatters";

export function ExportReportTab({ filters, onExport, isExporting }: { filters: ReportFilters; onExport: ReportExportHandler; isExporting: boolean }) {
  const period = filters.fromDate && filters.toDate ? `${formatReportDate(filters.fromDate)} - ${formatReportDate(filters.toDate)}` : "Toàn bộ kỳ";
  const grouping = GROUP_BY_OPTIONS.find((option) => option.value === filters.groupBy)?.label ?? "Theo ngày";
  return (
    <div className="grid gap-6 xl:grid-cols-[1fr_320px]">
      <Card>
        <CardHeader><CardTitle>Chọn bộ dữ liệu</CardTitle><CardDescription className="mt-1">Mỗi file tuân theo bộ lọc đang áp dụng trên trang báo cáo.</CardDescription></CardHeader>
        <CardContent>
          <div className="divide-y divide-slate-100">
            {EXPORT_OPTIONS.map((item) => (
              <div key={item.type} className="flex flex-col gap-3 py-4 first:pt-0 last:pb-0 sm:flex-row sm:items-center sm:justify-between">
                <div><p className="font-semibold text-slate-950">{item.title}</p><p className="mt-0.5 text-sm text-slate-500">{item.description}</p></div>
                <div className="flex shrink-0 gap-2"><Button size="sm" variant="outline" isLoading={isExporting} leftIcon={<Download className="h-3.5 w-3.5" />} onClick={() => void onExport("csv", item.type)}>CSV</Button><Button size="sm" variant="outline" isLoading={isExporting} leftIcon={<FileSpreadsheet className="h-3.5 w-3.5" />} onClick={() => void onExport("xlsx", item.type)}>Excel</Button></div>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>
      <Card className="h-fit xl:sticky xl:top-6">
        <CardHeader><CardTitle>Phạm vi xuất</CardTitle><CardDescription className="mt-1">Thông tin áp dụng cho mọi file tải xuống.</CardDescription></CardHeader>
        <CardContent><dl className="space-y-4 text-sm"><div><dt className="text-slate-400">Khoảng thời gian</dt><dd className="mt-1 font-semibold text-slate-950">{period}</dd></div><div><dt className="text-slate-400">Độ chi tiết</dt><dd className="mt-1 font-semibold text-slate-950">{grouping}</dd></div><div><dt className="text-slate-400">Định dạng</dt><dd className="mt-1 font-semibold text-slate-950">CSV hoặc Excel (.xlsx)</dd></div></dl></CardContent>
      </Card>
    </div>
  );
}
