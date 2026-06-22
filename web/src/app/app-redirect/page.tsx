'use client';

import { Suspense, useEffect, useState } from 'react';
import { useSearchParams } from 'next/navigation';

type SearchParamsReader = {
  get(name: string): string | null;
};

function buildAppUri(searchParams: SearchParamsReader): string {
  const target = searchParams.get('target');
  const eventSlug = searchParams.get('event_slug')?.trim();

  if (target === 'event_user' && eventSlug) {
    return `uevent://events/share/${encodeURIComponent(eventSlug)}`;
  }

  const eventId = searchParams.get('event_id');
  const ticketId = searchParams.get('ticket_id');
  const params = new URLSearchParams();
  if (target) params.append('target', target);
  if (eventId) params.append('event_id', eventId);
  if (ticketId) params.append('ticket_id', ticketId);

  const query = params.toString();
  return `uevent://notifications/open${query ? `?${query}` : ''}`;
}

function RedirectLogic() {
  const searchParams = useSearchParams();
  const [countdown, setCountdown] = useState(3);

  useEffect(() => {
    // Redirect to app
    window.location.href = buildAppUri(searchParams);

    // Optional countdown logic for UI
    const timer = setInterval(() => {
      setCountdown((prev) => (prev > 0 ? prev - 1 : 0));
    }, 1000);

    return () => clearInterval(timer);
  }, [searchParams]);

  const handleManualRetry = (e: React.MouseEvent) => {
    e.preventDefault();
    window.location.href = buildAppUri(searchParams);
  };

  return (
    <div className="min-h-screen flex flex-col items-center justify-center bg-gray-50 px-4">
      <div className="max-w-md w-full bg-white p-8 rounded-2xl shadow-sm border border-gray-100 text-center">
        <div className="w-16 h-16 bg-blue-50 text-blue-600 rounded-full flex items-center justify-center mx-auto mb-6 text-2xl">
          🚀
        </div>
        <h1 className="text-2xl font-bold text-gray-900 mb-2">Đang mở ứng dụng UEvent...</h1>
        <p className="text-gray-500 mb-8">
          Vui lòng đợi trong giây lát. Hệ thống đang chuyển hướng bạn vào ứng dụng di động.
        </p>
        
        <div className="text-sm text-gray-400">
          Nếu ứng dụng không tự mở sau {countdown} giây, <br />
          <button 
            onClick={handleManualRetry}
            className="text-blue-600 hover:underline bg-transparent border-none cursor-pointer mt-1"
          >
            nhấn vào đây để thử lại
          </button>.
        </div>
      </div>
    </div>
  );
}

export default function AppRedirect() {
  return (
    <Suspense fallback={
      <div className="min-h-screen flex items-center justify-center bg-gray-50">
        <div className="animate-pulse text-gray-400">Đang khởi tạo...</div>
      </div>
    }>
      <RedirectLogic />
    </Suspense>
  );
}
