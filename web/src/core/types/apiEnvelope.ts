// File: src/core/types/apiEnvelope.ts

export interface ApiResponseMeta {
  request_id?: string | null;
  pagination?: ApiPaginationMeta;
  [key: string]: unknown;
}

export interface ApiPaginationMeta {
  count: number;
  next: string | null;
  previous: string | null;
  page: number;
  page_size: number;
  total_pages: number;
}

export interface ApiEnvelope<TData = unknown, TErrors = unknown> {
  success: boolean;
  code: string;
  message: string;
  data: TData;
  errors: TErrors | null;
  meta: ApiResponseMeta;
}
