// File: src/app/(admin)/layout.tsx
import { AdminLayout } from '@/core/components';

export default function AdminLayoutWrapper({
  children,
}: {
  children: React.ReactNode;
}) {
  return <AdminLayout>{children}</AdminLayout>;
}
