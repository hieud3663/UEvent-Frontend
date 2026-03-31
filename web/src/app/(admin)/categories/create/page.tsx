// File: src/app/(admin)/categories/create/page.tsx
'use client';

import Link from 'next/link';
import { useRouter } from 'next/navigation';
import {
  ChevronDown,
  Music,
  Eye,
  Info,
  Sparkles,
  BarChart2,
  PartyPopper,
  Gamepad2,
  Utensils,
  Theater,
  Brush,
  Martini,
  Film,
} from 'lucide-react';

export default function CreateCategoryPage() {
  const router = useRouter();
  return (
    <div className="min-h-screen relative p-8">
      {/* Background Decorative Elements */}
      <div className="fixed top-[-10%] right-[-5%] w-[500px] h-[500px] bg-amber-200/20 blur-[120px] rounded-full z-[-1]"></div>
      <div className="fixed bottom-[-10%] left-[10%] w-[400px] h-[400px] bg-sky-200/20 blur-[100px] rounded-full z-[-1]"></div>

      <header className="mb-8">
        <h2 className="text-xl font-bold tracking-tight text-slate-900">
          Create New Category
        </h2>
      </header>

      {/* Form Content */}
      <div className="max-w-4xl mx-auto">
        <div className="glass-panel border border-white/40 rounded-[24px] shadow-[0_8px_32px_rgba(0,0,0,0.04)] overflow-hidden">
          {/* Header of the Modal Section */}
          <div className="px-8 py-6 border-b border-black/5 bg-white/40">
            <h3 className="text-xl font-bold text-slate-900">Category Details</h3>
            <p className="text-sm text-slate-500 mt-1">
              Define the properties for the new event grouping.
            </p>
          </div>

          {/* Form Fields */}
          <div className="p-8 space-y-8">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
              {/* Category Name */}
              <div className="space-y-2">
                <label className="block text-[10px] font-bold uppercase tracking-wider text-slate-400">
                  Category Name
                </label>
                <input
                  type="text"
                  placeholder="e.g. Music & Festivals"
                  className="w-full bg-white/50 border border-slate-200 focus:border-amber-500 focus:ring-2 focus:ring-amber-500/20 rounded-xl px-4 py-3 text-sm transition-all outline-none"
                />
              </div>

              {/* Category Icon */}
              <div className="space-y-2">
                <label className="block text-[10px] font-bold uppercase tracking-wider text-slate-400">
                  Category Icon
                </label>
                <div className="relative group flex items-center bg-white/50 border border-slate-200 rounded-xl px-4 py-3 cursor-pointer group-hover:border-amber-300 transition-colors">
                  <Music className="text-amber-500 mr-3 w-5 h-5" />
                  <span className="text-sm text-slate-700 flex-1">Music Note</span>
                  <ChevronDown className="text-slate-400 w-5 h-5" />
                </div>
              </div>
            </div>

            {/* Description */}
            <div className="space-y-2">
              <label className="block text-[10px] font-bold uppercase tracking-wider text-slate-400">
                Description
              </label>
              <textarea
                placeholder="Describe what events fall under this category..."
                rows={4}
                className="w-full bg-white/50 border border-slate-200 focus:border-amber-500 focus:ring-2 focus:ring-amber-500/20 rounded-xl px-4 py-3 text-sm transition-all outline-none resize-none"
              ></textarea>
            </div>

            {/* Visibility & Meta */}
            <div className="flex flex-col md:flex-row items-center justify-between gap-6 p-6 bg-amber-50/50 rounded-2xl border border-amber-100/50">
              <div className="flex items-center gap-4">
                <div className="w-12 h-12 rounded-full bg-amber-500/10 flex items-center justify-center">
                  <Eye className="text-amber-500 w-6 h-6" />
                </div>
                <div>
                  <h4 className="text-sm font-bold text-slate-900">Visibility Status</h4>
                  <p className="text-xs text-slate-500">
                    Decide if this category is visible to public users.
                  </p>
                </div>
              </div>
              <div className="flex bg-white/80 p-1.5 rounded-full border border-slate-200 shadow-sm">
                <button className="px-6 py-2 text-xs font-bold rounded-full bg-amber-500 text-white shadow-md">
                  Active
                </button>
                <button className="px-6 py-2 text-xs font-bold rounded-full text-slate-400 hover:text-slate-600">
                  Inactive
                </button>
              </div>
            </div>

            {/* Icon Preview Grid (Decorative Visual Element) */}
            <div className="space-y-4">
              <p className="text-[10px] font-bold uppercase tracking-wider text-slate-400">
                Suggested Icons
              </p>
              <div className="grid grid-cols-6 sm:grid-cols-8 md:grid-cols-10 gap-3">
                <div className="aspect-square flex items-center justify-center bg-white/50 border border-slate-100 rounded-lg hover:border-amber-500 cursor-pointer transition-colors">
                  <PartyPopper className="text-slate-500 w-5 h-5" />
                </div>
                <div className="aspect-square flex items-center justify-center bg-white/50 border border-slate-100 rounded-lg hover:border-amber-500 cursor-pointer transition-colors">
                  <Gamepad2 className="text-slate-500 w-5 h-5" />
                </div>
                <div className="aspect-square flex items-center justify-center bg-amber-500/10 border border-amber-500 rounded-lg cursor-pointer">
                  <Music className="text-amber-500 w-5 h-5" />
                </div>
                <div className="aspect-square flex items-center justify-center bg-white/50 border border-slate-100 rounded-lg hover:border-amber-500 cursor-pointer transition-colors">
                  <Utensils className="text-slate-500 w-5 h-5" />
                </div>
                <div className="aspect-square flex items-center justify-center bg-white/50 border border-slate-100 rounded-lg hover:border-amber-500 cursor-pointer transition-colors">
                  <Theater className="text-slate-500 w-5 h-5" />
                </div>
                <div className="aspect-square flex items-center justify-center bg-white/50 border border-slate-100 rounded-lg hover:border-amber-500 cursor-pointer transition-colors">
                  <Brush className="text-slate-500 w-5 h-5" />
                </div>
                <div className="aspect-square flex items-center justify-center bg-white/50 border border-slate-100 rounded-lg hover:border-amber-500 cursor-pointer transition-colors">
                  <Martini className="text-slate-500 w-5 h-5" />
                </div>
                <div className="aspect-square flex items-center justify-center bg-white/50 border border-slate-100 rounded-lg hover:border-amber-500 cursor-pointer transition-colors">
                  <Film className="text-slate-500 w-5 h-5" />
                </div>
              </div>
            </div>
          </div>

          {/* Footer Actions */}
          <div className="px-8 py-6 bg-slate-50/50 border-t border-black/5 flex items-center justify-end gap-4">
            <Link
              href="/categories"
              className="px-6 py-2.5 text-sm font-bold text-slate-500 hover:text-slate-800 transition-colors"
            >
              Cancel
            </Link>
            <button 
              type="button"
              onClick={() => {
                alert('Category created successfully!');
                router.push('/categories');
              }}
              className="px-8 py-2.5 text-sm font-bold bg-amber-500 text-white rounded-xl shadow-[0_4px_12px_rgba(255,184,0,0.3)] hover:brightness-105 active:scale-95 transition-all"
            >
              Create Category
            </button>
          </div>
        </div>

        {/* Contextual Information Card */}
        <div className="mt-8 grid grid-cols-1 md:grid-cols-3 gap-6">
          <div className="p-5 glass-panel rounded-2xl border border-white/40 flex items-start gap-4">
            <div className="text-amber-500">
              <Info className="w-5 h-5" />
            </div>
            <div>
              <p className="text-xs font-bold text-slate-900 mb-1">Impact Preview</p>
              <p className="text-[11px] text-slate-500 leading-relaxed">
                This category will immediately appear in the user-facing app filtering
                menu.
              </p>
            </div>
          </div>
          <div className="p-5 glass-panel rounded-2xl border border-white/40 flex items-start gap-4">
            <div className="text-amber-500">
              <Sparkles className="w-5 h-5" />
            </div>
            <div>
              <p className="text-xs font-bold text-slate-900 mb-1">AI Suggestion</p>
              <p className="text-[11px] text-slate-500 leading-relaxed">
                Consider adding sub-tags like &quot;Indoor&quot; or &quot;Nightlife&quot; for better
                discovery.
              </p>
            </div>
          </div>
          <div className="p-5 glass-panel rounded-2xl border border-white/40 flex items-start gap-4">
            <div className="text-amber-500">
              <BarChart2 className="w-5 h-5" />
            </div>
            <div>
              <p className="text-xs font-bold text-slate-900 mb-1">Expected Reach</p>
              <p className="text-[11px] text-slate-500 leading-relaxed">
                Category mapping affects approximately 450+ existing events.
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
