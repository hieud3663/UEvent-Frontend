// File: src/app/(admin)/users/[id]/ban/page.tsx
'use client';

import { useEffect, useState } from 'react';
import Image from 'next/image';
import Link from 'next/link';
import { useParams, useRouter } from 'next/navigation';
import { ChevronLeft } from 'lucide-react';
import {
  banUserById,
  getUserById,
} from '@/features/users/services/users.service';
import type { User } from '@/features/users/types';
import { AdminSelect, ConfirmActionDialog, ErrorState, ListSkeleton } from '@/core/components';
import { runActionWithToast } from '@/core/lib/runActionWithToast';

export default function BanUserPage() {
  const params = useParams();
  const router = useRouter();
  const userId = params.id as string;
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [banReason, setBanReason] = useState('Vi phạm điều khoản sử dụng');
  const [banDetails, setBanDetails] = useState('');
  const [isConfirmOpen, setIsConfirmOpen] = useState(false);
  const banReasonOptions = [
    { value: 'Vi phạm điều khoản sử dụng', label: 'Vi phạm điều khoản sử dụng' },
    { value: 'Spam hoặc hành vi bot', label: 'Spam hoặc hành vi bot' },
    { value: 'Quấy rối hoặc phát ngôn thù ghét', label: 'Quấy rối hoặc phát ngôn thù ghét' },
    { value: 'Hoạt động gian lận', label: 'Hoạt động gian lận' },
    { value: 'Khác', label: 'Khác' },
  ] as const;

  useEffect(() => {
    let isMounted = true;

    async function loadUser() {
      setIsLoading(true);

      try {
        const currentUser = await getUserById(userId);
        if (isMounted) {
          setUser(currentUser);
        }
      } finally {
        if (isMounted) {
          setIsLoading(false);
        }
      }
    }

    void loadUser();

    return () => {
      isMounted = false;
    };
  }, [userId]);

  if (isLoading) {
    return <ListSkeleton rows={5} className="p-6" />;
  }

  if (!user) {
    return (
      <ErrorState
        title="Không tìm thấy người dùng"
        message="Không thể tải thông tin tài khoản cần khóa. Vui lòng quay lại danh sách và thử lại."
        retryLabel="Quay lại danh sách"
        onRetry={() => router.push('/users')}
      />
    );
  }

  return (
    <div className="flex min-h-[calc(100vh-64px)] items-center justify-center p-0 pb-20 sm:p-6">
      {/* Focused Modal Card */}
      <div className="w-full max-w-xl overflow-hidden rounded-[28px] border border-white/40 bg-white/70 shadow-2xl shadow-slate-200/50 backdrop-blur-3xl sm:rounded-[32px]">
        {/* Modal Header (iOS Style) */}
        <div className="flex flex-col gap-3 border-b border-black/5 px-4 py-5 sm:flex-row sm:items-center sm:justify-between sm:px-8 sm:py-6">
          <button 
            onClick={() => router.back()}
            className="flex items-center text-slate-400 hover:text-slate-600 transition-colors"
          >
            <ChevronLeft className="w-5 h-5" />
            <span className="text-sm font-semibold">Quay lại</span>
          </button>
          <h1 className="text-lg font-bold text-slate-900 tracking-tight">Xác nhận khóa tài khoản</h1>
          <div className="hidden w-12 sm:block"></div> {/* Spacer for center alignment */}
        </div>

        <div className="p-4 sm:p-8">
          {/* User Context Section */}
          <div className="mb-8 flex flex-col gap-4 rounded-2xl border border-red-100 bg-red-50/50 p-4 sm:flex-row sm:items-center">
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
            <div className="sm:ml-auto">
              <span className="px-2 py-1 bg-red-100 text-red-700 text-[10px] font-black uppercase rounded-md whitespace-nowrap">
                Sắp khóa
              </span>
            </div>
          </div>

          {/* Form Section */}
          <div className="space-y-6">
            <div>
              <label className="block text-[10px] font-bold uppercase tracking-widest text-slate-400 mb-2 ml-1">
                Lý do khóa tài khoản
              </label>
              <AdminSelect
                value={banReason}
                onChange={setBanReason}
                options={banReasonOptions}
                ariaLabel="Chọn lý do khóa tài khoản"
                triggerClassName="h-auto rounded-2xl border-none bg-slate-200/50 px-4 py-3 text-slate-700 focus:ring-2 focus:ring-amber-500"
              />
            </div>

            <div>
              <label className="block text-[10px] font-bold uppercase tracking-widest text-slate-400 mb-2 ml-1">
                Ghi chú chi tiết
              </label>
              <textarea 
                value={banDetails}
                onChange={(event) => setBanDetails(event.target.value)}
                className="w-full bg-slate-200/50 border-none rounded-2xl px-4 py-3 text-sm focus:ring-2 focus:ring-amber-500 text-slate-700 outline-none resize-none" 
                placeholder="Nhập chi tiết bổ sung nếu cần..." 
                rows={4}
              ></textarea>
            </div>

            {/* Notify email checkbox tạm ẩn vì API ban hiện chỉ nhận reason, chưa có contract gửi email/appeal. */}
          </div>
        </div>

        {/* Modal Actions */}
        <div className="flex flex-col gap-3 border-t border-black/5 bg-white/80 px-4 py-5 backdrop-blur-md sm:px-8 sm:py-6 md:flex-row">
          <Link 
            href="/users"
            className="flex-1 order-2 md:order-1 py-3 px-6 rounded-2xl text-sm font-bold text-slate-600 hover:bg-slate-100 transition-all active:scale-95 text-center"
          >
            Hủy
          </Link>
          <button 
            type="button"
            onClick={() => {
              setIsConfirmOpen(true);
            }}
            className="flex-1 order-1 md:order-2 py-3 px-6 rounded-2xl text-sm font-bold bg-amber-500 text-white shadow-lg shadow-amber-500/30 hover:shadow-xl hover:saturate-150 transition-all active:scale-95"
          >
            Khóa tài khoản
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
        onConfirm={async () => {
          const reason = [banReason, banDetails.trim()].filter(Boolean).join(' - ');
          await runActionWithToast(() => banUserById(user.id, reason), {
            loading: `Đang khóa ${user.name}...`,
            success: `${user.name} đã bị khóa.`,
            error: `Không thể khóa ${user.name}.`,
          });
          setIsConfirmOpen(false);
          router.push('/users');
          router.refresh();
        }}
      />
    </div>
  );
}
