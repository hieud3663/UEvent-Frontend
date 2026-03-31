// File: src/app/(admin)/settings/page.tsx
'use client';

import { useState } from 'react';
import { Download, Users, ShieldAlert, TrendingUp, Shield, Verified, Calendar, Settings } from 'lucide-react';
import { Button } from '@/core/components';
import { cn } from '@/core/lib/utils';

interface LogEntry {
  id: string;
  timestamp: string;
  date: string;
  time: string;
  user: {
    name: string;
    initials: string;
    color: string;
  };
  action: string;
  status: 'success' | 'failed';
}

const mockLogs: LogEntry[] = [
  {
    id: '1',
    timestamp: '2023-10-24T14:42:01.32Z',
    date: 'Oct 24, 2023',
    time: '14:42:01.32',
    user: { name: 'Alex Rivers', initials: 'AR', color: 'indigo' },
    action: 'Settings Updated',
    status: 'success',
  },
  {
    id: '2',
    timestamp: '2023-10-24T14:35:44.92Z',
    date: 'Oct 24, 2023',
    time: '14:35:44.92',
    user: { name: 'Anonymous', initials: '?', color: 'amber' },
    action: 'Login Attempt',
    status: 'failed',
  },
  {
    id: '3',
    timestamp: '2023-10-24T13:20:15.12Z',
    date: 'Oct 24, 2023',
    time: '13:20:15.12',
    user: { name: 'Sarah Chen', initials: 'SC', color: 'emerald' },
    action: 'Event Approved',
    status: 'success',
  },
  {
    id: '4',
    timestamp: '2023-10-24T12:15:30.88Z',
    date: 'Oct 24, 2023',
    time: '12:15:30.88',
    user: { name: 'Mike Johnson', initials: 'MJ', color: 'purple' },
    action: 'User Banned',
    status: 'success',
  },
  {
    id: '5',
    timestamp: '2023-10-24T11:05:22.45Z',
    date: 'Oct 24, 2023',
    time: '11:05:22.45',
    user: { name: 'Anonymous', initials: '?', color: 'amber' },
    action: 'Login Attempt',
    status: 'failed',
  },
];

