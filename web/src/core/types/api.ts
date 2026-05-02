// File: src/core/types/api.ts

export interface ApiErrorResponse {
  code: string;
  message: string;
  details?: unknown;
  request_id?: string | null;
}

export interface PaginatedApiResponse<T> {
  count: number;
  next: string | null;
  previous: string | null;
  results: T[];
}

export interface ApiRequestOptions extends Omit<RequestInit, 'body'> {
  body?: unknown;
  auth?: boolean;
}

export interface ExportFileResult {
  blob: Blob;
  filename: string;
}
