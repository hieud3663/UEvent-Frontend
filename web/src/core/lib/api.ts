// File: src/core/lib/api.ts

import type { ApiErrorResponse, ApiRequestOptions, ExportFileResult } from '@/core/types/api';

const DEFAULT_API_BASE_URL = 'http://localhost:8000/api/v1';
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

  return response.json() as Promise<T>;
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

  const data = (await response.json()) as { access?: string; refresh?: string };
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
    code: `http_${response.status}`,
    message: response.statusText || 'Request failed.',
    details: null,
    request_id: response.headers.get('X-Request-ID'),
  };

  try {
    const data = (await response.json()) as Partial<ApiErrorResponse>;
    const errorResponse: ApiErrorResponse = {
      code: data.code || fallback.code,
      message: data.message || fallback.message,
      details: data.details ?? fallback.details,
      request_id: data.request_id ?? fallback.request_id,
    };
    return new ApiClientError(errorResponse.message, response.status, errorResponse);
  } catch {
    return new ApiClientError(fallback.message, response.status, fallback);
  }
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
