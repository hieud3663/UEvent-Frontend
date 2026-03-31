// File: src/core/components/Input.tsx
import { forwardRef } from 'react';
import { cn } from '@/core/lib/utils';

export interface InputProps extends React.InputHTMLAttributes<HTMLInputElement> {
  label?: string;
  error?: string;
  hint?: string;
  leftIcon?: React.ReactNode;
  rightIcon?: React.ReactNode;
}

export const Input = forwardRef<HTMLInputElement, InputProps>(
  ({ className, label, error, hint, leftIcon, rightIcon, id, ...props }, ref) => {
    const inputId = id || label?.toLowerCase().replace(/\s+/g, '-');

    return (
      <div className="space-y-2">
        {label && (
          <label
            htmlFor={inputId}
            className="text-xs font-bold uppercase tracking-widest text-on-surface-variant ml-1"
          >
            {label}
          </label>
        )}
        <div className="relative">
          {leftIcon && (
            <span className="absolute left-4 top-1/2 -translate-y-1/2 text-outline">
              {leftIcon}
            </span>
          )}
          <input
            ref={ref}
            id={inputId}
            className={cn(
              'w-full bg-surface-container-low/50 border-none rounded-2xl',
              'py-4 px-4 text-on-surface font-medium',
              'placeholder:text-outline-variant',
              'focus:ring-2 focus:ring-primary-container focus:outline-none',
              'transition-all duration-200',
              leftIcon && 'pl-12',
              rightIcon && 'pr-12',
              error && 'ring-2 ring-error',
              className
            )}
            {...props}
          />
          {rightIcon && (
            <span className="absolute right-4 top-1/2 -translate-y-1/2 text-outline">
              {rightIcon}
            </span>
          )}
        </div>
        {error && (
          <p className="text-xs text-error ml-1">{error}</p>
        )}
        {hint && !error && (
          <p className="text-xs text-outline ml-1">{hint}</p>
        )}
      </div>
    );
  }
);

Input.displayName = 'Input';
