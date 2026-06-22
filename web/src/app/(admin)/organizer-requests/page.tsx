"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import { CheckCircle2, FileCheck, Search, XCircle } from "lucide-react";
import { ErrorState, ListSkeleton, PromptActionDialog } from "@/core/components";
import { runActionWithToast } from "@/core/lib/runActionWithToast";
import {
  approveOrganizerRequest,
  getOrganizerRequests,
  getOrganizerRequestStats,
  rejectOrganizerRequest,
} from "@/features/organizer-requests/services/organizer-requests.service";
import type {
  OrganizerRequest,
  OrganizerRequestStats,
  OrganizerRequestStatus,
} from "@/features/organizer-requests/types";
import { cn } from "@/core/lib/utils";
import { EmptyState } from "@/core/components";

const statusOptions: Array<{
  value: OrganizerRequestStatus | "all";
  label: string;
}> = [
  { value: "all", label: "Tất cả" },
  { value: "pending", label: "Chờ duyệt" },
  { value: "approved", label: "Đã duyệt" },
  { value: "rejected", label: "Từ chối" },
  { value: "cancelled", label: "Đã hủy" },
];

const statusLabel: Record<OrganizerRequestStatus, string> = {
  pending: "Chờ duyệt",
  approved: "Đã duyệt",
  rejected: "Từ chối",
  cancelled: "Đã hủy",
};

const statusClassName: Record<OrganizerRequestStatus, string> = {
  pending: "bg-amber-100 text-amber-700",
  approved: "bg-emerald-100 text-emerald-700",
  rejected: "bg-red-100 text-red-700",
  cancelled: "bg-slate-200 text-slate-600",
};

