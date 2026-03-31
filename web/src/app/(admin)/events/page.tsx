// File: src/app/(admin)/events/page.tsx
'use client';

import { AlertTriangle, CheckCircle, Filter, MoreHorizontal, Calendar, User, TrendingDown, Flag, XCircle } from 'lucide-react';
import { Card } from '@/core/components';
import { mockEvents, eventStats } from '@/features/events/mock/mock-events';
import type { Event } from '@/features/events/types';
import Image from 'next/image';
import Link from 'next/link';

export default function EventsPage() {
  const reportedEvents = mockEvents.filter((e) => e.status === 'reported').slice(0, 2);
  const pendingEvents = mockEvents.filter((e) => e.status === 'pending').slice(0, 1);

  return (
    <div className="space-y-8">
      {/* Header Section */}
      <div className="flex justify-between items-end">
        <div>
          <h2 className="text-2xl font-bold tracking-tight text-on-surface">
            Event Moderation
          </h2>
          <p className="text-on-surface-variant text-sm mt-1">
            Review pending approvals and reported policy violations.
          </p>
        </div>
        <div className="flex gap-2">
          <button 
            type="button"
            onClick={() => alert('Opening advanced filter dialog...')}
            className="px-4 py-2 rounded-full glass-card text-xs font-bold uppercase tracking-wider flex items-center gap-2 border border-white/40"
          >
            <Filter className="w-4 h-4" />
            Filter
          </button>
          <button 
            type="button"
            onClick={() => alert('Starting Quick Audit mode...')}
            className="px-4 py-2 rounded-full bg-primary-container text-on-primary-container text-xs font-bold uppercase tracking-wider"
          >
            Quick Audit
          </button>
        </div>
      </div>

      {/* Moderation Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
        {/* Main Content */}
        <div className="lg:col-span-8 space-y-4">
          {/* Urgent Reports Section */}
          <h3 className="text-xs font-bold uppercase tracking-widest text-error flex items-center gap-2 mb-4">
            <AlertTriangle className="w-4 h-4" />
            Urgent Violations ({reportedEvents.length})
          </h3>

          {reportedEvents.map((event) => (
            <ReportedEventCard key={event.id} event={event} />
          ))}

          {/* Pending Approval Section */}
          <h3 className="text-xs font-bold uppercase tracking-widest text-slate-400 flex items-center gap-2 pt-6 mb-4">
            <CheckCircle className="w-4 h-4" />
            Pending Approval ({eventStats.pendingApproval})
          </h3>

          {pendingEvents.map((event) => (
            <PendingEventCard key={event.id} event={event} />
          ))}
        </div>

        {/* Right Column: Stats & Queue */}
        <div className="lg:col-span-4 space-y-6">
          {/* Moderation Pulse Card */}
          <Card className="glass-card border-none rounded-[32px] p-6">
            <h3 className="text-sm font-bold text-on-surface mb-4">Moderation Pulse</h3>
            <div className="grid grid-cols-2 gap-4">
              <div className="bg-white/50 p-4 rounded-2xl border border-white/40">
                <p className="text-[10px] font-bold text-slate-500 uppercase tracking-wider">Avg Response</p>
                <p className="text-2xl font-black text-on-surface mt-1">1.4h</p>
              </div>
              <div className="bg-white/50 p-4 rounded-2xl border border-white/40">
                <p className="text-[10px] font-bold text-slate-500 uppercase tracking-wider">Queue Size</p>
                <p className="text-2xl font-black text-on-surface mt-1">42</p>
              </div>
            </div>
            <div className="mt-4 p-4 bg-primary-container/20 rounded-2xl border border-primary-container/30">
              <div className="flex items-center justify-between">
                <span className="text-xs font-bold text-primary">Target: &lt; 2h</span>
                <TrendingDown className="w-4 h-4 text-primary" />
              </div>
              <div className="w-full bg-primary/10 h-1.5 rounded-full mt-2">
                <div className="bg-primary w-3/4 h-full rounded-full"></div>
              </div>
            </div>
          </Card>

          {/* Recent Activities Card */}
          <Card className="glass-card border-none rounded-[32px] p-6">
            <h3 className="text-sm font-bold text-on-surface mb-6">Recent Activities</h3>
            <div className="space-y-6">
              <div className="flex gap-3">
                <div className="w-8 h-8 rounded-full bg-green-100 flex items-center justify-center shrink-0">
                  <CheckCircle className="w-4 h-4 text-green-600" />
                </div>
                <div>
                  <p className="text-xs font-bold text-on-surface">Jazz on the Green approved</p>
                  <p className="text-[10px] text-on-surface-variant">by Alex Rivera • 12m ago</p>
                </div>
              </div>
              <div className="flex gap-3">
                <div className="w-8 h-8 rounded-full bg-error/10 flex items-center justify-center shrink-0">
                  <XCircle className="w-4 h-4 text-error" />
                </div>
                <div>
                  <p className="text-xs font-bold text-on-surface">Secret Bunker 404 declined</p>
                  <p className="text-[10px] text-on-surface-variant">Policy violation: Lack of permit • 45m ago</p>
                </div>
              </div>
              <div className="flex gap-3">
                <div className="w-8 h-8 rounded-full bg-blue-100 flex items-center justify-center shrink-0">
                  <Flag className="w-4 h-4 text-blue-600" />
                </div>
                <div>
                  <p className="text-xs font-bold text-on-surface">Sky Lantern Fest flagged</p>
                  <p className="text-[10px] text-on-surface-variant">Pending safety review • 1h ago</p>
                </div>
              </div>
            </div>
          </Card>

          {/* Moderator Policy Handbook Card */}
          <div className="bg-on-surface p-6 rounded-[32px] text-surface-container-lowest">
            <div className="w-6 h-6 flex items-center justify-center mb-2">
              <svg className="w-6 h-6 text-amber-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
              </svg>
            </div>
            <h4 className="font-bold text-sm mb-2">Moderator Policy Handbook</h4>
            <p className="text-[11px] text-white/60 mb-4 leading-relaxed">
              Ensure all events meet the Community Standards v4.2 regarding safety, noise levels, and verified ticketing partners.
            </p>
            <a
              className="inline-flex items-center gap-2 text-[10px] font-black uppercase tracking-widest text-amber-400 hover:text-amber-300 transition-colors"
              href="#"
            >
              Open Docs
              <svg className="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
              </svg>
            </a>
          </div>
        </div>
      </div>
    </div>
  );
}

