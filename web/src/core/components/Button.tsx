// File: src/core/components/Button.tsx
import { forwardRef } from 'react';
import { cn } from '@/core/lib/utils';
import { Loader2 } from 'lucide-react';

export interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'outline' | 'ghost' | 'danger';
  size?: 'sm' | 'md' | 'lg';
  isLoading?: boolean;
  leftIcon?: React.ReactNode;
  rightIcon?: React.ReactNode;
}

export const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  (
    {
      className,
      variant = 'primary',
      size = 'md',
      isLoading = false,
      leftIcon,
      rightIcon,
      disabled,
      children,
      ...props
    },
    ref
  ) => {
    const baseStyles = cn(
      'inline-flex items-center justify-center gap-2',
      'font-semibold rounded-xl',
      'transition-all duration-200',
      'focus:outline-none focus:ring-2 focus:ring-offset-2',
      'disabled:opacity-50 disabled:cursor-not-allowed'
    );

    const variants = {
      primary: cn(
        'bg-primary-container text-on-primary-container',
        'hover:shadow-lg hover:shadow-primary-container/30',
        'hover:scale-[1.02] active:scale-[0.98]',
        'focus:ring-primary-400'
      ),
      secondary: cn(
        'bg-slate-100 text-slate-800',
        'hover:bg-slate-200',
        'focus:ring-slate-400'
      ),
      outline: cn(
        'border-2 border-slate-200 bg-transparent text-slate-700',
        'hover:bg-slate-50 hover:border-slate-300',
        'focus:ring-slate-400'
      ),
      ghost: cn(
        'bg-transparent text-slate-600',
        'hover:bg-slate-100 hover:text-slate-800',
        'focus:ring-slate-400'
      ),
      danger: cn(
        'bg-error text-white',
        'hover:bg-error-dark',
        'focus:ring-error'
      ),
    };

    const sizes = {
      sm: 'h-8 px-3 text-xs',
      md: 'h-10 px-4 text-sm',
      lg: 'h-12 px-6 text-base',
    };

    return (
      <button
        ref={ref}
        className={cn(baseStyles, variants[variant], sizes[size], className)}
        disabled={disabled || isLoading}
        {...props}
      >
        {isLoading ? (
          <Loader2 className="w-4 h-4 animate-spin" />
        ) : (
          leftIcon
        )}
        {children}
        {!isLoading && rightIcon}
      </button>
    );
  }
);

Button.displayName = 'Button';
