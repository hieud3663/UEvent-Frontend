// File: src/core/lib/api.ts

import { isApiEnvelope, unwrapApiEnvelope } from '@/core/lib/apiEnvelope';
import type { ApiEnvelope } from '@/core/types/apiEnvelope';
import type { ApiErrorResponse, ApiRequestOptions, ExportFileResult } from '@/core/types/api';

const DEFAULT_API_BASE_URL = 'http://localhost:8000/api/v1';
// const DEFAULT_API_BASE_URL = 'https://uevent-api.u-code.dev/api/v1';
const ACCESS_TOKEN_KEY = 'uevent_admin_access_token';
const REFRESH_TOKEN_KEY = 'uevent_admin_refresh_token';

export class ApiClientError extends Error {
  constructor(
    message: string,
    public readonly status: number,
    public readonly response?: ApiErrorResponse
  ) {
    super(message);
    this.name = 'ApiClientError';
  }
}

export type ApiFieldErrors = Record<string, string[]>;

export function getApiBaseUrl(): string {
  return (process.env.NEXT_PUBLIC_API_BASE_URL || DEFAULT_API_BASE_URL).replace(/\/$/, '');
}

export const adminTokenStorage = {
  getAccessToken(): string | null {
    if (typeof window === 'undefined') return null;
    return window.localStorage.getItem(ACCESS_TOKEN_KEY);
  },
  getRefreshToken(): string | null {
    if (typeof window === 'undefined') return null;
    return window.localStorage.getItem(REFRESH_TOKEN_KEY);
  },
  setTokens(tokens: { access: string; refresh?: string }): void {
    if (typeof window === 'undefined') return;
    window.localStorage.setItem(ACCESS_TOKEN_KEY, tokens.access);
    if (tokens.refresh) {
      window.localStorage.setItem(REFRESH_TOKEN_KEY, tokens.refresh);
    }
  },
  clearTokens(): void {
    if (typeof window === 'undefined') return;
    window.localStorage.removeItem(ACCESS_TOKEN_KEY);
    window.localStorage.removeItem(REFRESH_TOKEN_KEY);
  },
};

export async function apiRequest<T>(path: string, options: ApiRequestOptions = {}): Promise<T> {
  const response = await fetchApi(path, options);

  if (response.status === 204) {
    return undefined as T;
  }

  const payload = await response.json();
  return unwrapApiEnvelope<T>(payload);
}

export async function apiRequestEnvelope<T>(
  path: string,
  options: ApiRequestOptions = {}
): Promise<ApiEnvelope<T>> {
  const response = await fetchApi(path, options);
  const payload = await response.json();

  if (!isApiEnvelope(payload)) {
    throw new ApiClientError('Invalid API response envelope.', response.status);
  }

  return payload as ApiEnvelope<T>;
}

export async function apiExport(path: string, options: ApiRequestOptions = {}): Promise<ExportFileResult> {
  const response = await fetchApi(path, options);
  const blob = await response.blob();

  return {
    blob,
    filename: getFilenameFromDisposition(response.headers.get('Content-Disposition')),
  };
}

async function fetchApi(path: string, options: ApiRequestOptions, retry = true): Promise<Response> {
  const { body, auth = true, headers, ...requestOptions } = options;
  const requestHeaders = new Headers(headers);

  if (body !== undefined && !requestHeaders.has('Content-Type')) {
    requestHeaders.set('Content-Type', 'application/json');
  }

  if (auth) {
    const token = adminTokenStorage.getAccessToken();
    if (token) {
      requestHeaders.set('Authorization', `Bearer ${token}`);
    }
  }

  const response = await fetch(`${getApiBaseUrl()}${normalizePath(path)}`, {
    ...requestOptions,
    headers: requestHeaders,
    body: body === undefined ? undefined : JSON.stringify(body),
  });

  if (response.status === 401 && auth && retry && (await refreshAccessToken())) {
    return fetchApi(path, options, false);
  }

  if (!response.ok) {
    throw await buildApiError(response);
  }

  return response;
}

async function refreshAccessToken(): Promise<boolean> {
  const refresh = adminTokenStorage.getRefreshToken();
  if (!refresh) return false;

  const response = await fetch(`${getApiBaseUrl()}/admin/auth/refresh/`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ refresh }),
  });

  if (!response.ok) {
    adminTokenStorage.clearTokens();
    redirectToLogin();
    return false;
  }

  const payload = await response.json();
  const data = unwrapApiEnvelope<{ access?: string; refresh?: string }>(payload);
  if (!data.access) {
    adminTokenStorage.clearTokens();
    redirectToLogin();
    return false;
  }

  adminTokenStorage.setTokens({ access: data.access, refresh: data.refresh });
  return true;
}

