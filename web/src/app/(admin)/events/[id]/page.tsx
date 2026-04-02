// File: src/app/(admin)/events/[id]/page.tsx
'use client';

import Image from 'next/image';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import {
  ChevronLeft,
  Bell,
  Settings,
  AlertTriangle,
  Calendar,
  MapPin,
  Users,
  Flag,
  History,
} from 'lucide-react';
import { toast } from 'sonner';

export default function EventReviewDetailPage() {
  const router = useRouter();

  const handleApprove = () => {
    toast.success('Event approved and published.');
    router.push('/events');
  };

  const handleDecline = () => {
    toast.success('Event declined and organizer notified.');
    router.push('/events');
  };

  return (
    <div className="min-h-screen pb-12">
      {/* TopNavBar */}
      <header className="fixed top-0 left-64 right-0 z-40 flex items-center justify-between px-8 h-[64px] bg-white/65 backdrop-blur-[40px] saturate-180 border-b-[0.5px] border-black/10">
        <div className="flex items-center gap-4">
          <Link
            href="/events"
            className="w-10 h-10 flex items-center justify-center rounded-full hover:bg-black/5 transition-colors text-slate-900"
          >
            <ChevronLeft className="w-6 h-6" />
          </Link>
          <h2 className="text-xl font-bold text-slate-900 tracking-tight">
            Event Details Review
          </h2>
        </div>

        <div className="flex items-center gap-3">
          <button
            type="button"
            onClick={handleDecline}
            className="px-6 py-2 rounded-full border border-red-600 text-red-600 font-bold text-sm hover:bg-red-50 transition-all active:scale-95"
          >
            Decline
          </button>
          <button
            type="button"
            onClick={handleApprove}
            className="px-6 py-2 rounded-full bg-amber-500 text-white font-bold text-sm shadow-md hover:opacity-90 transition-all active:scale-95"
          >
            Approve
          </button>

          <div className="w-[1px] h-6 bg-black/10 mx-2"></div>

          <button
            type="button"
            onClick={() => toast.info('Notification center will open here.')}
            className="w-10 h-10 flex items-center justify-center text-slate-400 hover:text-slate-600"
          >
            <Bell className="w-5 h-5" />
          </button>
          <button
            type="button"
            onClick={() => toast.info('Review settings panel is coming soon.')}
            className="w-10 h-10 flex items-center justify-center text-slate-400 hover:text-slate-600"
          >
            <Settings className="w-5 h-5" />
          </button>
        </div>
      </header>

      {/* Scrollable Content */}
      <div className="pt-[88px] px-8 max-w-6xl mx-auto">
        {/* Flag Notification Banner */}
        <div className="mb-8 p-4 rounded-2xl bg-red-50 border border-red-100 flex items-start gap-4">
          <div className="w-10 h-10 rounded-full bg-red-600 flex items-center justify-center shrink-0">
            <AlertTriangle className="text-white w-5 h-5" />
          </div>
          <div className="flex-1">
            <h3 className="text-red-700 font-bold text-lg leading-tight">
              Safety Concern Flagged
            </h3>
            <p className="text-red-600/80 text-sm mt-1">
              This event was automatically flagged by the system and reported by 3 users
              for potential safety policy violations in the event description.
            </p>
          </div>
          <div className="px-3 py-1 bg-red-100 text-red-700 text-[10px] font-black uppercase tracking-widest rounded-full">
            High Priority
          </div>
        </div>

        {/* Bento Grid Layout */}
        <div className="grid grid-cols-12 gap-6">
          {/* Hero Section: Full Event Banner (8 Cols) */}
          <div className="col-span-12 lg:col-span-8 space-y-6">
            <div className="relative aspect-[21/9] rounded-[32px] overflow-hidden shadow-xl group">
              <Image
                src="https://lh3.googleusercontent.com/aida-public/AB6AXuAs4b_L9QgWf1XDH0qx4gM5_00TpPdC1Klew3A-z8zhcyac4mFYrzPpnVWxU2hh9IC3TqNhMnqkeRO-e-jKUu39WMa5GbbZDljjvyUb3JfhqPLtf8yAEeHSZlpem6qFS2vbRJpc2SFZHQgc2vtnlhdWh70dYdQHT9eAMFasMPLfvTA3y5iKFWKrAqQBXbha-ttNDKcLlJVCY0LJVK3zlB8EAEUs-5gab1dWrWcMQ8Jk7Kuk-kTB3ag13oVHmucQgBEKGgNaPn4ipyg"
                alt="Event Banner"
                fill
                sizes="(min-width: 1024px) 66vw, 100vw"
                className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-700"
              />
              <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent"></div>
              <div className="absolute bottom-8 left-8 right-8 text-white">
                <div className="flex gap-2 mb-3">
                  <span className="px-3 py-1 bg-amber-500 text-black text-[10px] font-black uppercase tracking-widest rounded-full">
                    Music
                  </span>
                  <span className="px-3 py-1 bg-white/20 backdrop-blur-md text-white text-[10px] font-black uppercase tracking-widest rounded-full">
                    18+ Only
                  </span>
                </div>
                <h1 className="text-4xl font-black tracking-tight leading-none mb-2">
                  Midnight Echoes: Underground Rave
                </h1>
                <p className="text-white/80 font-medium">
                  By Crimson Records Collective
                </p>
              </div>
            </div>

            {/* Description Section */}
            <div className="bg-white/50 backdrop-blur-xl rounded-[32px] p-8 border border-white/40 shadow-sm">
              <h4 className="text-sm font-bold uppercase tracking-widest text-slate-400 mb-6">
                Event Description
              </h4>
              <div className="space-y-4 text-slate-700 leading-relaxed">
                <p>
                  Experience the raw energy of underground techno in an immersive
                  industrial setting. Midnight Echoes returns for a one-night-only
                  special featuring extended sets from international DJs and a custom
                  sound system designed to vibrate the soul.
                </p>
                <div className="bg-red-50 p-4 rounded-xl border-l-4 border-red-500 italic text-red-700">
                  <p>
                    &quot;Warning: This event features high-intensity strobes and a &apos;No-Rules&apos;
                    policy for those seeking the ultimate freedom in the shadows.&quot;
                  </p>
                  <span className="block text-[10px] font-bold mt-2 not-italic text-red-600">
                    — FLAGGED SECTION
                  </span>
                </div>
                <p>
                  Doors open at 11:00 PM. Strictly no photography or video allowed inside
                  the main hall to maintain the privacy and atmosphere of the sanctuary.
                </p>
              </div>
            </div>
          </div>

          {/* Details & Stats (4 Cols) */}
          <div className="col-span-12 lg:col-span-4 space-y-6">
            {/* Quick Info */}
            <div className="bg-white/80 backdrop-blur-xl rounded-[32px] p-6 border border-white/40 shadow-sm space-y-6">
              <div>
                <h4 className="text-[10px] font-bold uppercase tracking-widest text-slate-400 mb-3">
                  Location
                </h4>
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-xl bg-slate-100 flex items-center justify-center">
                    <MapPin className="text-slate-600 w-5 h-5" />
                  </div>
                  <div>
                    <p className="font-bold text-slate-900">UTC2 Room</p>
                    <p className="text-sm text-slate-500">
                      Industrial District, Sector 4
                    </p>
                  </div>
                </div>
              </div>

              <div>
                <h4 className="text-[10px] font-bold uppercase tracking-widest text-slate-400 mb-3">
                  Date & Time
                </h4>
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-xl bg-slate-100 flex items-center justify-center">
                    <Calendar className="text-slate-600 w-5 h-5" />
                  </div>
                  <div>
                    <p className="font-bold text-slate-900">Oct 24, 2024</p>
                    <p className="text-sm text-slate-500">23:00 - 06:00 UTC</p>
                  </div>
                </div>
              </div>

              <div>
                <h4 className="text-[10px] font-bold uppercase tracking-widest text-slate-400 mb-3">
                  Estimated Capacity
                </h4>
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-xl bg-slate-100 flex items-center justify-center">
                    <Users className="text-slate-600 w-5 h-5" />
                  </div>
                  <div>
                    <p className="font-bold text-slate-900">1,200 Attendees</p>
                    <p className="text-sm text-slate-500">840 Tickets Sold</p>
                  </div>
                </div>
              </div>
            </div>

            {/* Organizer Profile */}
            <div className="bg-white/80 backdrop-blur-xl rounded-[32px] p-6 border border-white/40 shadow-sm">
              <h4 className="text-[10px] font-bold uppercase tracking-widest text-slate-400 mb-4">
                Organizer Account
              </h4>
              <div className="flex items-center gap-4 mb-4">
                <div className="relative w-12 h-12 rounded-full overflow-hidden border-2 border-amber-500">
                  <Image
                    src="https://lh3.googleusercontent.com/aida-public/AB6AXuAlemM4TN8HkVmWnlmJ0gV4AN3-psUFHmePxiA8y29GPJKViVdo1AjprMXDFLSD_eW4jAi_tVrZCleLri1d9D4mNB8Q6o1DlkACCPPWSCjOPZ-8L3OiGgs2rMWqW7kTYLu_fv1Kd_0iKSAanV_Nre6bSuoKmoRcxVlsly4fXu2JxY5VoVahs3Z-O6rZxFcUXL-rrG4LZVzeyRqL4Dw3TnEFEfJu6hkdehKDb6Eet653Xz8i0fXMDemv3CGbIcreJWxpLgbShurH43g"
                    alt="Organizer Profile"
                    fill
                    sizes="48px"
                    className="w-full h-full object-cover"
                  />
                </div>
                <div>
                  <p className="font-bold text-slate-900">Crimson Collective</p>
                  <p className="text-xs text-slate-500">
                    Member since 2021 • 14 Events
                  </p>
                </div>
              </div>

              <div className="grid grid-cols-2 gap-2">
                <div className="p-3 bg-slate-50 rounded-2xl text-center">
                  <p className="text-lg font-bold text-slate-900">4.8</p>
                  <p className="text-[10px] uppercase text-slate-400 font-bold">
                    Rating
                  </p>
                </div>
                <div className="p-3 bg-slate-50 rounded-2xl text-center">
                  <p className="text-lg font-bold text-slate-900">0</p>
                  <p className="text-[10px] uppercase text-slate-400 font-bold">
                    Strikes
                  </p>
                </div>
              </div>
            </div>

            {/* Moderation Map */}
            <div className="relative rounded-[32px] overflow-hidden h-48 shadow-sm border border-white/40">
              <Image
                src="https://lh3.googleusercontent.com/aida-public/AB6AXuDK9BC1VKJFizyN0fihG055vITF5cI67w4CW6Rg3eY_e1xMCpd27UoEw37osGUiq5DCfHsejc3QqFCJm1ZnWAyjtxRFTKR5OXoUSJkQygkXsmousliSpJCcx9R8ul2JX0SyXvGr8_hiVNxnWfOzLMy1IdAzCFAaX-AF61aJBjHD2-T6MxNNCEa0UBb8l2KRW13GOmY8dRsyW6dkd372fqUwVo5c81mZlnmkiJk7Qm48_i1bv_FK5U7fDu8pnwA3C0GVbwHWq4VTWS0"
                alt="Map"
                fill
                sizes="(min-width: 1024px) 30vw, 100vw"
                className="w-full h-full object-cover grayscale brightness-90 contrast-125"
              />
            </div>
          </div>
        </div>

        {/* Action Footer */}
        <div className="mt-12 pt-8 border-t border-slate-200 flex justify-between items-center">
          <div className="flex gap-4">
            <button
              type="button"
              onClick={() => toast.info('Revision request sent to organizer.')}
              className="flex items-center gap-2 text-slate-500 hover:text-slate-900 font-medium transition-colors"
            >
              <Flag className="w-5 h-5" />
              Request Revision
            </button>
            <button
              type="button"
              onClick={() => toast.info('Audit log viewer is coming soon.')}
              className="flex items-center gap-2 text-slate-500 hover:text-slate-900 font-medium transition-colors"
            >
              <History className="w-5 h-5" />
              Audit Log
            </button>
          </div>
          <div className="flex gap-4">
            <Link
              href="/events"
              className="px-8 py-3 rounded-full bg-slate-200 text-slate-700 font-bold hover:bg-slate-300 transition-all text-center"
            >
              Cancel
            </Link>
            <button
              type="button"
              onClick={handleApprove}
              className="px-10 py-3 rounded-full bg-amber-500 text-white font-bold shadow-lg shadow-amber-500/20 hover:scale-105 active:scale-95 transition-all"
            >
              Confirm & Approve
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
