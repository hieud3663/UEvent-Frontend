// File: src/features/dashboard/components/StatsCard.tsx
import { LucideIcon } from 'lucide-react';
import { cn } from '@/core/lib/utils';

interface StatsCardProps {
  title: string;
  value: string | number;
  change?: {
    value: number;
    trend: 'up' | 'down' | 'neutral';
    label?: string;
  };
  icon: LucideIcon;
  iconColor?: string;
  iconBgColor?: string;
  className?: string;
}

export function StatsCard({
  title,
  value,
  change,
  icon: Icon,
  iconColor = 'text-amber-500',
  iconBgColor = 'bg-amber-100',
  className,
}: StatsCardProps) {
  return (
    <div
      className={cn(
        'glass-card p-6 rounded-[24px] shadow-sm',
        'hover:translate-y-[-4px] transition-transform duration-300',
        className
      )}
    >
      <div className="flex items-center justify-between mb-4">
        <div
          className={cn(
            'w-10 h-10 rounded-xl flex items-center justify-center',
            iconBgColor
          )}
        >
          <Icon className={cn('w-5 h-5', iconColor)} />
        </div>
        {change && (
          <span
            className={cn(
              'text-[10px] font-black px-2 py-1 rounded-full',
              change.trend === 'up' && 'text-emerald-600 bg-emerald-50',
              change.trend === 'down' && 'text-red-600 bg-red-50',
              change.trend === 'neutral' && 'text-amber-600 bg-amber-50'
            )}
          >
            {change.label
              ? change.label
              : `${change.trend === 'up' ? '+' : change.trend === 'down' ? '-' : ''}${change.value}%`}
          </span>
        )}
      </div>
      <p className="text-xs font-bold uppercase tracking-widest text-slate-400 mb-1">
        {title}
      </p>
      <h2 className="text-3xl font-black text-on-surface">{value}</h2>
    </div>
  );
}