async function buildApiError(response: Response): Promise<ApiClientError> {
  const fallback: ApiErrorResponse = {
    success: false,
    code: `http_${response.status}`,
    message: response.statusText || 'Request failed.',
    data: null,
    errors: null,
    meta: { request_id: response.headers.get('X-Request-ID') },
  };

  try {
    const data = await response.json();
    if (isApiEnvelope(data)) {
      const errorResponse: ApiErrorResponse = {
        success: false,
        code: data.code || fallback.code,
        message: data.message || fallback.message,
        data: null,
        errors: data.errors ?? fallback.errors,
        meta: data.meta || fallback.meta,
      };
      return new ApiClientError(formatApiErrorMessage(errorResponse), response.status, errorResponse);
    }

    const legacy = data as { code?: string; message?: string; details?: unknown; request_id?: string | null };
    const errorResponse: ApiErrorResponse = {
      success: false,
      code: legacy.code || fallback.code,
      message: legacy.message || fallback.message,
      data: null,
      errors: legacy.details ?? fallback.errors,
      meta: { request_id: legacy.request_id ?? fallback.meta.request_id },
    };
    return new ApiClientError(formatApiErrorMessage(errorResponse), response.status, errorResponse);
  } catch {
    return new ApiClientError(fallback.message, response.status, fallback);
  }
}

function formatApiErrorMessage(errorResponse: ApiErrorResponse): string {
  const detailMessages = flattenApiErrors(errorResponse.errors);

  if (detailMessages.length === 0) {
    return errorResponse.message;
  }

  return [errorResponse.message, ...detailMessages].join('\n');
}

export function getApiFieldErrors(error: unknown): ApiFieldErrors {
  if (!(error instanceof ApiClientError)) return {};

  const errors = error.response?.errors;
  if (!errors || typeof errors !== 'object' || Array.isArray(errors)) return {};

  return Object.fromEntries(
    Object.entries(errors as Record<string, unknown>).flatMap(([field, value]) => {
      const messages = flattenPlainErrorMessages(value);
      return messages.length > 0 ? [[field, messages]] : [];
    })
  );
}

function flattenApiErrors(errors: unknown): string[] {
  if (!errors) return [];

  if (typeof errors === 'object' && !Array.isArray(errors)) {
    return Object.entries(errors as Record<string, unknown>).flatMap(([field, value]) => {
      const messages = flattenPlainErrorMessages(value);
      if (messages.length === 0) return [];

      const fieldLabel = formatErrorFieldLabel(field);
      return messages.map((message) => `${fieldLabel}: ${message}`);
    });
  }

  return flattenPlainErrorMessages(errors);
}

function flattenPlainErrorMessages(errors: unknown): string[] {
  if (!errors) return [];

  if (typeof errors === 'string') {
    return [errors];
  }

  if (Array.isArray(errors)) {
    return errors.flatMap((item) => flattenPlainErrorMessages(item));
  }

  if (typeof errors === 'object') {
    return Object.values(errors as Record<string, unknown>).flatMap((value) => flattenPlainErrorMessages(value));
  }

  return [String(errors)];
}

function formatErrorFieldLabel(field: string): string {
  const labels: Record<string, string> = {
    username: 'Tên đăng nhập',
    email: 'Email',
    password: 'Mật khẩu',
    full_name: 'Họ và tên',
    student_code: 'Mã sinh viên',
    phone_number: 'Số điện thoại',
    faculty: 'Khoa/đơn vị',
    class_name: 'Mã lớp',
    role_codes: 'Vai trò',
    non_field_errors: 'Lỗi',
    detail: 'Chi tiết',
  };

  return labels[field] ?? field.replaceAll('_', ' ');
}

function normalizePath(path: string): string {
  return path.startsWith('/') ? path : `/${path}`;
}

function redirectToLogin(): void {
  if (typeof window === 'undefined') return;
  window.location.assign('/login');
}

function getFilenameFromDisposition(disposition: string | null): string {
  if (!disposition) return 'export.csv';

  const match = disposition.match(/filename="?([^";]+)"?/i);
  return match?.[1] || 'export.csv';
}
