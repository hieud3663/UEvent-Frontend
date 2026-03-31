// File: src/app/(admin)/notifications/create/page.tsx
'use client';

import { useState } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import {
  ChevronRight,
  Send,
  Clock,
  Eye,
  History,
  Sparkles,
  Bold,
  Italic,
  Link as LinkIcon,
  Smile,
  RocketIcon,
  ChevronDown,
  Wifi,
  Battery,
  Signal,
  Star,
} from 'lucide-react';

type ScheduleType = 'now' | 'later';

export default function CreateNotificationPage() {
  const router = useRouter();
  const [title, setTitle] = useState('');
  const [audience, setAudience] = useState('all');
  const [deliveryMethods, setDeliveryMethods] = useState({
    push: true,
    email: false,
    inbox: true,
  });
  const [message, setMessage] = useState('');
  const [scheduleType, setScheduleType] = useState<ScheduleType>('now');
  const [scheduleDate, setScheduleDate] = useState('');
  const [scheduleTime, setScheduleTime] = useState('');

  const toggleDeliveryMethod = (method: keyof typeof deliveryMethods) => {
    setDeliveryMethods((prev) => ({ ...prev, [method]: !prev[method] }));
  };

  return (
    <>
      {/* Breadcrumbs & Title Section */}
      <div className="px-10 pt-8 pb-4">
        <nav className="flex items-center gap-2 text-[10px] font-bold uppercase tracking-widest text-slate-400 mb-2">
          <Link href="/notifications" className="hover:text-[#FFB800] transition-colors">
            Notifications
          </Link>
          <ChevronRight className="w-3 h-3" />
          <span className="text-slate-600">Create New</span>
        </nav>
        <h2 className="text-3xl font-black text-slate-900 tracking-tight">
          Create New Notification
        </h2>
      </div>

      {/* Form Canvas */}
      <div className="px-10 pb-20 flex-1">
        <div className="max-w-4xl mx-auto">
          <div className="glass-panel rounded-[32px] p-10 shadow-xl relative overflow-hidden">
            {/* Subtle Decorative Background Glow */}
            <div className="absolute -top-20 -right-20 w-64 h-64 bg-[#FFB800]/5 rounded-full blur-3xl"></div>
            <div className="absolute -bottom-20 -left-20 w-64 h-64 bg-primary-container/5 rounded-full blur-3xl"></div>

            <form className="space-y-8 relative z-10">
              {/* Notification Title */}
              <div className="space-y-2">
                <label className="text-[10px] font-bold uppercase tracking-[0.1em] text-slate-500 ml-1">
                  Notification Title
                </label>
                <input
                  type="text"
                  value={title}
                  onChange={(e) => setTitle(e.target.value)}
                  className="w-full bg-white/50 border-0 border-b-2 border-slate-100 focus:border-[#FFB800] focus:ring-0 text-lg font-medium py-3 px-2 transition-all placeholder:text-slate-300"
                  placeholder="Enter a compelling title..."
                />
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                {/* Target Audience */}
                <div className="space-y-2">
                  <label className="text-[10px] font-bold uppercase tracking-[0.1em] text-slate-500 ml-1">
                    Target Audience
                  </label>
                  <div className="relative">
                    <select
                      value={audience}
                      onChange={(e) => setAudience(e.target.value)}
                      className="w-full appearance-none bg-white/60 border border-slate-200 rounded-2xl py-3.5 px-4 text-sm focus:ring-2 focus:ring-[#FFB800]/20 focus:border-[#FFB800] outline-none transition-all cursor-pointer"
                    >
                      <option value="all">All Users</option>
                      <option value="students">Students</option>
                      <option value="organizers">Organizers</option>
                      <option value="specific">Specific Event</option>
                    </select>
                    <ChevronDown className="absolute right-4 top-1/2 -translate-y-1/2 pointer-events-none text-slate-400 w-5 h-5" />
                  </div>
                </div>

                {/* Delivery Method */}
                <div className="space-y-2">
                  <label className="text-[10px] font-bold uppercase tracking-[0.1em] text-slate-500 ml-1">
                    Delivery Method
                  </label>
                  <div className="flex flex-wrap gap-3">
                    <label className="flex items-center gap-2 bg-white/60 border border-slate-200 rounded-xl px-4 py-3 cursor-pointer hover:bg-white transition-all">
                      <input
                        type="checkbox"
                        checked={deliveryMethods.push}
                        onChange={() => toggleDeliveryMethod('push')}
                        className="w-4 h-4 rounded text-[#FFB800] focus:ring-[#FFB800] border-slate-300"
                      />
                      <span className="text-xs font-semibold text-slate-600">Push</span>
                    </label>
                    <label className="flex items-center gap-2 bg-white/60 border border-slate-200 rounded-xl px-4 py-3 cursor-pointer hover:bg-white transition-all">
                      <input
                        type="checkbox"
                        checked={deliveryMethods.email}
                        onChange={() => toggleDeliveryMethod('email')}
                        className="w-4 h-4 rounded text-[#FFB800] focus:ring-[#FFB800] border-slate-300"
                      />
                      <span className="text-xs font-semibold text-slate-600">Email</span>
                    </label>
                    <label className="flex items-center gap-2 bg-white/60 border border-slate-200 rounded-xl px-4 py-3 cursor-pointer hover:bg-white transition-all">
                      <input
                        type="checkbox"
                        checked={deliveryMethods.inbox}
                        onChange={() => toggleDeliveryMethod('inbox')}
                        className="w-4 h-4 rounded text-[#FFB800] focus:ring-[#FFB800] border-slate-300"
                      />
                      <span className="text-xs font-semibold text-slate-600">App Inbox</span>
                    </label>
                  </div>
                </div>
              </div>

              {/* Message Body */}
              <div className="space-y-2">
                <label className="text-[10px] font-bold uppercase tracking-[0.1em] text-slate-500 ml-1">
                  Message Body
                </label>
                <div className="bg-white/60 border border-slate-200 rounded-3xl overflow-hidden focus-within:border-[#FFB800] transition-all">
                  <div className="bg-slate-50/80 px-4 py-2 border-b border-slate-100 flex gap-4">
                    <button
                      type="button"
                      className="text-slate-400 hover:text-slate-900 transition-colors"
                    >
                      <Bold className="w-[18px] h-[18px]" />
                    </button>
                    <button
                      type="button"
                      className="text-slate-400 hover:text-slate-900 transition-colors"
                    >
                      <Italic className="w-[18px] h-[18px]" />
                    </button>
                    <button
                      type="button"
                      className="text-slate-400 hover:text-slate-900 transition-colors"
                    >
                      <LinkIcon className="w-[18px] h-[18px]" />
                    </button>
                    <button
                      type="button"
                      className="text-slate-400 hover:text-slate-900 transition-colors ml-auto"
                    >
                      <Smile className="w-[18px] h-[18px]" />
                    </button>
                  </div>
                  <textarea
                    value={message}
                    onChange={(e) => setMessage(e.target.value)}
                    className="w-full bg-transparent border-none focus:ring-0 p-6 text-sm resize-none placeholder:text-slate-300"
                    placeholder="Write your notification message here..."
                    rows={6}
                  />
                </div>
              </div>

              {/* Scheduling */}
              <div className="space-y-4">
                <label className="text-[10px] font-bold uppercase tracking-[0.1em] text-slate-500 ml-1">
                  Scheduling
                </label>
                <div className="flex gap-4">
                  <label
                    className="flex-1 flex items-center justify-between p-4 bg-white/60 border border-slate-200 rounded-2xl cursor-pointer group hover:bg-white transition-all"
                  >
                    <div className="flex items-center gap-3">
                      <div className="p-2 bg-slate-100 rounded-lg text-slate-500">
                        <Send className="w-[18px] h-[18px]" />
                      </div>
                      <div>
                        <p className="text-sm font-bold text-slate-900">Send Now</p>
                        <p className="text-[10px] text-slate-400">Immediate delivery to all</p>
                      </div>
                    </div>
                    <input
                      type="radio"
                      name="scheduling"
                      value="now"
                      checked={scheduleType === 'now'}
                      onChange={() => setScheduleType('now')}
                      className="w-5 h-5 text-[#FFB800] focus:ring-[#FFB800] border-slate-300"
                    />
                  </label>
                  <label
                    className="flex-1 flex items-center justify-between p-4 bg-white/60 border border-slate-200 rounded-2xl cursor-pointer group hover:bg-white transition-all"
                  >
                    <div className="flex items-center gap-3">
                      <div className="p-2 bg-slate-100 rounded-lg text-slate-500">
                        <Clock className="w-[18px] h-[18px]" />
                      </div>
                      <div>
                        <p className="text-sm font-bold text-slate-900">Schedule for Later</p>
                        <p className="text-[10px] text-slate-400">Select date and time</p>
                      </div>
                    </div>
                    <input
                      type="radio"
                      name="scheduling"
                      value="later"
                      checked={scheduleType === 'later'}
                      onChange={() => setScheduleType('later')}
                      className="w-5 h-5 text-[#FFB800] focus:ring-[#FFB800] border-slate-300"
                    />
                  </label>
                </div>

                {/* Contextual Date Picker (Shown on Schedule) */}
                {scheduleType === 'later' && (
                  <div className="flex gap-4 p-4 bg-slate-50/50 rounded-2xl border border-dashed border-slate-200">
                    <div className="flex-1">
                      <input
                        type="date"
                        value={scheduleDate}
                        onChange={(e) => setScheduleDate(e.target.value)}
                        className="w-full bg-white border border-slate-200 rounded-xl px-4 py-2 text-sm focus:ring-2 focus:ring-[#FFB800]/20 outline-none"
                      />
                    </div>
                    <div className="flex-1">
                      <input
                        type="time"
                        value={scheduleTime}
                        onChange={(e) => setScheduleTime(e.target.value)}
                        className="w-full bg-white border border-slate-200 rounded-xl px-4 py-2 text-sm focus:ring-2 focus:ring-[#FFB800]/20 outline-none"
                      />
                    </div>
                  </div>
                )}
              </div>

              {/* Actions */}
              <div className="pt-6 flex items-center justify-between gap-4 border-t border-slate-100">
                <button
                  type="button"
                  onClick={() => alert('Draft saved successfully!')}
                  className="px-8 py-3.5 rounded-2xl border border-slate-200 bg-white/50 text-slate-600 font-bold text-sm hover:bg-white transition-all active:scale-95"
                >
                  Save Draft
                </button>
                <div className="flex items-center gap-4">
                  <button
                    type="button"
                    onClick={() => router.back()}
                    className="text-slate-400 text-xs font-semibold hover:text-slate-600 transition-colors"
                  >
                    Discard changes
                  </button>
                  <button
                    type="button"
                    onClick={() => {
                      alert('Notification sent successfully!');
                      router.push('/notifications');
                    }}
                    className="px-10 py-3.5 bg-[#FFB800] text-white rounded-2xl font-black text-sm shadow-xl shadow-[#FFB800]/30 hover:saturate-150 hover:scale-[1.02] active:scale-95 transition-all flex items-center gap-2"
                  >
                    <span>Send Notification</span>
                    <RocketIcon className="w-[18px] h-[18px]" />
                  </button>
                </div>
              </div>
            </form>
          </div>

          {/* Preview Card */}
          <div className="mt-8">
            <div className="flex items-center justify-between mb-4">
              <h4 className="text-[10px] font-black uppercase tracking-[0.2em] text-slate-400">
                Quick Preview
              </h4>
              <span className="text-[10px] text-slate-400 font-medium">Device: iPhone 15 Pro</span>
            </div>
            <div className="max-w-sm mx-auto glass-panel rounded-[2.5rem] p-4 border-8 border-slate-900 shadow-2xl aspect-[9/19] flex flex-col items-center justify-start overflow-hidden relative">
              {/* Screen Header */}
              <div className="w-full flex justify-between px-6 pt-2 mb-8">
                <span className="text-[10px] font-bold">9:41</span>
                <div className="flex gap-1 items-center">
                  <Signal className="w-[10px] h-[10px]" />
                  <Wifi className="w-[10px] h-[10px]" />
                  <Battery className="w-[10px] h-[10px]" />
                </div>
              </div>

              {/* Notification Toast */}
              <div className="w-full bg-white/90 backdrop-blur-md rounded-3xl p-4 shadow-lg border border-white/50 animate-pulse">
                <div className="flex items-center gap-2 mb-2">
                  <div className="w-5 h-5 bg-[#FFB800] rounded-md flex items-center justify-center">
                    <Star className="w-[12px] h-[12px] text-white fill-white" />
                  </div>
                  <span className="text-[10px] font-bold text-slate-400">AMBER EVENTS • NOW</span>
                </div>
                <h5 className="text-xs font-bold text-slate-900 mb-0.5">
                  {title || 'Notification Title Appears Here'}
                </h5>
                <p className="text-[10px] text-slate-500 leading-relaxed">
                  {message || 'The content of your message will be displayed like this on user lock screens...'}
                </p>
              </div>

              {/* Background Image */}
              <div className="absolute inset-0 -z-10">
                <div className="w-full h-full bg-slate-900 overflow-hidden">
                  <div className="absolute inset-0 bg-gradient-to-br from-indigo-500/30 to-purple-600/30"></div>
                  <div className="w-full h-full bg-gradient-to-br from-indigo-600 via-purple-600 to-pink-500 opacity-50"></div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Bottom Action Bar (Contextual) */}
      <div className="fixed bottom-8 left-1/2 -translate-x-1/2 z-50 flex items-center gap-2 px-2 py-2 glass-panel rounded-full shadow-2xl border border-white/40">
        <div className="flex items-center gap-1">
          <button
            type="button"
            className="p-3 text-slate-400 hover:text-[#FFB800] transition-colors rounded-full hover:bg-white/50"
          >
            <Eye className="w-5 h-5" />
          </button>
          <button
            type="button"
            className="p-3 text-slate-400 hover:text-[#FFB800] transition-colors rounded-full hover:bg-white/50"
          >
            <History className="w-5 h-5" />
          </button>
        </div>
        <div className="h-6 w-[1px] bg-slate-200 mx-1"></div>
        <button
          type="button"
          className="bg-[#FFB800] text-white px-6 py-2.5 rounded-full font-bold text-xs flex items-center gap-2 hover:saturate-150 transition-all active:scale-95 shadow-lg shadow-[#FFB800]/20"
        >
          <Sparkles className="w-4 h-4" />
          AI Optimizer
        </button>
      </div>
    </>
  );
}
