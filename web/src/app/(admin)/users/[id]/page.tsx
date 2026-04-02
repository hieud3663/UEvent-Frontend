// File: src/app/(admin)/users/[id]/page.tsx
'use client';

import Image from 'next/image';
import Link from 'next/link';
import { useParams, useRouter } from 'next/navigation';
import { ChevronRight, Camera, Mail, Lock, Settings } from 'lucide-react';
import { toast } from 'sonner';

export default function EditUserPage() {
  const params = useParams();
  const router = useRouter();
  const userId = params.id as string;
  const roleOptions = [
    { value: 'Student', label: 'Student' },
    { value: 'Organizer', label: 'Organizer' },
    { value: 'Faculty Admin', label: 'Faculty Admin' },
  ] as const;

  return (
    <div className="min-h-screen px-10 pb-20">
      <header className="mb-10 flex justify-between items-end">
        <div>
          <nav className="flex items-center gap-2 text-xs font-bold uppercase tracking-widest text-slate-400 mb-2">
            <Link href="/users" className="hover:text-amber-500">
              Users
            </Link>
            <ChevronRight className="w-3.5 h-3.5" />
            <span className="text-slate-600">Edit User Details</span>
          </nav>

          <h1 className="text-4xl font-extrabold tracking-tight text-slate-900">
            Modify Account
          </h1>
          <p className="text-slate-500 mt-2 font-medium">
            Update profile information and system access for{' '}
            <span className="text-amber-600 font-bold">Lê Văn Hùng</span>
          </p>
        </div>
        <div className="flex gap-3">
          <Link
            href="/users"
            className="px-6 py-2.5 glass-panel rounded-xl text-sm font-bold text-slate-600 hover:bg-white transition-all active:scale-95 border border-white/40 shadow-sm"
          >
            Discard Changes
          </Link>
          <button 
            type="button"
            onClick={() => {
              toast.success('Profile updated successfully.');
              router.push('/users');
            }}
            className="px-8 py-2.5 bg-amber-500 text-white rounded-xl text-sm font-bold shadow-lg shadow-amber-500/30 hover:saturate-150 transition-all active:scale-95"
          >
            Update Profile
          </button>
        </div>
      </header>

      {/* Bento Grid Form Layout */}
      <div className="grid grid-cols-12 gap-6">
        {/* Profile Overview (Small Card) */}
        <div className="col-span-12 lg:col-span-4 space-y-6">
          <div className="glass-panel rounded-[32px] p-8 flex flex-col items-center text-center shadow-[0_8px_32px_rgba(0,0,0,0.04)] border border-white/40">
            <div className="relative mb-6">
              <div className="relative h-32 w-32 rounded-full overflow-hidden border-4 border-white shadow-xl">
                <Image
                  src="https://lh3.googleusercontent.com/aida-public/AB6AXuDUVO4FhOeA38_fsKHgnSsdGBGwdx8JcsW9-W-PbiS-o32YlyO-IXMLyrAp_cwYujLn6JLqtKsXb0gGEon0QBYysA0eVLkt2j5N67ak-E8Jp8F8c4oyY7WOQjiS6yPxiDuUkdbSsJny8xgOyXCFXCR0zscZeMDQyK1TKC42jxcGu8S46SKz8F5E7EVSa4IKnXhHAShblhNqqmQiT5fvCCRriYnyoPA1LTU45X8pxzmetmQ-N9TLzchBqGCO0Ar-6sXN5GfKVlO4ej8"
                  alt="User avatar"
                  fill
                  sizes="128px"
                  className="w-full h-full object-cover"
                />
              </div>
              <button
                type="button"
                onClick={() => toast.info('Avatar upload flow will open here.')}
                className="absolute bottom-1 right-1 h-10 w-10 bg-amber-500 text-white rounded-full flex items-center justify-center border-4 border-white shadow-lg transition-transform hover:scale-110 active:scale-90"
              >
                <Camera className="w-5 h-5" />
              </button>
            </div>
            <h2 className="text-xl font-bold text-slate-900">Lê Văn Hùng</h2>
            <p className="text-slate-500 text-sm font-medium">
              Student • CS Class 2024-A
            </p>

            <div className="mt-8 pt-8 border-t border-slate-200/50 w-full flex justify-around">
              <div>
                <p className="text-[10px] font-bold uppercase tracking-widest text-slate-400">
                  Activity
                </p>
                <p className="text-lg font-bold text-slate-900">High</p>
              </div>
              <div>
                <p className="text-[10px] font-bold uppercase tracking-widest text-slate-400">
                  Status
                </p>
                <div className="flex items-center gap-1.5 justify-center mt-1">
                  <span className="h-2 w-2 rounded-full bg-emerald-500"></span>
                  <span className="text-sm font-bold text-emerald-600">Active</span>
                </div>
              </div>
            </div>
          </div>

          <div className="glass-panel rounded-[32px] p-6 shadow-[0_8px_32px_rgba(0,0,0,0.04)] border border-white/40">
            <h3 className="text-sm font-bold uppercase tracking-widest text-slate-400 mb-4">
              Quick Actions
            </h3>
            <div className="grid grid-cols-2 gap-3">
              <button
                type="button"
                onClick={() => toast.success('Password reset email has been queued.')}
                className="p-4 bg-slate-100/50 rounded-2xl flex flex-col items-center gap-2 hover:bg-amber-50 transition-colors group"
              >
                <Lock className="w-6 h-6 text-slate-400 group-hover:text-amber-600" />
                <span className="text-xs font-bold text-slate-600">Reset Pass</span>
              </button>
              <button
                type="button"
                onClick={() => toast.success('Account notice sent to user inbox.')}
                className="p-4 bg-slate-100/50 rounded-2xl flex flex-col items-center gap-2 hover:bg-amber-50 transition-colors group"
              >
                <Mail className="w-6 h-6 text-slate-400 group-hover:text-amber-600" />
                <span className="text-xs font-bold text-slate-600">Send Notice</span>
              </button>
            </div>
          </div>
        </div>

        {/* Detailed Info Form (Large Card) */}
        <div className="col-span-12 lg:col-span-8">
          <div className="glass-panel rounded-[32px] p-10 shadow-[0_8px_32px_rgba(0,0,0,0.04)] border border-white/40">
            <div className="flex items-center gap-3 mb-8">
              <div className="h-8 w-1 bg-amber-500 rounded-full"></div>
              <h2 className="text-2xl font-bold text-slate-900">Personal Information</h2>
            </div>

            <form className="space-y-8" onSubmit={(e) => e.preventDefault()}>
              {/* Name & Email Row */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div className="space-y-2">
                  <label className="text-xs font-bold uppercase tracking-widest text-slate-500 ml-1">
                    Full Name
                  </label>
                  <input
                    type="text"
                    defaultValue="Lê Văn Hùng"
                    className="w-full bg-slate-200/30 border-none rounded-2xl px-5 py-4 text-slate-900 font-medium focus:ring-2 focus:ring-amber-500 focus:bg-white transition-all outline-none"
                  />
                </div>
                <div className="space-y-2">
                  <label className="text-xs font-bold uppercase tracking-widest text-slate-500 ml-1">
                    Email Address
                  </label>
                  <input
                    type="email"
                    defaultValue="hung.lv2024@university.edu.vn"
                    className="w-full bg-slate-200/30 border-none rounded-2xl px-5 py-4 text-slate-900 font-medium focus:ring-2 focus:ring-amber-500 focus:bg-white transition-all outline-none"
                  />
                </div>
              </div>

              {/* Academic Details Row */}
              <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                <div className="space-y-2">
                  <label className="text-xs font-bold uppercase tracking-widest text-slate-500 ml-1">
                    Student ID (MSSV)
                  </label>
                  <div className="relative">
                    <input
                      type="text"
                      defaultValue="20245678"
                      className="w-full bg-slate-200/30 border-none rounded-2xl px-5 py-4 text-slate-900 font-medium focus:ring-2 focus:ring-amber-500 focus:bg-white transition-all outline-none"
                    />
                  </div>
                </div>
                <div className="space-y-2">
                  <label className="text-xs font-bold uppercase tracking-widest text-slate-500 ml-1">
                    Class Code
                  </label>
                  <input
                    type="text"
                    defaultValue="CS-K65-A"
                    className="w-full bg-slate-200/30 border-none rounded-2xl px-5 py-4 text-slate-900 font-medium focus:ring-2 focus:ring-amber-500 focus:bg-white transition-all outline-none"
                  />
                </div>
                <div className="space-y-2">
                  <label className="text-xs font-bold uppercase tracking-widest text-slate-500 ml-1">
                    Role Type
                  </label>
                  <select className="w-full bg-slate-200/30 border-none rounded-2xl px-5 py-4 text-slate-900 font-medium focus:ring-2 focus:ring-amber-500 focus:bg-white transition-all outline-none appearance-none">
                    {roleOptions.map((option) => (
                      <option key={option.value} value={option.value}>
                        {option.label}
                      </option>
                    ))}
                  </select>
                </div>
              </div>

              <div className="pt-4">
                <div className="flex items-center gap-3 mb-8">
                  <div className="h-8 w-1 bg-amber-500 rounded-full"></div>
                  <h2 className="text-2xl font-bold text-slate-900">System Permissions</h2>
                </div>

                <div className="space-y-4">
                  <label className="flex items-center justify-between p-4 bg-slate-100/50 rounded-2xl cursor-pointer hover:bg-amber-50 transition-colors">
                    <div className="flex items-center gap-4">
                      <div className="h-10 w-10 bg-white rounded-xl flex items-center justify-center shadow-sm">
                        <Settings className="w-5 h-5 text-amber-500" />
                      </div>
                      <div>
                        <p className="font-bold text-slate-900">Event Participation</p>
                        <p className="text-xs text-slate-500">
                          Allows the user to register for campus activities
                        </p>
                      </div>
                    </div>
                    <input
                      type="checkbox"
                      defaultChecked
                      className="w-6 h-6 rounded-lg border-slate-300 text-amber-500 focus:ring-amber-500"
                    />
                  </label>
                  
                  <label className="flex items-center justify-between p-4 bg-slate-100/50 rounded-2xl cursor-pointer hover:bg-amber-50 transition-colors">
                    <div className="flex items-center gap-4">
                      <div className="h-10 w-10 bg-white rounded-xl flex items-center justify-center shadow-sm">
                        <Settings className="w-5 h-5 text-amber-500" />
                      </div>
                      <div>
                        <p className="font-bold text-slate-900">Organization Privileges</p>
                        <p className="text-xs text-slate-500">
                          Enable tools for creating and managing events
                        </p>
                      </div>
                    </div>
                    <input
                      type="checkbox"
                      className="w-6 h-6 rounded-lg border-slate-300 text-amber-500 focus:ring-amber-500"
                    />
                  </label>
                  
                  <label className="flex items-center justify-between p-4 bg-slate-100/50 rounded-2xl cursor-pointer hover:bg-amber-50 transition-colors">
                    <div className="flex items-center gap-4">
                      <div className="h-10 w-10 bg-white rounded-xl flex items-center justify-center shadow-sm">
                        <Settings className="w-5 h-5 text-amber-500" />
                      </div>
                      <div>
                        <p className="font-bold text-slate-900">Data Exporting</p>
                        <p className="text-xs text-slate-500">
                          Access to download CSV/Excel participation reports
                        </p>
                      </div>
                    </div>
                    <input
                      type="checkbox"
                      defaultChecked
                      className="w-6 h-6 rounded-lg border-slate-300 text-amber-500 focus:ring-amber-500"
                    />
                  </label>
                </div>
              </div>

              <div className="pt-6">
                <div className="p-6 bg-red-50 rounded-[24px] border border-red-100 flex items-start gap-4">
                  <div className="w-5 h-5 text-red-500 mt-1 flex-shrink-0">⚠️</div>
                  <div>
                    <p className="font-bold text-red-700">Danger Zone</p>
                    <p className="text-sm text-red-600/80 mb-4">
                      Deleting this user will permanently erase all associated history and
                      records from the portal database.
                    </p>
                    <button 
                      type="button"
                      onClick={() => router.push(`/users/${userId}/ban`)}
                      className="px-5 py-2 bg-white text-red-600 rounded-xl text-xs font-bold uppercase tracking-widest border border-red-200 hover:bg-red-50 transition-colors active:scale-95"
                    >
                      Deactivate Account
                    </button>
                  </div>
                </div>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>
  );
}
