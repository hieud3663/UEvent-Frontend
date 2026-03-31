'use client';

import { useState } from 'react';
import Link from 'next/link';
import { Filter, Timer, MoreHorizontal, ChevronLeft, ChevronRight } from 'lucide-react';
import { mockTickets } from '@/features/support/mock/mock-support';
import { cn } from '@/core/lib/utils';
import type { Ticket, TicketStatus } from '@/features/support/types';

const statusConfig: Record<TicketStatus, { label: string; variant: 'success' | 'warning' | 'info' | 'neutral' }> = {
  open: { label: 'Pending', variant: 'warning' },
  in_progress: { label: 'In Progress', variant: 'info' },
  resolved: { label: 'Resolved', variant: 'success' },
  closed: { label: 'Closed', variant: 'neutral' },
};

type FilterType = 'all' | 'pending' | 'in_progress';
type QueueType = 'all' | 'technical' | 'billing' | 'general';

export default function SupportPage() {
  const [filterType, setFilterType] = useState<FilterType>('all');
  const [queueType, setQueueType] = useState<QueueType>('all');
  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 3;

  // Filter tickets based on selected filters
  const filteredTickets = mockTickets.filter((ticket) => {
    if (filterType === 'pending' && ticket.status !== 'open') return false;
    if (filterType === 'in_progress' && ticket.status !== 'in_progress') return false;

    if (queueType === 'technical' && ticket.category !== 'technical') return false;
    if (queueType === 'billing' && ticket.category !== 'payment') return false;
    // Note: 'general' could map to 'other' category or show all non-technical/billing

    return true;
  });

  const totalPages = Math.ceil(filteredTickets.length / itemsPerPage);
  const paginatedTickets = filteredTickets.slice(
    (currentPage - 1) * itemsPerPage,
    currentPage * itemsPerPage
  );

  const totalTickets = 2451; // From Stitch design
  const pendingInquiries = mockTickets.filter((t) => t.status === 'open').length;

  return (
    <div className="space-y-8 pb-32">
      {/* Header Section */}
      <div className="flex items-end justify-between">
        <div>
          <h1 className="text-3xl font-bold tracking-tight text-slate-900">
            Support &amp; Inquiries
          </h1>
          <p className="text-slate-500 mt-1">
            Manage and respond to user questions and support tickets.
          </p>
        </div>
        <div className="flex items-center gap-3">
          {/* Status Filter Toggle */}
          <div className="flex bg-white/60 p-1 rounded-full border border-white/80 shadow-sm">
            <button
              onClick={() => setFilterType('all')}
              className={cn(
                'px-4 py-1.5 rounded-full text-xs font-bold transition-all',
                filterType === 'all'
                  ? 'bg-amber-500 text-white'
                  : 'text-slate-500 hover:bg-slate-100'
              )}
            >
              ALL
            </button>
            <button
              onClick={() => setFilterType('pending')}
              className={cn(
                'px-4 py-1.5 rounded-full text-xs font-bold transition-all',
                filterType === 'pending'
                  ? 'bg-amber-500 text-white'
                  : 'text-slate-500 hover:bg-slate-100'
              )}
            >
              PENDING
            </button>
            <button
              onClick={() => setFilterType('in_progress')}
              className={cn(
                'px-4 py-1.5 rounded-full text-xs font-bold transition-all',
                filterType === 'in_progress'
                  ? 'bg-amber-500 text-white'
                  : 'text-slate-500 hover:bg-slate-100'
              )}
            >
              IN PROGRESS
            </button>
          </div>

          {/* Filter Button */}
          <button 
            type="button"
            onClick={() => alert('Opening advanced filter options...')}
            className="flex items-center gap-2 bg-white px-4 py-2 rounded-xl shadow-sm border border-white/80 text-sm font-semibold text-slate-700 hover:scale-[1.02] transition-transform"
          >
            <Filter className="w-4 h-4" />
            Filter
          </button>
        </div>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        {/* Total Tickets */}
        <div className="col-span-1 bg-white/80 backdrop-blur-md p-6 rounded-2xl shadow-sm border border-white/40">
          <p className="text-xs font-bold text-slate-400 uppercase tracking-widest mb-2">
            Total Tickets
          </p>
          <div className="flex items-baseline gap-2">
            <span className="text-4xl font-extrabold text-slate-900">{totalTickets.toLocaleString('en-US')}</span>
          </div>
          <p className="text-xs text-green-600 font-medium mt-2">+12% this week</p>
        </div>

        {/* Pending Inquiries */}
        <div className="col-span-1 bg-white/80 backdrop-blur-md p-6 rounded-2xl shadow-sm border border-white/40">
          <p className="text-xs font-bold text-slate-400 uppercase tracking-widest mb-2">
            Pending Inquiries
          </p>
          <span className="text-4xl font-extrabold text-slate-900">{pendingInquiries}</span>
          <p className="text-xs text-amber-600 font-medium mt-2">Requires urgent attention</p>
        </div>

        {/* Avg. Response Time - Large Card */}
        <div className="col-span-2 bg-amber-500 p-6 rounded-2xl shadow-lg border border-amber-400 relative overflow-hidden">
          <div className="relative z-10">
            <p className="text-xs font-bold text-amber-100 uppercase tracking-widest mb-2">
              Avg. Response Time
            </p>
            <span className="text-4xl font-extrabold text-white">2.4 hrs</span>
            <p className="text-xs text-amber-100 font-medium mt-2">
              Improving by 15 mins since yesterday
            </p>
          </div>
          <Timer className="absolute -right-4 -bottom-4 w-36 h-36 text-amber-400/30 rotate-12" />
        </div>
      </div>

      {/* Support Table */}
      <div className="bg-white/40 backdrop-blur-xl rounded-[2rem] border border-white/60 shadow-lg overflow-hidden">
        <table className="w-full text-left border-collapse">
          <thead>
            <tr className="bg-slate-50/50">
              <th className="px-8 py-5 text-[10px] font-extrabold text-slate-400 uppercase tracking-widest">
                User
              </th>
              <th className="px-8 py-5 text-[10px] font-extrabold text-slate-400 uppercase tracking-widest w-1/3">
                Subject / Question
              </th>
              <th className="px-8 py-5 text-[10px] font-extrabold text-slate-400 uppercase tracking-widest">
                Date
              </th>
              <th className="px-8 py-5 text-[10px] font-extrabold text-slate-400 uppercase tracking-widest">
                Status
              </th>
              <th className="px-8 py-5 text-[10px] font-extrabold text-slate-400 uppercase tracking-widest text-right">
                Actions
              </th>
            </tr>
          </thead>
          <tbody className="divide-y divide-white/40">
            {paginatedTickets.map((ticket) => (
              <TicketRow key={ticket.id} ticket={ticket} />
            ))}
          </tbody>
        </table>

        {/* Pagination Section */}
        <div className="bg-slate-50/50 px-8 py-4 flex items-center justify-between">
          <p className="text-xs font-medium text-slate-500">
            Showing {(currentPage - 1) * itemsPerPage + 1} to{' '}
            {Math.min(currentPage * itemsPerPage, filteredTickets.length)} of{' '}
            {totalTickets.toLocaleString('en-US')} entries
          </p>
          <div className="flex gap-2">
            <button
              onClick={() => setCurrentPage((p) => Math.max(1, p - 1))}
              disabled={currentPage === 1}
              className="w-8 h-8 rounded-lg flex items-center justify-center border border-slate-200 text-slate-400 hover:bg-white transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <ChevronLeft className="w-4 h-4" />
            </button>
            {[...Array(Math.min(3, totalPages))].map((_, i) => (
              <button
                key={i + 1}
                onClick={() => setCurrentPage(i + 1)}
                className={cn(
                  'w-8 h-8 rounded-lg flex items-center justify-center text-xs font-bold transition-colors',
                  currentPage === i + 1
                    ? 'bg-amber-500 text-white'
                    : 'border border-slate-200 text-slate-600 hover:bg-white'
                )}
              >
                {i + 1}
              </button>
            ))}
            <button
              onClick={() => setCurrentPage((p) => Math.min(totalPages, p + 1))}
              disabled={currentPage === totalPages}
              className="w-8 h-8 rounded-lg flex items-center justify-center border border-slate-200 text-slate-400 hover:bg-white transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <ChevronRight className="w-4 h-4" />
            </button>
          </div>
        </div>
      </div>

      {/* Floating Category/Filter Nav */}
      <div className="fixed bottom-8 left-1/2 -translate-x-1/2 flex items-center gap-2 bg-white/70 backdrop-blur-xl p-2 rounded-full border border-white/60 shadow-lg z-30">
        <span className="px-4 text-[10px] font-extrabold text-slate-400 uppercase tracking-widest border-r border-slate-200 mr-2">
          Queue Type
        </span>
        <button
          onClick={() => setQueueType('all')}
          className={cn(
            'px-4 py-2 rounded-full text-xs font-bold transition-colors',
            queueType === 'all'
              ? 'bg-amber-500 text-white'
              : 'text-slate-600 hover:bg-slate-100'
          )}
        >
          All Support
        </button>
        <button
          onClick={() => setQueueType('technical')}
          className={cn(
            'px-4 py-2 rounded-full text-xs font-bold transition-colors',
            queueType === 'technical'
              ? 'bg-amber-500 text-white'
              : 'text-slate-600 hover:bg-slate-100'
          )}
        >
          Technical
        </button>
        <button
          onClick={() => setQueueType('billing')}
          className={cn(
            'px-4 py-2 rounded-full text-xs font-bold transition-colors',
            queueType === 'billing'
              ? 'bg-amber-500 text-white'
              : 'text-slate-600 hover:bg-slate-100'
          )}
        >
          Billing
        </button>
        <button
          onClick={() => setQueueType('general')}
          className={cn(
            'px-4 py-2 rounded-full text-xs font-bold transition-colors',
            queueType === 'general'
              ? 'bg-amber-500 text-white'
              : 'text-slate-600 hover:bg-slate-100'
          )}
        >
          General
        </button>
      </div>
    </div>
  );
}

