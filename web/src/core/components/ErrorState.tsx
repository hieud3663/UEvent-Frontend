// File: src/core/components/ErrorState.tsx

import { AlertCircle } from 'lucide-react';
import { Button } from '@/core/components/Button';
import { cn } from '@/core/lib/utils';

interface ErrorStateProps {
  title?: string;
  message?: string;
  retryLabel?: string;
  onRetry?: () => void;
  className?: string;
}

export function ErrorState({
  title = 'Unable to load data',
  message = 'Please try again or contact support if the issue continues.',
  retryLabel = 'Retry',
  onRetry,
  className,
}: ErrorStateProps) {
  return (
    <div
      className={cn(
        'flex flex-col items-center justify-center rounded-2xl border border-red-100 bg-red-50 px-6 py-12 text-center',
        className
      )}
    >
      <div className="mb-4 rounded-full bg-red-100 p-3 text-red-600">
        <AlertCircle className="h-6 w-6" aria-hidden="true" />
      </div>
      <h3 className="text-base font-semibold text-red-950">{title}</h3>
      <p className="mt-2 max-w-md text-sm text-red-700">{message}</p>
      {onRetry ? (
        <Button className="mt-5" variant="danger" onClick={onRetry}>
          {retryLabel}
        </Button>
      ) : null}
    </div>
  );
}
