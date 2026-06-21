import type { ReportExportFormat, ReportExportType } from ".";

export type ReportTab =
  | "overview"
  | "growth"
  | "events"
  | "tickets"
  | "users"
  | "operations"
  | "export";

export type ReportExportHandler = (
  format: ReportExportFormat,
  type?: ReportExportType,
) => Promise<void>;
