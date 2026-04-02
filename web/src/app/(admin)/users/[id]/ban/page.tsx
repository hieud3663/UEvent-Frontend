// File: src/app/(admin)/users/[id]/ban/page.tsx
'use client';

import { useEffect, useState } from 'react';
import Image from 'next/image';
import Link from 'next/link';
import { useParams, useRouter } from 'next/navigation';
import { ChevronLeft } from 'lucide-react';
import {
  getUserById,
  getUsers,
} from '@/features/users/services/users.service';
import type { User } from '@/features/users/types';
import { toast } from 'sonner';
import { ConfirmActionDialog } from '@/core/components';

export default function BanUserPage() {
  const params = useParams();
  const router = useRouter();
  const userId = params.id as string;
  const [user, setUser] = useState<User | null>(null);
  const [isConfirmOpen, setIsConfirmOpen] = useState(false);
  const banReasonOptions = [
    { value: 'Violation of Terms of Service', label: 'Violation of Terms of Service' },
    { value: 'Spam or Bot Behavior', label: 'Spam or Bot Behavior' },
    { value: 'Harassment / Hate Speech', label: 'Harassment / Hate Speech' },
    { value: 'Fraudulent Activity', label: 'Fraudulent Activity' },
    { value: 'Other (Specify below)', label: 'Other (Specify below)' },
  ] as const;

  useEffect(() => {
    let isMounted = true;

    async function loadUser() {
      const currentUser = await getUserById(userId);

      if (currentUser) {
        if (isMounted) {
          setUser(currentUser);
        }
        return;
      }

      const usersResponse = await getUsers();
      if (isMounted) {
        setUser(usersResponse.users[0] ?? null);
      }
    }

    void loadUser();

    return () => {
      isMounted = false;
    };
  }, [userId]);

  if (!user) {
    return <div className="p-6 text-sm text-slate-500">Loading user...</div>;
  }

  return (
    <div className="min-h-[calc(100vh-64px)] flex items-center justify-center p-6 pb-20">
      {/* Focused Modal Card */}
      <div className="max-w-xl w-full bg-white/70 backdrop-blur-3xl border border-white/40 rounded-[32px] shadow-2xl shadow-slate-200/50 overflow-hidden">
        {/* Modal Header (iOS Style) */}
        <div className="px-8 py-6 flex items-center justify-between border-b border-black/5">
          <button 
            onClick={() => router.back()}
            className="flex items-center text-slate-400 hover:text-slate-600 transition-colors"
          >
            <ChevronLeft className="w-5 h-5" />
            <span className="text-sm font-semibold">Back</span>
          </button>
          <h1 className="text-lg font-bold text-slate-900 tracking-tight">Confirm User Ban</h1>
          <div className="w-12"></div> {/* Spacer for center alignment */}
        </div>

        <div className="p-8">
          {/* User Context Section */}
          <div className="flex items-center gap-4 p-4 bg-red-50/50 rounded-2xl border border-red-100 mb-8">
            <div className="relative h-14 w-14 rounded-full border-2 border-white shadow-sm overflow-hidden flex-shrink-0 bg-slate-200">
              {user.avatar ? (
                <Image src={user.avatar} alt="User avatar" fill sizes="56px" className="w-full h-full object-cover" />
              ) : (
                <div className="w-full h-full flex items-center justify-center bg-gradient-to-br from-amber-200 to-amber-400 text-slate-700 font-bold text-lg">
                  {user.name.split(' ').map(n => n[0]).join('')}
                </div>
              )}
            </div>
            <div>
              <h3 className="font-bold text-slate-900">{user.name}</h3>
              <p className="text-xs font-medium text-slate-500">
                ID: {user.studentId} • {user.email}
              </p>
            </div>
            <div className="ml-auto">
              <span className="px-2 py-1 bg-amber-100 text-amber-700 text-[10px] font-black uppercase rounded-md whitespace-nowrap">
                Status: Warning
              </span>
            </div>
          </div>

          {/* Form Section */}
          <div className="space-y-6">
            <div>
              <label className="block text-[10px] font-bold uppercase tracking-widest text-slate-400 mb-2 ml-1">
                Reason for Ban
              </label>
              <select className="w-full bg-slate-200/50 border-none rounded-2xl px-4 py-3 text-sm focus:ring-2 focus:ring-amber-500 text-slate-700 font-medium outline-none appearance-none">
                {banReasonOptions.map((option) => (
                  <option key={option.value} value={option.value}>
                    {option.label}
                  </option>
                ))}
              </select>
            </div>

            <div>
              <label className="block text-[10px] font-bold uppercase tracking-widest text-slate-400 mb-2 ml-1">
                Detailed Explanation
              </label>
              <textarea 
                className="w-full bg-slate-200/50 border-none rounded-2xl px-4 py-3 text-sm focus:ring-2 focus:ring-amber-500 text-slate-700 outline-none resize-none" 
                placeholder="Enter specific details about the violation..." 
                rows={4}
              ></textarea>
            </div>

            <div className="flex items-start gap-3 p-4 bg-slate-50 rounded-2xl border border-slate-200/50">
              <div className="pt-0.5">
                <input 
                  type="checkbox" 
                  className="rounded text-amber-500 focus:ring-amber-500 w-4 h-4 border-slate-300"
                  defaultChecked
                />
              </div>
              <p className="text-xs leading-relaxed text-slate-500 font-medium">
                Notify user via email about this decision and provide instructions for the appeal process.
              </p>
            </div>
          </div>
        </div>

        {/* Modal Actions */}
        <div className="px-8 py-6 bg-white/80 backdrop-blur-md border-t border-black/5 flex flex-col md:flex-row gap-3">
          <Link 
            href="/users"
            className="flex-1 order-2 md:order-1 py-3 px-6 rounded-2xl text-sm font-bold text-slate-600 hover:bg-slate-100 transition-all active:scale-95 text-center"
          >
            Cancel Action
          </Link>
          <button 
            type="button"
            onClick={() => {
              setIsConfirmOpen(true);
            }}
            className="flex-1 order-1 md:order-2 py-3 px-6 rounded-2xl text-sm font-bold bg-amber-500 text-white shadow-lg shadow-amber-500/30 hover:shadow-xl hover:saturate-150 transition-all active:scale-95"
          >
            Ban User Permanently
          </button>
        </div>
      </div>

      <ConfirmActionDialog
        open={isConfirmOpen}
        onOpenChange={setIsConfirmOpen}
        title="Xác nhận khóa tài khoản"
        description={`Bạn sắp khóa tài khoản của ${user.name}. Hành động này có thể gây mất quyền truy cập và khó hoàn tác.`}
        confirmLabel="Xác nhận"
        cancelLabel="Hủy"
        variant="danger"
        onConfirm={() => {
          toast.success('User has been banned.');
          setIsConfirmOpen(false);
          router.push('/users');
        }}
      />
    </div>
  );
}
