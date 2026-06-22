// File: src/app/(admin)/dashboard/page.tsx
'use client';

import { useState } from 'react';
import { Users, Ticket, CalendarCheck, Headphones, Plus, ArrowRight, CheckCircle, ShieldCheck } from 'lucide-react';
import Link from 'next/link';
import { ErrorState, AppLoadingScreen } from '@/core/components';
import { StatsCard } from '@/features/dashboard/components';
import { useDashboardOverview } from '@/features/dashboard/hooks/useDashboardOverview';
import { cn } from '@/core/lib/utils';

export default function DashboardPage() {
  const [period, setPeriod] = useState<'monthly' | 'yearly'>('monthly');
  const { stats, queue, growthSeries, auditSummary, isLoading, error } = useDashboardOverview();

  const statIconMap = {
    users: Users,
    registrations: Ticket,
    events: CalendarCheck,
    support: Headphones,
  } as const;

  const queueGradientMap: Record<string, string> = {
    'queue-1': 'from-amber-200 to-amber-400',
    'queue-2': 'from-amber-300 to-amber-500',
  };

  if (isLoading) {
    return <AppLoadingScreen title="Đang tải tổng quan hệ thống" description="Vui lòng chờ trong giây lát..." />;
  }

  if (error) {
    return (
      <ErrorState
        title="Không thể tải bảng điều khiển"
        message={error}
        retryLabel="Thử lại"
        onRetry={() => window.location.reload()}
      />
    );
  }

  const pendingQueueItems = queue.filter((item) => item.status === 'pending').slice(0, 2);
  const latestCompletedItem = queue.find((item) => item.status === 'completed');

  return (
    <div className="space-y-8">
      {/* Page Header */}
      <div>
        <h1 className="text-2xl font-bold tracking-tight text-on-surface">
          Tổng quan hệ thống
        </h1>
        <p className="text-on-surface-variant text-sm mt-1">
          Theo dõi chỉ số vận hành và hoạt động sự kiện theo thời gian thực.
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
        <div className="glass-card rounded-[28px] p-4 sm:p-6 lg:col-span-2 lg:rounded-[32px] lg:p-8">
          <div className="mb-8 flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
            <div>
              <h3 className="text-lg font-bold text-on-surface">Xu hướng tăng trưởng sự kiện</h3>
              <p className="text-sm text-slate-500">Tổng quan số sự kiện mới được tạo theo thời gian</p>
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
                Theo tháng
              </button>
              <button
                type="button"
                onClick={() => setPeriod('yearly')}
                className={cn(
                  'px-4 py-1.5 text-xs font-bold rounded-full border border-transparent',
                  period === 'yearly' ? 'bg-white shadow-sm text-slate-900 border-black/5' : 'text-slate-500 hover:text-slate-900'
                )}
              >
                Theo năm
              </button>
            </div>
          </div>
          {/* Visual Chart Placeholder */}
          <div className="relative mt-4 flex h-[220px] w-full items-end gap-2 overflow-hidden sm:h-[300px] sm:gap-4">
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
            <h3 className="text-lg font-bold text-on-surface">Hàng đợi xử lý</h3>
            <p className="text-sm text-slate-500">Các mục đang chờ xem xét và thao tác</p>
          </div>
          <div className="flex-1 p-4 space-y-3">
            {pendingQueueItems.map((item) => (
              <Link
                key={item.id}
                href={item.href}
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
              </Link>
            ))}
            {latestCompletedItem && (
              <Link href={latestCompletedItem.href} className="block p-4 rounded-2xl bg-slate-50/50 hover:bg-white transition-colors">
                <div className="flex gap-4 items-center">
                  <div className="w-10 h-10 rounded-full bg-emerald-100 flex items-center justify-center flex-shrink-0">
                    <CheckCircle className="text-emerald-600 w-5 h-5" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-bold">{latestCompletedItem.title}</p>
                    <p className="text-xs text-slate-500">{latestCompletedItem.subtitle}</p>
                  </div>
                  <span className="text-[10px] text-slate-400 font-bold whitespace-nowrap">Hoàn tất</span>
                </div>
              </Link>
            )}
            {auditSummary ? (
              <Link href="/settings" className="block rounded-2xl border border-blue-100 bg-blue-50/70 p-4 transition-colors hover:bg-blue-50">
                <div className="flex items-center gap-4">
                  <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-blue-100">
                    <ShieldCheck className="h-5 w-5 text-blue-600" />
                  </div>
                  <div className="min-w-0">
                    <p className="text-sm font-bold text-slate-900">Nhật ký kiểm toán</p>
                    <p className="text-xs text-slate-500">
                      {auditSummary.status === 'available'
                        ? `${auditSummary.totalEvents.toLocaleString('vi-VN')} bản ghi trong 24 giờ.`
                        : 'OpenSearch audit chưa sẵn sàng.'}
                    </p>
                  </div>
                </div>
              </Link>
            ) : null}
          </div>
          <div className="p-4 mt-auto">
            <Link 
              href="/events"
              className="w-full py-3 bg-amber-500 text-white text-xs font-black uppercase tracking-widest rounded-xl hover:opacity-90 transition-opacity flex items-center justify-center"
            >
              Xem tất cả hoạt động
            </Link>
          </div>
        </div>
      </div>

      {/* Floating Action Button */}
      <div className="fixed bottom-24 right-4 z-50 sm:right-8 lg:bottom-8">
        <Link 
          href="/notifications/create"
          className="flex items-center gap-2 rounded-full bg-on-surface px-4 py-3 text-white shadow-2xl transition-transform duration-300 hover:scale-[1.05] sm:px-6 sm:py-4"
        >
          <Plus className="w-5 h-5" />
          <span className="hidden text-sm font-bold sm:inline">Thông báo mới</span>
        </Link>
      </div>
    </div>
  );
}