export default function SettingsPage() {
  const [darkMode, setDarkMode] = useState(true);
  const [auditAlerts, setAuditAlerts] = useState(true);
  const [dateRange, setDateRange] = useState('24hours');
  const [actionType, setActionType] = useState('all');

  return (
    <div className="space-y-8">
      {/* Header Section */}
      <div className="flex justify-between items-end">
        <div>
          <h1 className="text-3xl font-bold tracking-tight text-slate-900">
            System Logs &amp; Audit Trail
          </h1>
          <p className="text-slate-500 text-sm mt-1">
            Real-time monitoring of platform operations and administrative actions.
          </p>
        </div>
        <Button
          variant="outline"
          className="bg-white/80 hover:bg-white border border-white/40 shadow-sm backdrop-blur-md"
          leftIcon={<Download className="w-[18px] h-[18px]" />}
        >
          Export Audit Logs
        </Button>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <StatsCard
          icon={<Users className="w-5 h-5" />}
          iconBg="bg-amber-100"
          iconColor="text-amber-600"
          label="Total Sessions Today"
          value="12,842"
          badge={{ text: '+12%', color: 'emerald' }}
        />
        <StatsCard
          icon={<ShieldAlert className="w-5 h-5" />}
          iconBg="bg-red-100"
          iconColor="text-red-600"
          label="Failed Logins"
          value="42"
          badge={{ text: '-3%', color: 'red' }}
        />
        <StatsCard
          icon={<TrendingUp className="w-5 h-5" />}
          iconBg="bg-blue-100"
          iconColor="text-blue-600"
          label="Peak Activity Time"
          value="14:20 PM"
        />
        <StatsCard
          icon={<Shield className="w-5 h-5" />}
          iconBg="bg-purple-100"
          iconColor="text-purple-600"
          label="Active Admins"
          value="07"
          avatars={2}
        />
      </div>

      {/* Main Content Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-8">
        {/* Left Column: System Logs Table */}
        <div className="lg:col-span-8 space-y-6">
          {/* Filters */}
          <div className="glass-panel glass-border p-4 rounded-[2rem] flex flex-wrap items-center gap-4">
            <div className="flex-1 min-w-[150px]">
              <label className="block text-[10px] font-bold text-slate-400 uppercase tracking-widest mb-1.5 ml-2">
                Date Range
              </label>
              <div className="relative">
                <Calendar className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 w-[14px] h-[14px]" />
                <select
                  value={dateRange}
                  onChange={(e) => setDateRange(e.target.value)}
                  className="w-full bg-slate-100/50 border-none rounded-xl pl-9 pr-4 py-2 text-sm text-slate-700 appearance-none focus:ring-2 focus:ring-amber-500/20 transition-all cursor-pointer"
                >
                  <option value="24hours">Last 24 Hours</option>
                  <option value="7days">Last 7 Days</option>
                  <option value="30days">Last 30 Days</option>
                </select>
              </div>
            </div>
            <div className="flex-1 min-w-[150px]">
              <label className="block text-[10px] font-bold text-slate-400 uppercase tracking-widest mb-1.5 ml-2">
                Action Type
              </label>
              <div className="flex gap-2">
                <button
                  type="button"
                  onClick={() => setActionType('all')}
                  className={cn(
                    'px-4 py-2 rounded-xl text-[10px] font-bold uppercase tracking-wider transition-all',
                    actionType === 'all'
                      ? 'bg-amber-500 text-white shadow-md shadow-amber-500/20'
                      : 'bg-slate-100/80 text-slate-500 hover:bg-slate-200/50'
                  )}
                >
                  All
                </button>
                <button
                  type="button"
                  onClick={() => setActionType('error')}
                  className={cn(
                    'px-4 py-2 rounded-xl text-[10px] font-bold uppercase tracking-wider transition-all',
                    actionType === 'error'
                      ? 'bg-amber-500 text-white shadow-md shadow-amber-500/20'
                      : 'bg-slate-100/80 text-slate-500 hover:bg-slate-200/50'
                  )}
                >
                  Error
                </button>
              </div>
            </div>
          </div>

          {/* Logs Table */}
          <div className="glass-panel glass-border rounded-[2.5rem] overflow-hidden shadow-sm">
            <div className="overflow-x-auto">
              <table className="w-full text-left border-collapse">
                <thead>
                  <tr className="bg-slate-50/50 border-b border-slate-100/50">
                    <th className="px-6 py-4 text-[10px] font-bold text-slate-400 uppercase tracking-widest">
                      Timestamp
                    </th>
                    <th className="px-6 py-4 text-[10px] font-bold text-slate-400 uppercase tracking-widest">
                      User/Admin
                    </th>
                    <th className="px-6 py-4 text-[10px] font-bold text-slate-400 uppercase tracking-widest">
                      Action
                    </th>
                    <th className="px-6 py-4 text-[10px] font-bold text-slate-400 uppercase tracking-widest text-right">
                      Status
                    </th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-50/50">
                  {mockLogs.map((log) => (
                    <tr key={log.id} className="hover:bg-amber-50/30 transition-colors group">
                      <td className="px-6 py-4">
                        <div className="flex flex-col">
                          <span className="text-sm font-semibold text-slate-900">{log.date}</span>
                          <span className="text-[10px] text-slate-400 font-mono">{log.time}</span>
                        </div>
                      </td>
                      <td className="px-6 py-4">
                        <div className="flex items-center gap-3">
                          <div
                            className={cn(
                              'w-8 h-8 rounded-full flex items-center justify-center text-xs font-bold',
                              log.user.color === 'indigo' && 'bg-indigo-100 text-indigo-600',
                              log.user.color === 'amber' && 'bg-amber-100 text-amber-600',
                              log.user.color === 'emerald' && 'bg-emerald-100 text-emerald-600',
                              log.user.color === 'purple' && 'bg-purple-100 text-purple-600'
                            )}
                          >
                            {log.user.initials}
                          </div>
                          <p className="text-sm font-bold text-slate-900">{log.user.name}</p>
                        </div>
                      </td>
                      <td className="px-6 py-4">
                        <span className="text-sm font-medium text-slate-700">{log.action}</span>
                      </td>
                      <td className="px-6 py-4 text-right">
                        <span
                          className={cn(
                            'px-2.5 py-1 rounded-full text-[10px] font-bold uppercase tracking-wider',
                            log.status === 'success' && 'bg-emerald-100 text-emerald-700',
                            log.status === 'failed' && 'bg-red-100 text-red-700'
                          )}
                        >
                          {log.status}
                        </span>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
            <div className="px-6 py-4 bg-slate-50/30 border-t border-slate-100/50 flex items-center justify-between">
              <p className="text-[10px] text-slate-400 font-bold uppercase tracking-wider">
                Showing 1-15 of 1,240
              </p>
              <div className="flex gap-1">
                <button
                  type="button"
                  className="w-8 h-8 rounded-lg bg-amber-500 text-white text-xs font-bold"
                >
                  1
                </button>
                <button
                  type="button"
                  className="w-8 h-8 rounded-lg text-slate-600 text-xs font-bold hover:bg-slate-200/50"
                >
                  2
                </button>
                <button
                  type="button"
                  className="w-8 h-8 rounded-lg text-slate-600 text-xs font-bold hover:bg-slate-200/50"
                >
                  3
                </button>
              </div>
            </div>
          </div>
        </div>

        {/* Right Column: System Preferences & Support */}
        <div className="lg:col-span-4 space-y-6">
          {/* System Preferences */}
          <div className="glass-panel glass-border rounded-[32px] p-8 shadow-sm">
            <h3 className="text-xl font-bold text-slate-900 mb-8 flex items-center gap-3">
              <Settings className="w-5 h-5 text-amber-500" />
              System Preferences
            </h3>
            <div className="space-y-8">
              <div className="flex items-center justify-between group">
                <div className="space-y-1">
                  <p className="font-bold text-slate-900">Dark Mode</p>
                  <p className="text-xs text-slate-500">Sync with system default</p>
                </div>
                <label className="relative inline-flex items-center cursor-pointer">
                  <input
                    type="checkbox"
                    className="sr-only peer"
                    checked={darkMode}
                    onChange={(e) => setDarkMode(e.target.checked)}
                  />
                  <div className="w-11 h-6 bg-slate-200 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-amber-500"></div>
                </label>
              </div>
              <div className="flex items-center justify-between group">
                <div className="space-y-1">
                  <p className="font-bold text-slate-900">Audit Alerts</p>
                  <p className="text-xs text-slate-500">Notify on critical log events</p>
                </div>
                <label className="relative inline-flex items-center cursor-pointer">
                  <input
                    type="checkbox"
                    className="sr-only peer"
                    checked={auditAlerts}
                    onChange={(e) => setAuditAlerts(e.target.checked)}
                  />
                  <div className="w-11 h-6 bg-slate-200 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-amber-500"></div>
                </label>
              </div>
            </div>
            <div className="mt-12 p-6 rounded-2xl bg-amber-50 border border-amber-100/50">
              <div className="flex gap-4">
                <Verified className="w-5 h-5 text-amber-600 shrink-0 mt-0.5" />
                <div>
                  <p className="text-xs font-bold text-amber-900 uppercase tracking-widest mb-1">
                    Security Status
                  </p>
                  <p className="text-[11px] text-amber-800 leading-snug">
                    Two-factor authentication is active. Last audit review 2h ago.
                  </p>
                </div>
              </div>
            </div>
          </div>

          {/* System Support */}
          <div className="glass-panel glass-border rounded-[32px] p-8 shadow-sm bg-slate-900 text-white overflow-hidden relative">
            <div className="relative z-10">
              <h4 className="text-lg font-bold mb-2">System Support</h4>
              <p className="text-slate-400 text-sm mb-6">
                Need assistance with admin privileges or logs?
              </p>
              <button
                type="button"
                className="w-full py-3 bg-white/10 backdrop-blur-md border border-white/20 rounded-xl font-bold text-sm hover:bg-white/20 transition-colors"
              >
                Open Support Ticket
              </button>
            </div>
            <div className="absolute -right-12 -bottom-12 w-40 h-40 bg-amber-500/20 blur-[60px] rounded-full"></div>
          </div>
        </div>
      </div>
    </div>
  );
}

interface StatsCardProps {
  icon: React.ReactNode;
  iconBg: string;
  iconColor: string;
  label: string;
  value: string;
  badge?: {
    text: string;
    color: 'emerald' | 'red';
  };
  avatars?: number;
}

function StatsCard({ icon, iconBg, iconColor, label, value, badge, avatars }: StatsCardProps) {
  return (
    <div className="glass-panel glass-border p-5 rounded-3xl shadow-sm flex flex-col justify-between h-32">
      <div className="flex justify-between items-start">
        <span className={cn('p-2 rounded-lg', iconBg, iconColor)}>{icon}</span>
        {badge && (
          <span
            className={cn(
              'text-[10px] font-bold px-2 py-0.5 rounded-full',
              badge.color === 'emerald' && 'text-emerald-600 bg-emerald-50',
              badge.color === 'red' && 'text-red-600 bg-red-50'
            )}
          >
            {badge.text}
          </span>
        )}
        {avatars && (
          <div className="flex -space-x-2">
            <div className="w-6 h-6 rounded-full border-2 border-white bg-slate-200"></div>
            <div className="w-6 h-6 rounded-full border-2 border-white bg-slate-300"></div>
          </div>
        )}
      </div>
      <div>
        <p className="text-[10px] font-bold uppercase tracking-wider text-slate-400">{label}</p>
        <p className="text-2xl font-black text-slate-900 leading-tight">{value}</p>
      </div>
    </div>
  );
}
