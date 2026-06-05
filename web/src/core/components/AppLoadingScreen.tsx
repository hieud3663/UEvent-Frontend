import { Loader2 } from 'lucide-react';
import { cn } from '@/core/lib/utils';

interface AppLoadingScreenProps {
  title?: string;
  description?: string;
  className?: string;
}

export function AppLoadingScreen({
  title = 'Đang tải dữ liệu',
  description = 'Vui lòng chờ trong giây lát',
  className,
}: AppLoadingScreenProps) {
  return (
    <main
      className={cn(
        'grid min-h-screen place-items-center bg-ethereal px-5 text-on-surface',
        className
      )}
      aria-busy="true"
      aria-live="polite"
    >
      <div className="glass-card flex items-center gap-3 rounded-[28px] px-5 py-4">
        <Loader2 className="h-5 w-5 animate-spin text-primary-700" />
        <div className="space-y-0.5">
          <span className="block text-sm font-bold">{title}</span>
          <span className="block text-xs text-slate-500">{description}</span>
        </div>
      </div>
    </main>
  );
}
