// File: src/app/(public)/terms/page.tsx
import type { Metadata } from 'next';
import { LegalDocumentPage } from '../LegalDocumentPage';
import { PublicShell } from '../PublicShell';

export const metadata: Metadata = {
  title: 'Điều khoản dịch vụ | UEvent',
  description: 'Điều khoản sử dụng website và ứng dụng UEvent.',
};

export default function TermsPage() {
  return (
    <PublicShell>
      <LegalDocumentPage documentType="terms_of_service" eyebrow="Điều khoản" />
    </PublicShell>
  );
}
