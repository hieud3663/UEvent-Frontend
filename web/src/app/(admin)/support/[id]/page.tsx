// File: src/app/(admin)/support/[id]/page.tsx
'use client';

import { useState } from 'react';
import {
  Send,
  User,
  Bold,
  Italic,
  Link as LinkIcon,
  Paperclip,
  Smile,
  ShieldCheck,
  CircleCheck,
  Forward
} from 'lucide-react';
import { mockTickets } from '@/features/support/mock/mock-support';
import { cn } from '@/core/lib/utils';
import type { TicketPriority, TicketStatus, TicketMessage, Ticket } from '@/features/support/types';
import { use } from 'react';

const priorityConfig: Record<TicketPriority, { label: string; color: string }> = {
  low: { label: 'Low', color: 'text-slate-600' },
  medium: { label: 'Medium', color: 'text-blue-600' },
  high: { label: 'High', color: 'text-red-500' },
  urgent: { label: 'Urgent', color: 'text-red-600' },
};

const statusConfig: Record<TicketStatus, { label: string; color: string }> = {
  open: { label: 'Open', color: 'text-blue-600' },
  in_progress: { label: 'InProgress', color: 'text-amber-600' },
  resolved: { label: 'Resolved', color: 'text-emerald-600' },
  closed: { label: 'Closed', color: 'text-slate-600' },
};

interface PageProps {
  params: Promise<{ id: string }>;
}

export default function SupportDetailPage({ params }: PageProps) {
  const resolvedParams = use(params);
  const ticket = mockTickets.find((t) => t.id === resolvedParams.id) || mockTickets[0];
  const [newMessage, setNewMessage] = useState('');
  const [isOnline] = useState(true);

  const priority = priorityConfig[ticket.priority];
  const status = statusConfig[ticket.status];

  return (
    <div className="flex gap-8 flex-1 p-8">
      {/* Left Column: Chat Interface */}
      <div className="flex-1 flex flex-col gap-6">
        {/* Chat Feed */}
        <div className="flex-1 flex flex-col gap-6 max-w-4xl">
          {/* User Message */}
          {ticket.messages.map((message, index) => (
            <div key={message.id}>
              <MessageBubble message={message} />

              {/* System Status Tag - show after first user message */}
              {index === 0 && !message.isStaff && (
                <div className="flex justify-center my-6">
                  <span className="bg-slate-100 text-slate-500 text-[10px] font-bold uppercase tracking-widest px-3 py-1 rounded-full border border-white/40">
                    Ticket assigned to you
                  </span>
                </div>
              )}
            </div>
          ))}
        </div>

        {/* Reply Area */}
        {ticket.status !== 'closed' && (
          <div className="glass-panel p-6 rounded-[32px] border border-white/40 shadow-xl mt-auto">
            <div className="flex flex-col gap-4">
              {/* Formatting Toolbar */}
              <div className="flex items-center gap-4 text-slate-400 px-2">
                <button className="hover:text-primary transition-colors" type="button">
                  <Bold className="w-4 h-4" />
                </button>
                <button className="hover:text-primary transition-colors" type="button">
                  <Italic className="w-4 h-4" />
                </button>
                <button className="hover:text-primary transition-colors" type="button">
                  <LinkIcon className="w-4 h-4" />
                </button>
                <button className="hover:text-primary transition-colors" type="button">
                  <Paperclip className="w-4 h-4" />
                </button>
                <div className="h-4 w-[1px] bg-slate-200"></div>
                <button className="hover:text-primary transition-colors" type="button">
                  <Smile className="w-4 h-4" />
                </button>
              </div>

              {/* Textarea */}
              <textarea
                className="w-full bg-slate-100/50 border-none rounded-2xl focus:ring-2 focus:ring-primary-container/30 text-sm placeholder:text-slate-400 p-4 resize-none"
                placeholder={`Type your reply to ${ticket.userName}...`}
                rows={3}
                value={newMessage}
                onChange={(e) => setNewMessage(e.target.value)}
              />

              {/* Bottom Bar - Online Status & Send Button */}
              <div className="flex justify-between items-center">
                <div className="flex items-center gap-2">
                  <span className={cn("w-2 h-2 rounded-full", isOnline ? "bg-green-500" : "bg-slate-300")}></span>
                  <span className="text-[10px] font-bold uppercase text-slate-500">
                    {isOnline ? `${ticket.userName.split(' ')[0]} is online` : 'Offline'}
                  </span>
                </div>
                <button
                  className="bg-amber-500 text-white px-8 py-3 rounded-xl font-bold text-sm shadow-lg shadow-amber-500/20 flex items-center gap-2 active:scale-95 transition-all"
                  type="button"
                >
                  <span>Send Reply</span>
                  <Send className="w-4 h-4" />
                </button>
              </div>
            </div>
          </div>
        )}
      </div>

      {/* Right Column: Student Info & Ticket Meta */}
      <aside className="w-80 flex flex-col gap-6">
        {/* Profile Info */}
        <section className="glass-panel p-6 rounded-[32px] border border-white/40 shadow-sm flex flex-col items-center text-center">
          <div className="w-24 h-24 rounded-3xl overflow-hidden border-4 border-white shadow-xl mb-4 transform -rotate-3">
            <div className="w-full h-full bg-gradient-to-br from-slate-200 to-slate-300 flex items-center justify-center">
              <User className="w-12 h-12 text-slate-400" />
            </div>
          </div>
          <h3 className="font-headline text-lg font-bold text-slate-900">{ticket.userName}</h3>
          <p className="text-xs font-bold text-primary mb-4">ID: #{ticket.userId}</p>

          {/* Stats */}
          <div className="w-full flex justify-around border-t border-white/40 pt-4 mt-2">
            <div className="flex flex-col">
              <span className="text-[10px] font-bold uppercase text-slate-400">Events</span>
              <span className="text-sm font-bold">12</span>
            </div>
            <div className="w-[1px] bg-white/40"></div>
            <div className="flex flex-col">
              <span className="text-[10px] font-bold uppercase text-slate-400">Tickets</span>
              <span className="text-sm font-bold">28</span>
            </div>
          </div>
        </section>

        {/* Ticket Details - Inquiry Context */}
        <section className="glass-panel p-6 rounded-[32px] border border-white/40 shadow-sm">
          <h4 className="text-[10px] font-black uppercase tracking-widest text-slate-400 mb-4">
            Inquiry Context
          </h4>
          <div className="space-y-4">
            <div className="flex flex-col gap-1">
              <span className="text-[10px] font-bold text-slate-500">Related Event</span>
              <span className="text-xs font-semibold text-slate-900">
                {ticket.category === 'event' ? 'Urban Tech Summit 2024' : 'N/A'}
              </span>
            </div>
            <div className="flex flex-col gap-1">
              <span className="text-[10px] font-bold text-slate-500">Status</span>
              <div className="flex items-center gap-2">
                <span className={cn(
                  "w-2 h-2 rounded-full",
                  ticket.status === 'open' ? 'bg-blue-500' :
                  ticket.status === 'in_progress' ? 'bg-amber-500' :
                  ticket.status === 'resolved' ? 'bg-emerald-500' : 'bg-slate-500'
                )}></span>
                <span className={cn("text-xs font-bold", status.color)}>
                  {status.label}
                </span>
              </div>
            </div>
            <div className="flex flex-col gap-1">
              <span className="text-[10px] font-bold text-slate-500">Priority</span>
              <span className={cn("text-xs font-bold", priority.color)}>
                {priority.label}
              </span>
            </div>
            <div className="flex flex-col gap-1">
              <span className="text-[10px] font-bold text-slate-500">Channel</span>
              <span className="text-xs font-semibold text-slate-900">Web Portal</span>
            </div>
          </div>
        </section>

        {/* Actions */}
        <section className="flex flex-col gap-2">
          <button
            className="w-full py-3 glass-panel hover:bg-white text-slate-700 rounded-2xl font-bold text-xs uppercase tracking-widest border border-white/40 transition-all flex items-center justify-center gap-2"
            type="button"
          >
            <CircleCheck className="w-4 h-4" />
            Mark as Resolved
          </button>
          <button
            className="w-full py-3 glass-panel hover:bg-white text-slate-700 rounded-2xl font-bold text-xs uppercase tracking-widest border border-white/40 transition-all flex items-center justify-center gap-2"
            type="button"
          >
            <Forward className="w-4 h-4" />
            Escalate Ticket
          </button>
        </section>
      </aside>
    </div>
  );
}

