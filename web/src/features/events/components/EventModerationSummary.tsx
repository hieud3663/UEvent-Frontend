import { ShieldAlert } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle } from '@/core/components';

interface EventModerationSummaryProps {
  urgentReports: number;
  pendingApproval: number;
}

export function EventModerationSummary({ urgentReports, pendingApproval }: EventModerationSummaryProps) {
  return (
    <Card className="glass-card rounded-3xl border-white/40">
      <CardHeader className="flex flex-row items-center justify-between pb-2">
        <CardTitle className="text-sm font-bold uppercase tracking-wider text-slate-500">
          Kiểm duyệt sự kiện
        </CardTitle>
        <ShieldAlert className="h-4 w-4 text-red-500" />
      </CardHeader>
      <CardContent className="space-y-1">
        <p className="text-3xl font-black text-slate-900">{urgentReports}</p>
        <p className="text-xs text-slate-500">Báo cáo khẩn cấp, {pendingApproval} sự kiện chờ duyệt</p>
      </CardContent>
    </Card>
  );
}
