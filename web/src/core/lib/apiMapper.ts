// File: src/core/lib/apiMapper.ts

export function mapPaginatedResults<TApi, TModel>(
  response: { count: number; next: string | null; previous: string | null; results: TApi[] },
  mapper: (item: TApi) => TModel
) {
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
