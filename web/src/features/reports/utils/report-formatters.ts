const LABELS: Record<string, string> = {
  pending: "Chờ xử lý",
  approved: "Đã duyệt",
  rejected: "Từ chối",
  published: "Đã xuất bản",
  draft: "Nháp",
  cancelled: "Đã hủy",
  completed: "Đã hoàn thành",
  open: "Mở",
  closed: "Đóng",
  resolved: "Đã giải quyết",
  in_progress: "Đang xử lý",
  issued: "Đã cấp",
  used: "Đã dùng",
  expired: "Đã hết hạn",
  revoked: "Bị thu hồi",
  active: "Hoạt động",
  archived: "Lưu trữ",
  banned: "Đình chỉ",
  checked_in: "Đã check-in",
  registered: "Đã đăng ký",
  waitlisted: "Danh sách chờ",
  valid: "Khả dụng",
};

export function formatReportLabel(value: string): string {
  return LABELS[value.toLowerCase()] ?? value;
}

export function formatReportDate(value: string): string {
  return new Date(`${value}T00:00:00`).toLocaleDateString("vi-VN");
}

export function formatShortDate(value: string): string {
  const date = new Date(`${value}T00:00:00`);
  return `${date.getDate()}/${date.getMonth() + 1}`;
}

export function sumPoints(points: Array<{ count: number }>): number {
  return points.reduce((total, point) => total + point.count, 0);
}

export function percentage(value: number, total: number): number {
  return total ? Math.round((value / total) * 1000) / 10 : 0;
}
