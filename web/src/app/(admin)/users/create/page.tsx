// File: src/app/(admin)/users/create/page.tsx
'use client';

import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { ChevronRight, Settings, UserPlus } from 'lucide-react';

export default function CreateUserPage() {
  const router = useRouter();

  const handleCreateUser = (e: React.FormEvent) => {
    e.preventDefault();
    alert('User created successfully!');
    router.push('/users');
  };

  return (
    <div className="min-h-screen px-10 pb-20">
      <header className="mb-10 flex justify-between items-end">
        <div>
          <nav className="flex items-center gap-2 text-xs font-bold uppercase tracking-widest text-slate-400 mb-2">
            <Link href="/users" className="hover:text-amber-500">
              Users
            </Link>
            <ChevronRight className="w-3.5 h-3.5" />
            <span className="text-slate-600">Create New User</span>
          </nav>

          <h1 className="text-4xl font-extrabold tracking-tight text-slate-900">
            Create Account
          </h1>
          <p className="text-slate-500 mt-2 font-medium">
            Setup a new user profile and configure system access permissions.
          </p>
        </div>
        <div className="flex gap-3">
          <Link
            href="/users"
            className="px-6 py-2.5 glass-panel rounded-xl text-sm font-bold text-slate-600 hover:bg-white transition-all active:scale-95 border border-white/40 shadow-sm flex items-center justify-center"
          >
            Cancel
          </Link>
          <button 
            type="submit" 
            form="create-user-form"
            className="px-8 py-2.5 bg-amber-500 text-white rounded-xl text-sm font-bold shadow-lg shadow-amber-500/30 hover:saturate-150 transition-all active:scale-95 flex items-center justify-center gap-2"
          >
            <UserPlus className="w-4 h-4" />
            Create User
          </button>
        </div>
      </header>

      {/* Form Content */}
      <div className="max-w-4xl">
        <div className="glass-panel rounded-[32px] p-10 shadow-[0_8px_32px_rgba(0,0,0,0.04)] border border-white/40">
          <div className="flex items-center gap-3 mb-8">
            <div className="h-8 w-1 bg-amber-500 rounded-full"></div>
            <h2 className="text-2xl font-bold text-slate-900">Personal Information</h2>
          </div>

          <form id="create-user-form" className="space-y-8" onSubmit={handleCreateUser}>
            {/* Name & Email Row */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="space-y-2">
                <label className="text-xs font-bold uppercase tracking-widest text-slate-500 ml-1">
                  Full Name
                </label>
                <input
                  type="text"
                  placeholder="e.g. Nguyễn Văn A"
                  required
                  className="w-full bg-slate-200/30 border-none rounded-2xl px-5 py-4 text-slate-900 font-medium focus:ring-2 focus:ring-amber-500 focus:bg-white transition-all outline-none"
                />
              </div>
              <div className="space-y-2">
                <label className="text-xs font-bold uppercase tracking-widest text-slate-500 ml-1">
                  Email Address
                </label>
                <input
                  type="email"
                  placeholder="e.g. nva@university.edu.vn"
                  required
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
                <input
                  type="text"
                  placeholder="e.g. 20241234"
                  className="w-full bg-slate-200/30 border-none rounded-2xl px-5 py-4 text-slate-900 font-medium focus:ring-2 focus:ring-amber-500 focus:bg-white transition-all outline-none"
                />
              </div>
              <div className="space-y-2">
                <label className="text-xs font-bold uppercase tracking-widest text-slate-500 ml-1">
                  Class Code
                </label>
                <input
                  type="text"
                  placeholder="e.g. CS-K65"
                  className="w-full bg-slate-200/30 border-none rounded-2xl px-5 py-4 text-slate-900 font-medium focus:ring-2 focus:ring-amber-500 focus:bg-white transition-all outline-none"
                />
              </div>
              <div className="space-y-2">
                <label className="text-xs font-bold uppercase tracking-widest text-slate-500 ml-1">
                  Role Type
                </label>
                <select className="w-full bg-slate-200/30 border-none rounded-2xl px-5 py-4 text-slate-900 font-medium focus:ring-2 focus:ring-amber-500 focus:bg-white transition-all outline-none appearance-none cursor-pointer">
                  <option value="Student">Student</option>
                  <option value="Organizer">Organizer</option>
                  <option value="Faculty Admin">Faculty Admin</option>
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
                    className="w-6 h-6 rounded-lg border-slate-300 text-amber-500 focus:ring-amber-500 outline-none"
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
                    className="w-6 h-6 rounded-lg border-slate-300 text-amber-500 focus:ring-amber-500 outline-none"
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
                    className="w-6 h-6 rounded-lg border-slate-300 text-amber-500 focus:ring-amber-500 outline-none"
                  />
                </label>
              </div>
            </div>
            
            {/* Action Buttons for Mobile mostly, but good to have at bottom too */}
            <div className="pt-8 border-t border-slate-200/50 flex justify-end gap-3 md:hidden">
              <button 
                type="submit"
                className="w-full py-3.5 bg-amber-500 text-white rounded-xl font-bold hover:bg-amber-600 transition-colors shadow-md"
              >
                Create User
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
}