function TicketRow({ ticket }: { ticket: Ticket }) {
  const status = statusConfig[ticket.status];

  // Extract ticket number from ID (e.g., TKT-001 -> #001)
  const ticketNumber = `#${ticket.id.replace('TKT-', '443')}`;

  // Get first message preview (truncated)
  const preview = ticket.messages[0]?.content || ticket.description;

  // Format date
  const date = new Date(ticket.createdAt);
  const formattedDate = date.toLocaleDateString('en-US', {
    month: 'short',
    day: 'numeric',
    year: 'numeric'
  });
  const formattedTime = date.toLocaleTimeString('en-US', {
    hour: '2-digit',
    minute: '2-digit'
  });

  return (
    <tr className="group hover:bg-white/60 transition-colors">
      {/* User Column */}
      <td className="px-8 py-6">
        <div className="flex items-center gap-4">
          <div className="w-10 h-10 rounded-full bg-slate-200 overflow-hidden relative">
            {/* Placeholder avatar with initials */}
            <div className="w-full h-full flex items-center justify-center bg-gradient-to-br from-amber-200 to-amber-400 text-slate-700 font-bold text-sm">
              {ticket.userName.split(' ').map(n => n[0]).join('')}
            </div>
          </div>
          <div>
            <p className="text-sm font-bold text-slate-900">{ticket.userName}</p>
            <p className="text-xs text-slate-500">ID: {ticketNumber}</p>
          </div>
        </div>
      </td>

      {/* Subject Column */}
      <td className="px-8 py-6">
        <div className="space-y-1">
          <p className="text-sm font-bold text-slate-800 truncate">{ticket.subject}</p>
          <p className="text-xs text-slate-600 line-clamp-1 italic">
            &quot;{preview}&quot;
          </p>
        </div>
      </td>

      {/* Date Column */}
      <td className="px-8 py-6">
        <p className="text-xs font-medium text-slate-500">{formattedDate}</p>
        <p className="text-[10px] text-slate-400">{formattedTime}</p>
      </td>

      {/* Status Column */}
      <td className="px-8 py-6">
        <span className={cn(
          'inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-[10px] font-bold uppercase tracking-wider',
          status.variant === 'success' && 'bg-green-100 text-green-700',
          status.variant === 'warning' && 'bg-amber-100 text-amber-700',
          status.variant === 'info' && 'bg-blue-100 text-blue-700',
          status.variant === 'neutral' && 'bg-slate-100 text-slate-700'
        )}>
          <span className={cn(
            'w-1.5 h-1.5 rounded-full',
            status.variant === 'success' && 'bg-green-500',
            status.variant === 'warning' && 'bg-amber-500',
            status.variant === 'info' && 'bg-blue-500',
            status.variant === 'neutral' && 'bg-slate-500'
          )} />
          {status.label}
        </span>
      </td>

      {/* Actions Column */}
      <td className="px-8 py-6 text-right">
        {ticket.status === 'open' ? (
          <Link href={`/support/${ticket.id}`}>
            <button className="bg-amber-500 text-white px-4 py-2 rounded-lg text-xs font-bold hover:scale-[1.05] transition-transform active:scale-95 shadow-md shadow-amber-200">
              Answer
            </button>
          </Link>
        ) : ticket.status === 'in_progress' ? (
          <Link href={`/support/${ticket.id}`}>
            <button className="bg-white border border-amber-500 text-amber-600 px-4 py-2 rounded-lg text-xs font-bold hover:bg-amber-50 transition-colors">
              Reply
            </button>
          </Link>
        ) : (
          <Link href={`/support/${ticket.id}`}>
            <button className="p-2 text-slate-400 hover:text-slate-900 transition-colors">
              <MoreHorizontal className="w-5 h-5" />
            </button>
          </Link>
        )}
      </td>
    </tr>
  );
}
