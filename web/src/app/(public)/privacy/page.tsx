// File: src/app/(public)/privacy/page.tsx
import type { Metadata } from 'next';
import { LegalDocumentPage } from '../LegalDocumentPage';
import { PublicShell } from '../PublicShell';

export const metadata: Metadata = {
  title: 'Chính sách quyền riêng tư | UEvent',
  description: 'Chính sách thu thập, sử dụng và bảo vệ dữ liệu cá nhân của UEvent.',
};

export default function PrivacyPage() {
  return (
    <PublicShell>
      <LegalDocumentPage documentType="privacy_policy" eyebrow="Chính sách" />
    </PublicShell>
  );
}
