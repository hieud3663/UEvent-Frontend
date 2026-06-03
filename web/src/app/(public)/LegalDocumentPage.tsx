// File: src/app/(public)/LegalDocumentPage.tsx
import { FileText, ShieldCheck } from 'lucide-react';
import { formatLegalDate, getPublicLegalDocument, splitLegalBody } from './legal-content';

interface LegalDocumentPageProps {
  documentType: 'privacy_policy' | 'terms_of_service';
  eyebrow: string;
}

export async function LegalDocumentPage({ documentType, eyebrow }: LegalDocumentPageProps) {
  const document = await getPublicLegalDocument(documentType);
  const paragraphs = document ? splitLegalBody(document.body) : [];

  return (
    <section>
      <div className="mx-auto max-w-4xl px-5 py-12 sm:px-8 sm:py-16">
        <div className="glass-card rounded-[32px] p-6 shadow-2xl shadow-black/5 sm:p-8">
          <div className="flex items-start gap-4">
            <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-2xl bg-primary-container text-on-primary-container shadow-lg shadow-primary-container/20">
              {documentType === 'privacy_policy' ? (
                <ShieldCheck className="h-5 w-5" />
              ) : (
                <FileText className="h-5 w-5" />
              )}
            </div>
            <div>
              <p className="text-xs font-black uppercase tracking-widest text-primary-700">{eyebrow}</p>
              <h1 className="mt-2 text-3xl font-black tracking-tight text-on-surface sm:text-4xl">
                {document?.title ?? (documentType === 'privacy_policy' ? 'Chính sách quyền riêng tư' : 'Điều khoản dịch vụ')}
              </h1>
              <p className="mt-3 text-base leading-7 text-on-surface-variant">
                {document?.summary ||
                  'Tài liệu này được đồng bộ từ API công khai giống ứng dụng di động. Hiện chưa có bản công bố để hiển thị.'}
              </p>
            </div>
          </div>

          {document ? (
            <dl className="mt-8 grid gap-3 border-y border-black/5 py-5 text-sm sm:grid-cols-2">
              <div className="rounded-2xl bg-white/55 p-4">
                <dt className="font-bold text-on-surface-variant">Phiên bản</dt>
                <dd className="mt-1 font-black text-on-surface">{document.version || 'Chưa công bố'}</dd>
              </div>
              <div className="rounded-2xl bg-white/55 p-4">
                <dt className="font-bold text-on-surface-variant">Cập nhật</dt>
                <dd className="mt-1 font-black text-on-surface">
                  {document.updatedAt ? formatLegalDate(document.updatedAt) : 'Chưa công bố'}
                </dd>
              </div>
              
            </dl>
          ) : null}

          {paragraphs.length > 0 ? (
            <div className="mt-8 space-y-5 text-base leading-8 text-on-surface">
              {paragraphs.map((paragraph) => (
                <p key={paragraph}>{paragraph}</p>
              ))}
            </div>
          ) : (
            <div className="mt-8 rounded-2xl border border-warning-light bg-warning-light/60 p-4 text-sm font-semibold text-warning-dark">
              Chưa lấy được tài liệu từ API `/support/legal-documents/{documentType}/?locale=vi`.
            </div>
          )}
        </div>
      </div>
    </section>
  );
}
