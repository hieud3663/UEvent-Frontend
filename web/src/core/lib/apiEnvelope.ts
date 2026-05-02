// File: src/core/lib/apiEnvelope.ts

import type { ApiEnvelope } from '@/core/types/apiEnvelope';

export function isApiEnvelope(value: unknown): value is ApiEnvelope {
  return (
    typeof value === 'object' &&
    value !== null &&
    'success' in value &&
    'code' in value &&
    'message' in value &&
    'data' in value &&
    'errors' in value &&
    'meta' in value
  );
}

export function unwrapApiEnvelope<T>(value: unknown): T {
  if (isApiEnvelope(value)) {
    return value.data as T;
  }

  return value as T;
}
