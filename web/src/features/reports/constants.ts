import type { ReportExportType, ReportGroupBy } from "./types";

export const GROUP_BY_OPTIONS: Array<{ value: ReportGroupBy; label: string }> = [
  { value: "day", label: "Theo ngày" },
  { value: "week", label: "Theo tuần" },
  { value: "month", label: "Theo tháng" },
];

export const SERIES_LABELS: Record<string, string> = {
  users: "Người dùng",
  events: "Sự kiện",
  registrations: "Đăng ký",
  tickets: "Vé",
  checkins: "Check-in",
  support: "Hỗ trợ",
};

export const SERIES_COLORS: Record<string, string> = {
  users: "#2563eb",
  events: "#d97706",
  registrations: "#0f766e",
  tickets: "#7c3aed",
  checkins: "#16a34a",
  support: "#dc2626",
};

export const EXPORT_OPTIONS: Array<{
  type: ReportExportType;
  title: string;
  description: string;
}> = [
  { type: "all", title: "Toàn bộ báo cáo", description: "KPI, xu hướng, phân bổ và bảng xếp hạng." },
  { type: "overview", title: "Tổng quan điều hành", description: "Chỉ số chính và sức khỏe hệ thống." },
  { type: "time_series", title: "Dữ liệu xu hướng", description: "Tất cả chuỗi thời gian theo kỳ lọc." },
  { type: "events", title: "Sự kiện", description: "Hiệu suất, đăng ký, check-in và sức chứa." },
  { type: "status", title: "Phân bổ trạng thái", description: "Trạng thái của từng nhóm nghiệp vụ." },
  { type: "categories", title: "Danh mục", description: "Hiệu suất sự kiện theo danh mục." },
  { type: "faculties", title: "Khoa", description: "Phân bổ người tham gia theo khoa." },
  { type: "support", title: "Hỗ trợ", description: "Ticket theo trạng thái và mức ưu tiên." },
  { type: "organizer_requests", title: "Yêu cầu organizer", description: "Yêu cầu chờ, đã duyệt và từ chối." },
];
