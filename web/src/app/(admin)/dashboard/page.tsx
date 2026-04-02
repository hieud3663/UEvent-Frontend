// File: src/app/(admin)/dashboard/page.tsx
'use client';

import { useState } from 'react';
import { Users, Ticket, CalendarCheck, Banknote, Plus, ArrowRight, CheckCircle } from 'lucide-react';
import Link from 'next/link';
import { StatsCard } from '@/features/dashboard/components';
import { useDashboardOverview } from '@/features/dashboard/hooks/useDashboardOverview';
import { cn } from '@/core/lib/utils';
import { runActionWithToast } from '@/core/lib/runActionWithToast';

export default function DashboardPage() {
  const [period, setPeriod] = useState<'monthly' | 'yearly'>('monthly');
  const { stats, queue, growthSeries, isLoading, error } = useDashboardOverview();

  const statIconMap = {
    users: Users,
    registrations: Ticket,
    events: CalendarCheck,
    revenue: Banknote,
  } as const;

  const queueGradientMap: Record<string, string> = {
    'queue-1': 'from-amber-200 to-amber-400',
    'queue-2': 'from-amber-300 to-amber-500',
  };

  const handleOpenQueue = async (queueId: string, queueLabel: string) => {
    await runActionWithToast(async () => Promise.resolve(queueId), {
      loading: `Opening ${queueLabel}...`,
      success: `${queueLabel} is ready.`,
      error: `Failed to open ${queueLabel}.`,
    });
  };

  if (isLoading) {
    return <div className="p-6 text-sm text-slate-500">Loading dashboard overview...</div>;
  }

  if (error) {
    return <div className="p-6 text-sm text-red-500">{error}</div>;
  }

  const pendingQueueItems = queue.filter((item) => item.status === 'pending').slice(0, 2);
  const latestCompletedItem = queue.find((item) => item.status === 'completed');

  return (
    <div className="space-y-8">
      {/* Page Header */}
      <div>
        <h1 className="text-2xl font-bold tracking-tight text-on-surface">
          Dashboard Overview
        </h1>
        <p className="text-on-surface-variant text-sm mt-1">
          Real-time performance metrics and global event monitoring.
        </p>
      </div>

      {/* Stats Grid */}
      <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-4">
        {stats.map((stat) => {
          const Icon = statIconMap[stat.id as keyof typeof statIconMap] ?? Users;
          const trendValue = Number.parseFloat(stat.trendLabel.replace(/[+%]/g, ''));
          const isNumericTrend = Number.isFinite(trendValue);

          return (
            <StatsCard
              key={stat.id}
              title={stat.title}
              value={stat.value}
              change={
                isNumericTrend
                  ? { value: trendValue, trend: trendValue > 0 ? 'up' : trendValue < 0 ? 'down' : 'neutral' }
                  : { value: 0, trend: 'neutral', label: stat.trendLabel }
              }
              icon={Icon}
              iconColor="text-amber-500"
              iconBgColor="bg-amber-100"
            />
          );
        })}
      </div>

      {/* Charts & Activities Section */}
      <div className="grid gap-8 lg:grid-cols-3">
        {/* Event Growth Chart */}
        <div className="lg:col-span-2 glass-card rounded-[32px] p-8">
          <div className="flex items-center justify-between mb-8">
            <div>
              <h3 className="text-lg font-bold text-on-surface">Event Growth Trends</h3>
              <p className="text-sm text-slate-500">Monthly overview of new event creation</p>
            </div>
            <div className="flex items-center gap-2">
              <button
                type="button"
                onClick={() => setPeriod('monthly')}
                className={cn(
                  'px-4 py-1.5 text-xs font-bold rounded-full border border-black/5',
                  period === 'monthly' ? 'bg-white shadow-sm text-slate-900' : 'text-slate-500 bg-transparent'
                )}
              >
                Monthly
              </button>
              <button
                type="button"
                onClick={() => setPeriod('yearly')}
                className={cn(
                  'px-4 py-1.5 text-xs font-bold rounded-full border border-transparent',
                  period === 'yearly' ? 'bg-white shadow-sm text-slate-900 border-black/5' : 'text-slate-500 hover:text-slate-900'
                )}
              >
                Yearly
              </button>
            </div>
          </div>
          {/* Visual Chart Placeholder */}
          <div className="relative h-[300px] w-full mt-4 flex items-end gap-4 overflow-hidden">
            {/* Background Grid */}
            <div className="absolute inset-0 flex flex-col justify-between opacity-10 pointer-events-none">
              <div className="w-full h-[1px] bg-slate-400"></div>
              <div className="w-full h-[1px] bg-slate-400"></div>
              <div className="w-full h-[1px] bg-slate-400"></div>
              <div className="w-full h-[1px] bg-slate-400"></div>
              <div className="w-full h-[1px] bg-slate-400"></div>
            </div>
            {growthSeries.map((point) => {
              const value = period === 'monthly' ? point.monthlyValue : point.yearlyValue;

              return (
                <div
                  key={point.id}
                  className={cn(
                    'flex-1 rounded-t-xl',
                    point.highlight
                      ? 'bg-primary-container shadow-[0_0_20px_rgba(255,184,0,0.3)]'
                      : value >= 75
                        ? 'bg-amber-400'
                        : value >= 55
                          ? 'bg-amber-300'
                          : value >= 40
                            ? 'bg-amber-200'
                            : 'bg-amber-100'
                  )}
                  style={{ height: `${value}%` }}
                ></div>
              );
            })}
          </div>
          <div className="flex justify-between mt-4 text-[10px] font-bold text-slate-400 px-1 uppercase tracking-tighter">
            {growthSeries.map((point) => (
              <span key={`label-${point.id}`}>{point.month}</span>
            ))}
          </div>
        </div>

        {/* Queue Management */}
        <div className="glass-card rounded-[32px] overflow-hidden flex flex-col">
          <div className="p-6 border-b border-black/5 bg-white/40">
            <h3 className="text-lg font-bold text-on-surface">Queue Management</h3>
            <p className="text-sm text-slate-500">Pending reviews and actions</p>
          </div>
          <div className="flex-1 p-4 space-y-3">
            {pendingQueueItems.map((item) => (
              <button
                key={item.id}
                type="button"
                onClick={() => {
                  void handleOpenQueue(item.id, item.title);
                }}
                className="group w-full p-4 rounded-2xl bg-white/50 hover:bg-white transition-all cursor-pointer border border-transparent hover:border-amber-100 text-left"
              >
                <div className="flex gap-4 items-center">
                  <div className="w-10 h-10 rounded-full bg-surface-container overflow-hidden flex-shrink-0">
                    <div
                      className={cn(
                        'w-full h-full bg-gradient-to-br',
                        queueGradientMap[item.id] ?? 'from-amber-200 to-amber-400'
                      )}
                    />
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-bold truncate">{item.title}</p>
                    <p className="text-xs text-slate-500">{item.subtitle}</p>
                  </div>
                  <ArrowRight className="text-amber-500 w-5 h-5 opacity-0 group-hover:opacity-100 transition-opacity" />
                </div>
              </button>
            ))}
            {latestCompletedItem && (
              <div className="p-4 rounded-2xl bg-slate-50/50">
                <div className="flex gap-4 items-center">
                  <div className="w-10 h-10 rounded-full bg-emerald-100 flex items-center justify-center flex-shrink-0">
                    <CheckCircle className="text-emerald-600 w-5 h-5" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-bold">{latestCompletedItem.title}</p>
                    <p className="text-xs text-slate-500">{latestCompletedItem.subtitle}</p>
                  </div>
                  <span className="text-[10px] text-slate-400 font-bold whitespace-nowrap">2H AGO</span>
                </div>
              </div>
            )}
          </div>
          <div className="p-4 mt-auto">
            <Link 
              href="/events"
              className="w-full py-3 bg-amber-500 text-white text-xs font-black uppercase tracking-widest rounded-xl hover:opacity-90 transition-opacity flex items-center justify-center"
            >
              View All Activity
            </Link>
          </div>
        </div>
      </div>

      {/* Floating Action Button */}
      <div className="fixed bottom-8 right-8 z-50">
        <Link 
          href="/notifications/create"
          className="flex items-center gap-2 bg-on-surface text-white px-6 py-4 rounded-full shadow-2xl hover:scale-[1.05] transition-transform duration-300"
        >
          <Plus className="w-5 h-5" />
          <span className="text-sm font-bold">New Notification</span>
        </Link>
      </div>
    </div>
  );
}
