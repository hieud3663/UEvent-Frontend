export type ReportGroupBy = "day" | "week" | "month";
export type ReportExportFormat = "csv" | "xlsx";
export type ReportExportType =
  | "all"
  | "overview"
  | "time_series"
  | "status"
  | "categories"
  | "faculties"
  | "events"
  | "support"
  | "organizer_requests";

export interface ReportFilters {
  fromDate?: string;
  toDate?: string;
  groupBy?: ReportGroupBy;
}

export interface ReportMetricDto {
  id: string;
  label: string;
  value: number;
  helper: string;
  description?: string;
}

export interface ReportTimeSeriesPointDto {
  period: string;
  count: number;
}

export interface ReportBreakdownItemDto {
  label: string;
  count: number;
  percentage: number;
}

export interface ReportFunnelStepDto {
  id: string;
  label: string;
  value: number;
}

export interface ReportCategoryPerformanceDto {
  label: string;
  events_count: number;
  registration_count: number;
}

export interface ReportFacultyDistributionDto {
  label: string;
  count: number;
}

export interface ReportTopEventDto {
  id: string;
  title: string;
  status: string;
  category: string;
  max_capacity: number;
  registration_count: number;
  checkin_count: number;
  checkin_rate: number;
  capacity_rate: number;
}

export interface ReportOrganizerRequestSummaryDto {
  total: number;
  pending: number;
  approved: number;
  rejected: number;
  approval_rate: number;
}

export interface ReportHealthItemDto {
  id: string;
  label: string;
  value: number;
  total: number;
  score: number;
}

export interface ReportInsightDto {
  title: string;
  description: string;
  severity: "success" | "warning" | "info" | string;
}

export interface ReportOverviewDto {
  generated_at: string;
  filters?: {
    from_date: string;
    to_date: string;
    group_by: ReportGroupBy;
  };
  metrics: ReportMetricDto[];
  time_series?: Record<string, ReportTimeSeriesPointDto[]>;
  breakdowns?: Record<
    string,
    Array<ReportBreakdownItemDto | Record<string, string | number | null>>
  >;
  funnel?: ReportFunnelStepDto[];
  category_performance?: ReportCategoryPerformanceDto[];
  faculty_distribution?: ReportFacultyDistributionDto[];
  top_events: ReportTopEventDto[];
  organizer_request_summary?: ReportOrganizerRequestSummaryDto;
  system_health?: ReportHealthItemDto[];
  insights?: ReportInsightDto[];
}

export interface ReportMetric {
  id: string;
  label: string;
  value: number;
  helper: string;
  description: string;
}

export interface ReportTimeSeriesPoint {
  period: string;
  count: number;
}

export interface ReportBreakdownItem {
  label: string;
  count: number;
  percentage: number;
}

export interface ReportFunnelStep {
  id: string;
  label: string;
  value: number;
}

export interface ReportCategoryPerformance {
  label: string;
  eventsCount: number;
  registrationCount: number;
}

export interface ReportFacultyDistribution {
  label: string;
  count: number;
}

export interface ReportTopEvent {
  id: string;
  title: string;
  status: string;
  category: string;
  maxCapacity: number;
  registrationCount: number;
  checkinCount: number;
  checkinRate: number;
  capacityRate: number;
}

export interface ReportOrganizerRequestSummary {
  total: number;
  pending: number;
  approved: number;
  rejected: number;
  approvalRate: number;
}

export interface ReportHealthItem {
  id: string;
  label: string;
  value: number;
  total: number;
  score: number;
}

export interface ReportInsight {
  title: string;
  description: string;
  severity: "success" | "warning" | "info" | string;
}

export interface ReportOverview {
  generatedAt: string;
  filters: {
    fromDate: string;
    toDate: string;
    groupBy: ReportGroupBy;
  };
  metrics: ReportMetric[];
  timeSeries: Record<string, ReportTimeSeriesPoint[]>;
  breakdowns: Record<string, ReportBreakdownItem[]>;
  funnel: ReportFunnelStep[];
  categoryPerformance: ReportCategoryPerformance[];
  facultyDistribution: ReportFacultyDistribution[];
  topEvents: ReportTopEvent[];
  organizerRequestSummary: ReportOrganizerRequestSummary;
  systemHealth: ReportHealthItem[];
  insights: ReportInsight[];
}
