import { apiRequest, apiRequestEnvelope } from "@/core/lib/api";
import type {
  OrganizerRequest,
  OrganizerRequestDto,
  OrganizerRequestStats,
  OrganizerRequestStatus,
} from "../types";

export interface OrganizerRequestFilters {
  status?: OrganizerRequestStatus | "all";
  keyword?: string;
  page?: number;
  pageSize?: number;
}

export interface OrganizerRequestsResponse {
  requests: OrganizerRequest[];
  total: number;
}

export async function getOrganizerRequests(
  filters: OrganizerRequestFilters = {},
): Promise<OrganizerRequestsResponse> {
  const params = new URLSearchParams();
  params.set("page", String(filters.page ?? 1));
  params.set("page_size", String(filters.pageSize ?? 20));

  if (filters.status && filters.status !== "all") {
    params.set("status", filters.status);
  }
  if (filters.keyword?.trim()) {
    params.set("search", filters.keyword.trim());
  }

  const envelope = await apiRequestEnvelope<OrganizerRequestDto[]>(
    `/admin/organizer-requests/?${params.toString()}`,
  );
  const requests = envelope.data.map(mapOrganizerRequest);
  return {
    requests,
    total: envelope.meta.pagination?.count ?? requests.length,
  };
}

export async function getOrganizerRequestStats(): Promise<OrganizerRequestStats> {
  return apiRequest<OrganizerRequestStats>(
    "/admin/organizer-requests/statistics/",
  );
}

export async function approveOrganizerRequest(
  requestId: string,
  note = "",
): Promise<OrganizerRequest> {
  const response = await apiRequest<OrganizerRequestDto>(
    `/admin/organizer-requests/${requestId}/approve/`,
    {
      method: "POST",
      body: { note },
    },
  );
  return mapOrganizerRequest(response);
}

export async function rejectOrganizerRequest(
  requestId: string,
  note = "",
): Promise<OrganizerRequest> {
  const response = await apiRequest<OrganizerRequestDto>(
    `/admin/organizer-requests/${requestId}/reject/`,
    {
      method: "POST",
      body: { note },
    },
  );
  return mapOrganizerRequest(response);
}

function mapOrganizerRequest(dto: OrganizerRequestDto): OrganizerRequest {
  return {
    id: dto.id,
    status: dto.status,
    reason: dto.reason,
    proofFileKey: dto.proof_file_key,
    proofFileName: dto.proof_file_name,
    proofFileUrl: dto.proof_file_url,
    reviewedBy: dto.reviewed_by,
    reviewedAt: dto.reviewed_at,
    reviewNote: dto.review_note,
    createdAt: dto.created_at,
    updatedAt: dto.updated_at,
    user: dto.user,
  };
}
