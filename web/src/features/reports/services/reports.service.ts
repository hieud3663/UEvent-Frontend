import { apiExport, apiRequest } from "@/core/lib/api";
import type { ExportFileResult } from "@/core/types/api";
import type {
  ReportBreakdownItem,
  ReportExportFormat,
  ReportExportType,
  ReportFilters,
  ReportGroupBy,
  ReportOverview,
  ReportOverviewDto,
} from "../types";

export async function getReportOverview(
  filters: ReportFilters = {},
): Promise<ReportOverview> {
  const params = buildReportParams(filters);
  const query = params.toString();
  const response = await apiRequest<ReportOverviewDto>(
    `/admin/reports/overview/${query ? `?${query}` : ""}`,
  );
  return mapReportOverview(response, filters);
}

export async function exportAdminReport(
  filters: ReportFilters = {},
  reportType: ReportExportType = "all",
  format: ReportExportFormat = "csv",
): Promise<ExportFileResult> {
  const params = buildReportParams(filters);
  params.set("report_type", reportType);
  params.set("export_format", format);
  return apiExport(`/admin/reports/export/?${params.toString()}`);
}

export function downloadReportFile(result: ExportFileResult): void {
  if (typeof window === "undefined") return;

  const url = window.URL.createObjectURL(result.blob);
  const link = document.createElement("a");
  link.href = url;
  link.download = result.filename;
  document.body.appendChild(link);
  link.click();
  link.remove();
  window.URL.revokeObjectURL(url);
}

function buildReportParams(filters: ReportFilters): URLSearchParams {
  const params = new URLSearchParams();
  if (filters.fromDate) params.set("from_date", filters.fromDate);
  if (filters.toDate) params.set("to_date", filters.toDate);
  if (filters.groupBy) params.set("group_by", filters.groupBy);
  return params;
}

function mapReportOverview(
  dto: ReportOverviewDto,
  requestFilters: ReportFilters,
): ReportOverview {
  const fallbackFromDate = requestFilters.fromDate ?? defaultFromDate();
  const fallbackToDate = requestFilters.toDate ?? todayDate();
  const fallbackGroupBy = requestFilters.groupBy ?? "day";
  const breakdowns = mapBreakdowns(dto.breakdowns ?? {});
  const organizerBreakdown = breakdowns.organizer_requests_by_status ?? [];
  const approvedRequests = countBreakdown(organizerBreakdown, "approved");
  const rejectedRequests = countBreakdown(organizerBreakdown, "rejected");

  return {
    generatedAt: dto.generated_at ?? new Date().toISOString(),
    filters: {
      fromDate: dto.filters?.from_date ?? fallbackFromDate,
      toDate: dto.filters?.to_date ?? fallbackToDate,
      groupBy: normalizeGroupBy(dto.filters?.group_by ?? fallbackGroupBy),
    },
    metrics: (dto.metrics ?? []).map((metric) => ({
      id: metric.id,
      label: metric.label,
      value: metric.value,
      helper: metric.helper,
      description: metric.description ?? "",
    })),
    timeSeries: dto.time_series ?? {},
    breakdowns,
    funnel: dto.funnel ?? [],
    categoryPerformance: (dto.category_performance ?? []).map((item) => ({
      label: item.label,
      eventsCount: item.events_count,
      registrationCount: item.registration_count,
    })),
    facultyDistribution: dto.faculty_distribution ?? [],
    topEvents: (dto.top_events ?? []).map((event) => ({
      id: event.id,
      title: event.title,
      status: event.status,
      category: event.category ?? "Chưa phân loại",
      maxCapacity: event.max_capacity ?? 0,
      registrationCount: event.registration_count,
      checkinCount: event.checkin_count ?? 0,
      checkinRate: event.checkin_rate ?? 0,
      capacityRate: event.capacity_rate ?? 0,
    })),
    organizerRequestSummary: {
      total:
        dto.organizer_request_summary?.total ??
        organizerBreakdown.reduce((sum, row) => sum + row.count, 0),
      pending:
        dto.organizer_request_summary?.pending ??
        countBreakdown(organizerBreakdown, "pending"),
      approved: dto.organizer_request_summary?.approved ?? approvedRequests,
      rejected: dto.organizer_request_summary?.rejected ?? rejectedRequests,
      approvalRate:
        dto.organizer_request_summary?.approval_rate ??
        percentage(approvedRequests, approvedRequests + rejectedRequests),
    },
    systemHealth: dto.system_health ?? [],
    insights: dto.insights ?? [],
  };
}

function mapBreakdowns(
  breakdowns: NonNullable<ReportOverviewDto["breakdowns"]>,
): Record<string, ReportBreakdownItem[]> {
  return Object.fromEntries(
    Object.entries(breakdowns).map(([key, rows]) => {
      const total = rows.reduce((sum, row) => sum + Number(row.count ?? 0), 0);
      return [
        key,
        rows.map((row) => {
          const label =
            "label" in row && row.label != null
              ? String(row.label)
              : String(
                  Object.entries(row).find(
                    ([field]) => field !== "count",
                  )?.[1] ?? "N/A",
                );
          const count = Number(row.count ?? 0);
          const rawPercentage =
            "percentage" in row ? Number(row.percentage) : NaN;
          return {
            label,
            count,
            percentage: Number.isFinite(rawPercentage)
              ? rawPercentage
              : percentage(count, total),
          };
        }),
      ];
    }),
  );
}

function countBreakdown(rows: ReportBreakdownItem[], status: string): number {
  return rows.find((row) => row.label === status)?.count ?? 0;
}

function normalizeGroupBy(value: string): ReportGroupBy {
  return value === "week" || value === "month" ? value : "day";
}

function percentage(numerator: number, denominator: number): number {
  if (!denominator) return 0;
  return Math.round((numerator / denominator) * 10000) / 100;
}

function defaultFromDate(): string {
  const date = new Date();
  date.setDate(date.getDate() - 89);
  return date.toISOString().slice(0, 10);
}

function todayDate(): string {
  return new Date().toISOString().slice(0, 10);
}
