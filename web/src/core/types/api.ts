// File: src/core/types/api.ts

import type { ApiEnvelope, ApiPaginationMeta, ApiResponseMeta } from '@/core/types/apiEnvelope';

export type { ApiEnvelope, ApiPaginationMeta, ApiResponseMeta };

export interface ApiErrorResponse {
  success: false;
  code: string;
  message: string;
  data: null;
  errors?: unknown;
  meta: ApiResponseMeta;
}

export interface LegacyApiErrorResponse {
  code: string;
  message: string;
  details?: unknown;
  request_id?: string | null;
}

export interface PaginatedApiResponse<T> extends ApiEnvelope<T[]> {
  success: true;
  data: T[];
  errors: null;
  meta: ApiResponseMeta & {
    pagination: ApiPaginationMeta;
  };
}

export interface LegacyPaginatedApiResponse<T> {
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
