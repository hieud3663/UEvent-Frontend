export type OrganizerRequestStatus =
  | "pending"
  | "approved"
  | "rejected"
  | "cancelled";

export interface OrganizerRequestUserDto {
  id: string;
  username: string;
  email: string;
  full_name: string;
  student_code?: string | null;
  faculty?: string | null;
}

export interface OrganizerRequestReviewerDto {
  id: string;
  username: string;
  email: string;
  full_name: string;
}

export interface OrganizerRequestDto {
  id: string;
  status: OrganizerRequestStatus;
  reason: string;
  proof_file_key: string;
  proof_file_name: string;
  proof_file_url: string;
  reviewed_by?: OrganizerRequestReviewerDto | null;
  reviewed_at?: string | null;
  review_note: string;
  created_at: string;
  updated_at: string;
  user: OrganizerRequestUserDto;
}

export interface OrganizerRequest {
  id: string;
  status: OrganizerRequestStatus;
  reason: string;
  proofFileKey: string;
  proofFileName: string;
  proofFileUrl: string;
  reviewedBy?: OrganizerRequestReviewerDto | null;
  reviewedAt?: string | null;
  reviewNote: string;
  createdAt: string;
  updatedAt: string;
  user: OrganizerRequestUserDto;
}

export interface OrganizerRequestStats {
  pending: number;
  approved: number;
  rejected: number;
  cancelled: number;
  total: number;
}
