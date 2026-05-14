import { FolderOpen } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle } from '@/core/components';

interface CategorySummaryProps {
  totalCategories: number;
  totalEvents: number;
}

export function CategorySummary({ totalCategories, totalEvents }: CategorySummaryProps) {
  return (
    <Card className="glass-card rounded-3xl border-white/40">
      <CardHeader className="flex flex-row items-center justify-between pb-2">
        <CardTitle className="text-sm font-bold uppercase tracking-wider text-slate-500">
          Danh mục
        </CardTitle>
        <FolderOpen className="h-4 w-4 text-amber-500" />
      </CardHeader>
      <CardContent className="space-y-1">
        <p className="text-3xl font-black text-slate-900">{totalCategories}</p>
        <p className="text-xs text-slate-500">{totalEvents} sự kiện đã gắn</p>
      </CardContent>
    </Card>
  );
}