function ReportedEventCard({ event }: { event: Event }) {
  const reportTypeLabels = {
    safety: 'Safety Concern',
    copyright: 'Copyright Claim',
    spam: 'Spam Report',
    other: 'Other Issue',
  };

  // Image mapping based on event ID - using Stitch design images
  const imageMap: Record<string, string> = {
    '1': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDWr1ZLrB2PRjy_meeHzsve3tDJ5IqG4_V7_hbpCy4BaTbyUvUmXr0COd6ppICAccsQji3LpzrAXoZty2sVF2a-9H_eZONwwoXfNMb2_dHDyoMbFM4EzljjyHGtAZ1ZVwf0vvHIM8LyzOOAKwhZoNCzeDf9XCpYjx_H1G4W1CQ0a_oQmdfw6SzxXNwfHF08cO8Pi5FLVuvEFxMakARkq8B9hYy2Cr71yzY68IKa65embMoyBmnrbk5LXjbJ4TAkfKs89fu7em7d07E',
    '2': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDM-9hYTuO2vpG1-AV5rmjnXqj3aMQRZQag8HNz53HFoGtdIweRS4HDR7YkMC7_Mmet-yBNI764yTib5EE1QOl5sm6fpj_kaaFP1KiJu39owtykk-zkfhY22527LJST21ZpsiVh_Av4-uIBwd2-tQ1BaTMe36BqJUsLrWkGXww6MoPB9DJqjpyz9HyDPciyLxRzC_LhDIJoiVmVRUbZdhYBWZ8jPtQxuqYuIrEWYa05xApOtfaKLMFu96fnsBSBeUg4D1X_3PVnVEg',
  };

  return (
    <Card className="glass-card border-none rounded-3xl p-6 flex flex-col md:flex-row gap-6 border-l-4 border-l-error">
      {/* Image */}
      <div className="w-full md:w-48 h-32 rounded-2xl overflow-hidden shrink-0 relative bg-gradient-to-br from-slate-200 to-slate-300">
        {imageMap[event.id] && (
          <Image
            src={imageMap[event.id]}
            alt={event.title}
            fill
            className="object-cover"
            sizes="(max-width: 768px) 100vw, 192px"
          />
        )}
      </div>

      {/* Content */}
      <div className="flex-grow flex flex-col">
        <div className="flex justify-between items-start">
          <div>
            <h4 className="font-bold text-lg text-on-surface">{event.title}</h4>
            <p className="text-xs text-on-surface-variant flex items-center gap-1 mt-0.5">
              <User className="w-3 h-3" />
              {event.organizer} • <Calendar className="w-3 h-3" />
              {event.date}
            </p>
          </div>
          {event.reportType && (
            <span className="px-2 py-1 rounded bg-error/10 text-error text-[10px] font-bold uppercase tracking-tighter">
              {reportTypeLabels[event.reportType]}
            </span>
          )}
        </div>

        {event.reportSnippet && (
          <div className="mt-4 bg-error-container/30 p-3 rounded-xl">
            <p className="text-xs text-on-error-container leading-relaxed">
              <span className="font-bold">Report Snippet:</span> &quot;{event.reportSnippet}&quot;
            </p>
          </div>
        )}

        <div className="mt-auto pt-4 flex gap-3">
          <Link href={`/events/${event.id}`} className="flex-grow md:flex-none px-6 py-2 bg-on-surface text-surface-container-lowest rounded-xl text-xs font-bold hover:opacity-90 transition-opacity whitespace-nowrap text-center">
            View Event
          </Link>
          <button className="flex-grow md:flex-none px-6 py-2 bg-error text-white rounded-xl text-xs font-bold hover:bg-error/90 transition-opacity">
            Decline
          </button>
          <button className="p-2 glass-card rounded-xl text-on-surface-variant hover:text-on-surface transition-colors border border-white/40">
            <MoreHorizontal className="w-4 h-4" />
          </button>
        </div>
      </div>
    </Card>
  );
}

