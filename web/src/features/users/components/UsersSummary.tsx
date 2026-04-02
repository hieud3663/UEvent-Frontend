import { Users } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle } from '@/core/components';

interface UsersSummaryProps {
  totalUsers: number;
  activeOrganizers: number;
}

export function UsersSummary({ totalUsers, activeOrganizers }: UsersSummaryProps) {
  return (
    <Card className="glass-card rounded-3xl border-white/40">
      <CardHeader className="flex flex-row items-center justify-between pb-2">
        <CardTitle className="text-sm font-bold uppercase tracking-wider text-slate-500">
          Users Overview
        </CardTitle>
        <Users className="h-4 w-4 text-amber-500" />
      </CardHeader>
      <CardContent className="space-y-1">
        <p className="text-3xl font-black text-slate-900">{totalUsers.toLocaleString()}</p>
        <p className="text-xs text-slate-500">{activeOrganizers} active organizers</p>
      </CardContent>
    </Card>
  );
}
