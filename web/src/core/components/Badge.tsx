// File: src/core/components/Badge.tsx
import { cn } from '@/core/lib/utils';

export interface BadgeProps {
  variant?: 'default' | 'success' | 'warning' | 'error' | 'info' | 'neutral';
  size?: 'sm' | 'md' | 'lg';
  children: React.ReactNode;
  className?: string;
}

export function Badge({
  variant = 'default',
  size = 'md',
  children,
  className,
}: BadgeProps) {
  const variants = {
    default: 'bg-primary-100 text-primary-700',
    success: 'bg-success-light text-success-dark',
    warning: 'bg-warning-light text-warning-dark',
    error: 'bg-error-light text-error-dark',
    info: 'bg-info-light text-info-dark',
    neutral: 'bg-slate-100 text-slate-600',
  };

  const sizes = {
    sm: 'px-1.5 py-0.5 text-[10px]',
    md: 'px-2 py-1 text-xs',
    lg: 'px-3 py-1.5 text-sm',
  };

  return (
    <span
      className={cn(
        'inline-flex items-center font-bold rounded-full uppercase tracking-wide',
        variants[variant],
        sizes[size],
        className
      )}
    >
      {children}
    </span>
  );
}
