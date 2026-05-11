// File: src/app/(admin)/layout.tsx
import { AdminAuthGuard, AdminLayout } from '@/core/components';

export default function AdminLayoutWrapper({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <AdminAuthGuard>
      <AdminLayout>{children}</AdminLayout>
    </AdminAuthGuard>
  );
}
