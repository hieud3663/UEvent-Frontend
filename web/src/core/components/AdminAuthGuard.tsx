// File: src/core/components/AdminAuthGuard.tsx
'use client';

import { useEffect, useState } from 'react';
import { usePathname, useRouter } from 'next/navigation';
import { AppLoadingScreen, ErrorState } from '@/core/components';
import { getCurrentAdmin, hasAdminAccessToken } from '@/features/auth/services/auth.service';

interface AdminAuthGuardProps {
  children: React.ReactNode;
}

export function AdminAuthGuard({ children }: AdminAuthGuardProps) {
  const pathname = usePathname();
  const router = useRouter();
  const [status, setStatus] = useState<'checking' | 'authenticated' | 'error'>('checking');

  useEffect(() => {
    let isMounted = true;

    async function verifySession() {
      if (!hasAdminAccessToken()) {
        router.replace(`/login?next=${encodeURIComponent(pathname)}`);
        return;
      }

      try {
        await getCurrentAdmin();
        if (isMounted) {
          setStatus('authenticated');
        }
      } catch {
        if (isMounted) {
          setStatus('error');
        }
      }
    }

    void verifySession();

    return () => {
      isMounted = false;
    };
  }, [pathname, router]);

  if (status === 'authenticated') {
    return children;
  }

  if (status === 'error') {
    return (
      <main className="min-h-screen bg-slate-50 p-6">
        <ErrorState
          title="Phiên đăng nhập không hợp lệ"
          message="Vui lòng đăng nhập lại để tiếp tục quản trị hệ thống."
          retryLabel="Đăng nhập lại"
          onRetry={() => router.replace(`/login?next=${encodeURIComponent(pathname)}`)}
        />
      </main>
    );
  }

  return (
    <AppLoadingScreen
      title="Đang xác thực phiên quản trị"
      description="Vui lòng chờ trong giây lát"
      className="bg-slate-50"
    />
  );
}