function MessageBubble({ message }: { message: TicketMessage }) {
  // Format time
  const messageDate = new Date(message.createdAt);
  const timeStr = messageDate.toLocaleTimeString('en-US', {
    hour: 'numeric',
    minute: '2-digit',
    hour12: true
  });

  if (message.isStaff) {
    // Admin Reply
    return (
      <div className="flex items-start gap-4 flex-row-reverse">
        <div className="w-10 h-10 rounded-full bg-amber-500 flex items-center justify-center flex-shrink-0 border-2 border-white shadow-sm">
          <ShieldCheck className="w-5 h-5 text-white" fill="currentColor" />
        </div>
        <div className="flex flex-col gap-1 items-end">
          <div className="flex items-center gap-2 mb-1">
            <span className="text-[10px] text-slate-400">{timeStr}</span>
            <span className="text-xs font-bold text-slate-900">{message.authorName}</span>
          </div>
          <div className="bg-primary-container text-on-primary-container p-4 rounded-2xl rounded-tr-none shadow-lg shadow-primary-container/10 max-w-md">
            <p className="text-sm leading-relaxed">
              {message.content}
            </p>
          </div>
        </div>
      </div>
    );
  }

  // User Message
  return (
    <div className="flex items-start gap-4">
      <div className="w-10 h-10 rounded-full bg-slate-200 overflow-hidden flex-shrink-0 border-2 border-white shadow-sm">
        <div className="w-full h-full bg-gradient-to-br from-slate-200 to-slate-300 flex items-center justify-center">
          <User className="w-5 h-5 text-slate-400" />
        </div>
      </div>
      <div className="flex flex-col gap-1 items-start">
        <div className="flex items-center gap-2 mb-1">
          <span className="text-xs font-bold text-slate-900">{message.authorName}</span>
          <span className="text-[10px] text-slate-400">{timeStr}</span>
        </div>
        <div className="bg-white p-4 rounded-2xl rounded-tl-none shadow-sm border border-white/60 max-w-md">
          <p className="text-sm text-on-surface leading-relaxed">
            {message.content}
          </p>
        </div>
      </div>
    </div>
  );
}
