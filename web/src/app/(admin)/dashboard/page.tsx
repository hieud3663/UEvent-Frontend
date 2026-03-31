// File: src/app/(admin)/dashboard/page.tsx
import { Users, Ticket, CalendarCheck, Banknote, Plus, ArrowRight, CheckCircle } from 'lucide-react';
import Link from 'next/link';
import { StatsCard } from '@/features/dashboard/components';

export default function DashboardPage() {
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
        <StatsCard
          title="Total Users"
          value="42,891"
          change={{ value: 12.5, trend: 'up' }}
          icon={Users}
          iconColor="text-amber-500"
          iconBgColor="bg-amber-100"
        />
        <StatsCard
          title="Registrations"
          value="156,042"
          change={{ value: 8.2, trend: 'up' }}
          icon={Ticket}
          iconColor="text-amber-500"
          iconBgColor="bg-amber-100"
        />
        <StatsCard
          title="Active Events"
          value="1,204"
          change={{ value: 0, trend: 'neutral', label: 'Active Now' }}
          icon={CalendarCheck}
          iconColor="text-amber-500"
          iconBgColor="bg-amber-100"
        />
        <StatsCard
          title="Total Revenue"
          value="$2.4M"
          change={{ value: 15.9, trend: 'up' }}
          icon={Banknote}
          iconColor="text-amber-500"
          iconBgColor="bg-amber-100"
        />
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
              <button className="px-4 py-1.5 text-xs font-bold bg-white shadow-sm rounded-full border border-black/5">
                Monthly
              </button>
              <button className="px-4 py-1.5 text-xs font-bold text-slate-500 hover:text-slate-900">
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
            {/* Simulated Bars */}
            <div className="flex-1 bg-amber-100 rounded-t-xl h-[40%]"></div>
            <div className="flex-1 bg-amber-200 rounded-t-xl h-[60%]"></div>
            <div className="flex-1 bg-amber-300 rounded-t-xl h-[55%]"></div>
            <div className="flex-1 bg-amber-400 rounded-t-xl h-[85%]"></div>
            <div className="flex-1 bg-primary-container rounded-t-xl h-[95%] shadow-[0_0_20px_rgba(255,184,0,0.3)]"></div>
            <div className="flex-1 bg-amber-300 rounded-t-xl h-[70%]"></div>
            <div className="flex-1 bg-amber-200 rounded-t-xl h-[45%]"></div>
            <div className="flex-1 bg-amber-100 rounded-t-xl h-[30%]"></div>
            <div className="flex-1 bg-amber-200 rounded-t-xl h-[50%]"></div>
            <div className="flex-1 bg-amber-400 rounded-t-xl h-[75%]"></div>
            <div className="flex-1 bg-primary-container rounded-t-xl h-[90%]"></div>
            <div className="flex-1 bg-amber-300 rounded-t-xl h-[65%]"></div>
          </div>
          <div className="flex justify-between mt-4 text-[10px] font-bold text-slate-400 px-1 uppercase tracking-tighter">
            <span>Jan</span>
            <span>Feb</span>
            <span>Mar</span>
            <span>Apr</span>
            <span>May</span>
            <span>Jun</span>
            <span>Jul</span>
            <span>Aug</span>
            <span>Sep</span>
            <span>Oct</span>
            <span>Nov</span>
            <span>Dec</span>
          </div>
        </div>

        {/* Queue Management */}
        <div className="glass-card rounded-[32px] overflow-hidden flex flex-col">
          <div className="p-6 border-b border-black/5 bg-white/40">
            <h3 className="text-lg font-bold text-on-surface">Queue Management</h3>
            <p className="text-sm text-slate-500">Pending reviews and actions</p>
          </div>
          <div className="flex-1 p-4 space-y-3">
            {/* Pending Item 1 */}
            <div className="group p-4 rounded-2xl bg-white/50 hover:bg-white transition-all cursor-pointer border border-transparent hover:border-amber-100">
              <div className="flex gap-4 items-center">
                <div className="w-10 h-10 rounded-full bg-surface-container overflow-hidden flex-shrink-0">
                  <div className="w-full h-full bg-gradient-to-br from-amber-200 to-amber-400" />
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-bold truncate">Cyber Summit 2024</p>
                  <p className="text-xs text-slate-500">New event approval requested</p>
                </div>
                <ArrowRight className="text-amber-500 w-5 h-5 opacity-0 group-hover:opacity-100 transition-opacity" />
              </div>
            </div>
            {/* Pending Item 2 */}
            <div className="group p-4 rounded-2xl bg-white/50 hover:bg-white transition-all cursor-pointer border border-transparent hover:border-amber-100">
              <div className="flex gap-4 items-center">
                <div className="w-10 h-10 rounded-full bg-surface-container overflow-hidden flex-shrink-0">
                  <div className="w-full h-full bg-gradient-to-br from-amber-300 to-amber-500" />
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-bold truncate">Creative Workshop</p>
                  <p className="text-xs text-slate-500">Organizer verification</p>
                </div>
                <ArrowRight className="text-amber-500 w-5 h-5 opacity-0 group-hover:opacity-100 transition-opacity" />
              </div>
            </div>
            {/* Activity Item */}
            <div className="p-4 rounded-2xl bg-slate-50/50">
              <div className="flex gap-4 items-center">
                <div className="w-10 h-10 rounded-full bg-emerald-100 flex items-center justify-center flex-shrink-0">
                  <CheckCircle className="text-emerald-600 w-5 h-5" />
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-bold">System Update</p>
                  <p className="text-xs text-slate-500">Security patches applied</p>
                </div>
                <span className="text-[10px] text-slate-400 font-bold whitespace-nowrap">2H AGO</span>
              </div>
            </div>
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
