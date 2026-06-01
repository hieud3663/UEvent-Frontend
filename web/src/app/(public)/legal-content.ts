// File: src/app/(public)/legal-content.ts
import { apiRequest } from '@/core/lib/api';

type LegalDocumentType = 'privacy_policy' | 'terms_of_service';

export interface PublicLegalDocument {
  documentType: LegalDocumentType;
  title: string;
  version: string;
  summary: string;
  body: string;
  updatedAt: string;
  source: 'api';
}

interface LegalDocumentDto {
  document_type?: string;
  title?: string;
  version?: string;
  summary?: string;
  body?: string;
  locale?: string;
  published_at?: string | null;
  updated_at?: string | null;
}

const LEGAL_DOCUMENT_LOCALE = 'vi';

export async function getPublicLegalDocument(documentType: LegalDocumentType): Promise<PublicLegalDocument | null> {
  try {
    const document = await apiRequest<LegalDocumentDto>(`/support/legal-documents/${documentType}/?locale=${LEGAL_DOCUMENT_LOCALE}`, {
      auth: false,
      cache: 'no-store',
    });

    if (!document.body) return null;
    return {
      documentType,
      title: document.title || getDocumentFallbackTitle(documentType),
      version: document.version || '',
      summary: document.summary || '',
      body: document.body,
      updatedAt: document.published_at || document.updated_at || '',
      source: 'api',
    };
  } catch {
    return null;
  }
}

export function splitLegalBody(body: string): string[] {
  return body
    .split(/\n{2,}/)
    .map((paragraph) => paragraph.trim())
    .filter(Boolean);
}

export function formatLegalDate(value: string): string {
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) {
    return value;
  }

  return new Intl.DateTimeFormat('vi-VN', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
  }).format(date);
}

function getDocumentFallbackTitle(documentType: LegalDocumentType): string {
  return documentType === 'privacy_policy' ? 'Chính sách quyền riêng tư' : 'Điều khoản dịch vụ';
}