function PendingEventCard({ event }: { event: Event }) {
  // Image mapping based on event ID - using Stitch design images
  const imageMap: Record<string, string> = {
    '3': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDHRwADeOvL-aYEGvIlevWZus2G-2vSnUrmdx-O3HvJwzxepkds5x4F1uRyEc-jD9l1snnqGlB-TdkmOjEJANEuha_wmkbhHxkkZouX-Q3rcxcqzZnBtnDKun--Y0zrWoaY2OxWdMtPVCEmy68AxIbo61LJ68Rs8fTJ2IM7zBFB4II165OWUNt5f0UBBHSUAbx_9BzpUmd1KkVtBaEqsN4PJb28XaPUegn5rI97fHj8vP8M60a-dlFmtrLO6dSiMBMBt4NUkHvvdLs',
  };

  return (
    <Card className="glass-card border-none rounded-3xl p-6 flex flex-col md:flex-row gap-6 hover:shadow-xl transition-shadow duration-300">
      {/* Image */}
      <div className="w-full md:w-48 h-32 rounded-2xl overflow-hidden shrink-0 relative bg-gradient-to-br from-amber-100 to-amber-200">
        {imageMap[event.id] && (
          <Image
            src={imageMap[event.id]}
            alt={event.title}
            fill
            className="object-cover"
            sizes="(max-width: 768px) 100vw, 192px"
          />
        )}
      </div>

      {/* Content */}
      <div className="flex-grow flex flex-col">
        <div className="flex justify-between items-start">
          <div>
            <h4 className="font-bold text-lg text-on-surface">{event.title}</h4>
            <p className="text-xs text-on-surface-variant flex items-center gap-1 mt-0.5">
              <User className="w-3 h-3" />
              {event.organizer} • <Calendar className="w-3 h-3" />
              {event.date}
            </p>
          </div>
          <span className="px-2 py-1 rounded bg-secondary-container/30 text-secondary text-[10px] font-bold uppercase tracking-tighter">
            New Organizer
          </span>
        </div>

        <p className="text-xs text-on-surface-variant mt-4 line-clamp-2 leading-relaxed">
          Sierra Sol is a newly registered wellness collective. They are proposing a 3-day high-altitude yoga experience for 50 guests. Documentation for insurance is attached.
        </p>

        <div className="mt-auto pt-4 flex gap-3">
          <button className="flex-grow md:flex-none px-6 py-2 bg-amber-500 text-white rounded-xl text-xs font-bold hover:bg-amber-600 transition-colors">
            Approve
          </button>
          <Link href={`/events/${event.id}`} className="flex-grow md:flex-none px-6 py-2 glass-card text-on-surface rounded-xl text-xs font-bold border border-white/40 text-center">
            Review Details
          </Link>
        </div>
      </div>
    </Card>
  );
}