export default function OrganizerRequestsPage() {
  const [requests, setRequests] = useState<OrganizerRequest[]>([]);
  const [stats, setStats] = useState<OrganizerRequestStats | null>(null);
  const [status, setStatus] = useState<OrganizerRequestStatus | "all">(
    "pending",
  );
  const [keyword, setKeyword] = useState("");
  const [submittedKeyword, setSubmittedKeyword] = useState("");
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [processingId, setProcessingId] = useState<string | null>(null);
  const [promptOpen, setPromptOpen] = useState(false);
  const [promptAction, setPromptAction] = useState<"approve" | "reject" | null>(null);
  const [promptRequest, setPromptRequest] = useState<OrganizerRequest | null>(null);

  const loadData = useCallback(async () => {
    setIsLoading(true);
    setError(null);
    try {
      const [requestPage, nextStats] = await Promise.all([
        getOrganizerRequests({
          status,
          keyword: submittedKeyword,
          pageSize: 50,
        }),
        getOrganizerRequestStats(),
      ]);
      setRequests(requestPage.requests);
      setStats(nextStats);
    } catch (loadError) {
      setError(
        loadError instanceof Error
          ? loadError.message
          : "Không thể tải danh sách yêu cầu.",
      );
    } finally {
      setIsLoading(false);
    }
  }, [status, submittedKeyword]);

  useEffect(() => {
    void loadData();
  }, [loadData]);

  const statCards = useMemo(
    () => [
      { label: "Tổng yêu cầu", value: stats?.total ?? 0 },
      { label: "Chờ duyệt", value: stats?.pending ?? 0, color: "text-amber-600" },
      { label: "Đã duyệt", value: stats?.approved ?? 0, color: "text-emerald-600" },
      { label: "Từ chối", value: stats?.rejected ?? 0, color: "text-red-500" },
    ],
    [stats],
  );

  function handleReviewClick(
    request: OrganizerRequest,
    action: "approve" | "reject",
  ) {
    setPromptRequest(request);
    setPromptAction(action);
    setPromptOpen(true);
  }

  async function processReview(note: string) {
    if (!promptRequest || !promptAction) return;

    setProcessingId(promptRequest.id);
    const request = promptRequest;
    const action = promptAction;

    try {
      await runActionWithToast(
        () =>
          action === "approve"
            ? approveOrganizerRequest(request.id, note)
            : rejectOrganizerRequest(request.id, note),
        {
          loading:
            action === "approve"
              ? "Đang duyệt yêu cầu..."
              : "Đang từ chối yêu cầu...",
          success:
            action === "approve" ? "Đã duyệt yêu cầu." : "Đã từ chối yêu cầu.",
        },
      );
      await loadData();
    } finally {
      setProcessingId(null);
    }
  }

  if (isLoading) {
    return <ListSkeleton rows={8} />;
  }

  if (error) {
    return (
      <ErrorState
        title="Không thể tải yêu cầu tổ chức"
        message={error}
        retryLabel="Thử lại"
        onRetry={() => void loadData()}
      />
    );
  }

  return (
    <div className="space-y-8">
      {/* Header Section */}
      <div className="flex flex-col gap-4 md:flex-row md:items-end md:justify-between">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-on-surface">
            Yêu cầu tổ chức
          </h1>
          <p className="mt-1 text-sm font-medium text-slate-500">
            Duyệt quyền trở thành người tổ chức sự kiện cho người dùng.
          </p>
        </div>
      </div>

      {/* Dashboard Stats Bento Style */}
      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 md:grid-cols-4">
        {statCards.map((item) => (
          <div
            key={item.label}
            className="glass-card flex flex-col gap-1 rounded-2xl p-5"
          >
            <span className="text-[10px] font-bold uppercase tracking-widest text-slate-500">
              {item.label}
            </span>
            <span className={cn("text-2xl font-black", item.color ?? "text-on-surface")}>
              {item.value.toLocaleString("vi-VN")}
            </span>
          </div>
        ))}
      </div>

      {/* Filters & Search */}
      <div className="glass-card flex flex-col justify-between gap-4 rounded-2xl p-4 lg:flex-row lg:items-center">
        <div className="flex flex-wrap gap-2">
          {statusOptions.map((option) => (
            <button
              key={option.value}
              type="button"
              onClick={() => setStatus(option.value)}
              className={cn(
                "rounded-lg px-4 py-2 text-xs font-bold transition-all",
                status === option.value
                  ? "bg-amber-500 text-white shadow-md shadow-amber-500/20"
                  : "border border-white/60 bg-white/50 text-slate-600 hover:bg-white",
              )}
            >
              {option.label}
            </button>
          ))}
        </div>
        <form
          className="flex min-w-0 flex-1 gap-2 lg:max-w-md lg:justify-end"
          onSubmit={(event) => {
            event.preventDefault();
            setSubmittedKeyword(keyword);
          }}
        >
          <div className="relative flex-1">
            <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 pointer-events-none text-slate-400" />
            <input
              value={keyword}
              onChange={(event) => setKeyword(event.target.value)}
              className="h-10 w-full rounded-xl border border-white/60 bg-white/50 pl-10 pr-4 text-sm font-medium outline-none transition-all placeholder:text-slate-400 focus:border-amber-400 focus:bg-white focus:ring-4 focus:ring-amber-500/10"
              placeholder="Tìm user, email, tài liệu..."
            />
          </div>
          <button
            type="submit"
            className="h-10 rounded-xl bg-slate-800 px-5 text-sm font-bold text-white transition-all hover:bg-slate-700 active:scale-95"
          >
            Tìm
          </button>
        </form>
      </div>

      {/* Main Data Table */}
      <div className="glass-card overflow-hidden rounded-[32px] shadow-2xl shadow-black/5">
        <div className="overflow-x-auto">
          <table className="min-w-[820px] w-full border-collapse text-left">
            <thead>
              <tr className="border-b border-white/40">
                <th className="px-6 py-5 text-[10px] font-black uppercase tracking-[0.1em] text-slate-400">
                  Người dùng
                </th>
                <th className="px-6 py-5 text-[10px] font-black uppercase tracking-[0.1em] text-slate-400">
                  Tài liệu
                </th>
                <th className="px-6 py-5 text-[10px] font-black uppercase tracking-[0.1em] text-slate-400">
                  Lý do
                </th>
                <th className="px-6 py-5 text-[10px] font-black uppercase tracking-[0.1em] text-slate-400">
                  Trạng thái
                </th>
                <th className="px-6 py-5 text-[10px] font-black uppercase tracking-[0.1em] text-slate-400 text-right">
                  Thao tác
                </th>
              </tr>
            </thead>
            <tbody className="divide-y divide-white/20">
              {requests.map((request) => (
                <tr
                  key={request.id}
                  className="group transition-colors hover:bg-white/40"
                >
                  <td className="px-6 py-4">
                    <div className="flex flex-col">
                      <span className="text-sm font-bold text-on-surface">
                        {request.user.full_name || request.user.username}
                      </span>
                      <span className="text-xs font-medium text-slate-500">
                        {request.user.email}
                      </span>
                    </div>
                  </td>
                  <td className="px-6 py-4">
                    {request.proofFileUrl ? (
                      <a
                        href={request.proofFileUrl}
                        target="_blank"
                        rel="noreferrer"
                        className="inline-flex items-center gap-1.5 text-xs font-bold text-amber-600 transition-colors hover:text-amber-700 hover:underline"
                      >
                        <FileCheck className="h-4 w-4" />
                        {request.proofFileName || "Xem tài liệu"}
                      </a>
                    ) : (
                      <span className="text-xs font-medium text-slate-400">
                        {request.proofFileName || "Không có tài liệu"}
                      </span>
                    )}
                  </td>
                  <td className="px-6 py-4">
                    <p className="line-clamp-2 max-w-[200px] text-xs font-medium text-slate-600" title={request.reason}>
                      {request.reason}
                    </p>
                  </td>
                  <td className="px-6 py-4">
                    <div className="flex flex-col items-start gap-1.5">
                      <span
                        className={cn(
                          "rounded-full px-2.5 py-1 text-[10px] font-black uppercase",
                          statusClassName[request.status],
                        )}
                      >
                        {statusLabel[request.status]}
                      </span>
                      <span className="text-xs font-mono font-medium text-slate-500">
                        {new Date(request.createdAt).toLocaleDateString("vi-VN")}
                      </span>
                    </div>
                  </td>
                  <td className="px-6 py-4 text-right">
                    <div className="flex justify-end gap-2">
                      <button
                        type="button"
                        disabled={
                          request.status !== "pending" ||
                          processingId === request.id
                        }
                        onClick={() => handleReviewClick(request, "approve")}
                        className="inline-flex min-w-[80px] items-center justify-center gap-1.5 rounded-lg border border-emerald-100 bg-emerald-50 px-3 py-2 text-[11px] font-bold text-emerald-600 shadow-sm transition-all hover:bg-emerald-500 hover:text-white disabled:pointer-events-none disabled:opacity-50"
                      >
                        <CheckCircle2 className="h-3.5 w-3.5" />
                        Duyệt
                      </button>
                      <button
                        type="button"
                        disabled={
                          request.status !== "pending" ||
                          processingId === request.id
                        }
                        onClick={() => handleReviewClick(request, "reject")}
                        className="inline-flex min-w-[80px] items-center justify-center gap-1.5 rounded-lg border border-red-100 bg-red-50 px-3 py-2 text-[11px] font-bold text-red-500 shadow-sm transition-all hover:bg-red-500 hover:text-white disabled:pointer-events-none disabled:opacity-50"
                      >
                        <XCircle className="h-3.5 w-3.5" />
                        Từ chối
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {requests.length === 0 && !isLoading ? (
          <div className="p-6">
            <EmptyState
              title="Không có yêu cầu"
              description="Không tìm thấy yêu cầu phù hợp với bộ lọc hiện tại."
            />
          </div>
        ) : null}
      </div>

      <PromptActionDialog
        open={promptOpen}
        onOpenChange={setPromptOpen}
        title={promptAction === "approve" ? "Duyệt yêu cầu" : "Từ chối yêu cầu"}
        description={
          promptAction === "approve"
            ? `Bạn có chắc chắn muốn duyệt quyền Organizer cho người dùng ${promptRequest?.user.full_name || promptRequest?.user.username}?`
            : `Vui lòng nhập lý do từ chối quyền Organizer của ${promptRequest?.user.full_name || promptRequest?.user.username}.`
        }
        placeholder={promptAction === "approve" ? "Ghi chú duyệt (tùy chọn)" : "Lý do từ chối (bắt buộc)"}
        confirmLabel={promptAction === "approve" ? "Duyệt" : "Từ chối"}
        variant={promptAction === "approve" ? "success" : "danger"}
        onConfirm={processReview}
      />
    </div>
  );
}
