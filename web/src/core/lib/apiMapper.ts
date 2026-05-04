// File: src/core/lib/apiMapper.ts

import type { ApiPaginationMeta, LegacyPaginatedApiResponse, PaginatedApiResponse } from '@/core/types/api';

export function mapPaginatedResults<TApi, TModel>(
  response: LegacyPaginatedApiResponse<TApi> | PaginatedApiResponse<TApi>,
  mapper: (item: TApi) => TModel
) {
  if ('success' in response) {
    const pagination: ApiPaginationMeta = response.meta.pagination;
    return {
      total: pagination.count,
      next: pagination.next,
      previous: pagination.previous,
      items: response.data.map(mapper),
    };
  }

  return {
    total: response.count,
    next: response.next,
    previous: response.previous,
    items: response.results.map(mapper),
  };
}

export function requireString(value: unknown, fallback = ''): string {
  return typeof value === 'string' ? value : fallback;
}

export function requireBoolean(value: unknown, fallback = false): boolean {
  return typeof value === 'boolean' ? value : fallback;
}
