import { ArrowRight, CheckCircle } from 'lucide-react';
import { cn } from '@/core/lib/utils';
import type { QueueActivityItem } from '../types';

interface QueueActivityListProps {
  items: QueueActivityItem[];
}

export function QueueActivityList({ items }: QueueActivityListProps) {
  return (
    <div className="space-y-3">
      {items.map((item) => (
        <div
          key={item.id}
          className={cn(
            'group p-4 rounded-2xl transition-all cursor-pointer border',
            item.status === 'pending'
              ? 'bg-white/50 hover:bg-white border-transparent hover:border-amber-100'
              : 'bg-slate-50/50 border-slate-100/50'
          )}
        >
          <div className="flex gap-4 items-center">
            <div className="w-10 h-10 rounded-full bg-surface-container overflow-hidden flex-shrink-0 flex items-center justify-center">
              {item.status === 'completed' ? (
                <CheckCircle className="text-emerald-600 w-5 h-5" />
              ) : (
                <div className="w-full h-full bg-gradient-to-br from-amber-200 to-amber-400" />
              )}
            </div>
            <div className="flex-1 min-w-0">
              <p className="text-sm font-bold truncate">{item.title}</p>
              <p className="text-xs text-slate-500">{item.subtitle}</p>
            </div>
            {item.status === 'pending' && (
              <ArrowRight className="text-amber-500 w-5 h-5 opacity-0 group-hover:opacity-100 transition-opacity" />
            )}
          </div>
        </div>
      ))}
    </div>
  );
}
