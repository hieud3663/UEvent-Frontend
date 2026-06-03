'use client';

import { useEffect, useRef, useState } from 'react';
import { usePathname } from 'next/navigation';
import { Loader2 } from 'lucide-react';
import { cn } from '@/core/lib/utils';

interface PublicPageTransitionProps {
  children: React.ReactNode;
  className?: string;
}

export function PublicPageTransition({ children, className }: PublicPageTransitionProps) {
  const pathname = usePathname();
  const [isNavigating, setIsNavigating] = useState(false);
  const timeoutRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  useEffect(() => {
    if (timeoutRef.current) {
      clearTimeout(timeoutRef.current);
    }

    timeoutRef.current = setTimeout(() => {
      setIsNavigating(false);
      timeoutRef.current = null;
    }, 120);
  }, [pathname]);

  useEffect(() => {
    return () => {
      if (timeoutRef.current) {
        clearTimeout(timeoutRef.current);
      }
    };
  }, []);

  const handleClickCapture = (event: React.MouseEvent<HTMLDivElement>) => {
    if (event.defaultPrevented || event.button !== 0 || event.metaKey || event.ctrlKey || event.shiftKey || event.altKey) {
      return;
    }

    const anchor = (event.target as HTMLElement).closest('a');
    if (!anchor) return;

    const href = anchor.getAttribute('href');
    const target = anchor.getAttribute('target');
    if (!href || target === '_blank' || href.startsWith('#') || href.startsWith('mailto:') || href.startsWith('tel:')) {
      return;
    }

    const nextUrl = new URL(href, window.location.href);
    if (nextUrl.origin !== window.location.origin) return;

    const isSamePage = nextUrl.pathname === window.location.pathname && nextUrl.search === window.location.search;
    if (isSamePage) return;

    setIsNavigating(true);
    if (timeoutRef.current) {
      clearTimeout(timeoutRef.current);
    }
    timeoutRef.current = setTimeout(() => setIsNavigating(false), 1800);
  };

  return (
    <div className={className} onClickCapture={handleClickCapture}>
      <div
        className={cn(
          'pointer-events-none fixed inset-x-0 top-0 z-[120] h-1 origin-left bg-primary-container shadow-lg shadow-primary-container/30 transition-transform duration-300',
          isNavigating ? 'scale-x-100' : 'scale-x-0'
        )}
      />
      {isNavigating ? (
        <div className="pointer-events-none fixed inset-x-0 top-4 z-[119] flex justify-center px-4">
          <div className="inline-flex items-center gap-2 rounded-full border border-white/70 bg-white/90 px-4 py-2 text-xs font-bold text-on-surface shadow-xl shadow-black/10 backdrop-blur-xl">
            <Loader2 className="h-4 w-4 animate-spin text-primary-700" />
            Đang chuyển trang
          </div>
        </div>
      ) : null}
      {children}
    </div>
  );
}
