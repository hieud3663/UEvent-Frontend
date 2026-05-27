// File: src/app/(admin)/users/[id]/page.tsx
'use client';

import { useEffect, useState } from 'react';
import Image from 'next/image';
import Link from 'next/link';
import { useParams, useRouter } from 'next/navigation';
import { ChevronRight, KeyRound, ShieldOff } from 'lucide-react';
import { AdminSelect, ErrorState, ListSkeleton } from '@/core/components';
import { runActionWithToast } from '@/core/lib/runActionWithToast';
import {
  getUserById,
  getUserPasskeys,
  revokeUserPasskey,
  unbanUserById,
  updateUserById,
} from '@/features/users/services/users.service';
import type { PasskeyCredential, User, UserRole } from '@/features/users/types';

const statusDisplay = {
  active: { dot: 'bg-emerald-500', label: 'Đang hoạt động', text: 'text-emerald-600' },
  pending: { dot: 'bg-amber-500', label: 'Chờ duyệt', text: 'text-amber-600' },
  banned: { dot: 'bg-red-500', label: 'Đã khóa', text: 'text-red-600' },
} satisfies Record<User['status'], { dot: string; label: string; text: string }>;

export default function EditUserPage() {
  const params = useParams();
  const router = useRouter();
  const userId = params.id as string;
  const [user, setUser] = useState<User | null>(null);
  const [passkeys, setPasskeys] = useState<PasskeyCredential[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [revokingPasskeyId, setRevokingPasskeyId] = useState<string | null>(null);
  const roleOptions = [
    { value: 'student', label: 'Sinh viên' },
    { value: 'organizer', label: 'Nhà tổ chức' },
    { value: 'admin', label: 'Quản trị viên' },
  ] as const;

  useEffect(() => {
    let isMounted = true;

    async function loadUser() {
      setIsLoading(true);
      const currentUser = await getUserById(userId);
      const currentPasskeys = currentUser ? await getUserPasskeys(userId) : [];
      if (isMounted) {
        setUser(currentUser);
        setPasskeys(currentPasskeys);
        setIsLoading(false);
      }
    }

    void loadUser();

    return () => {
      isMounted = false;
    };
  }, [userId]);

  const handleUpdateUser = async (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    setIsSubmitting(true);

    try {
      const formData = new FormData(event.currentTarget);
      const role = String(formData.get('role') ?? user?.role ?? 'student') as UserRole;
      await runActionWithToast(
        () => updateUserById(userId, {
          full_name: String(formData.get('full_name') ?? '').trim(),
          student_code: String(formData.get('student_code') ?? '').trim() || undefined,
          faculty: String(formData.get('faculty') ?? '').trim() || undefined,
          class_name: String(formData.get('class_name') ?? '').trim() || undefined,
          role_codes: [role],
        }),
        {
          loading: 'Đang cập nhật hồ sơ...',
          success: 'Hồ sơ đã được cập nhật.',
          error: 'Không thể cập nhật hồ sơ.',
        }
      );
      router.push('/users');
      router.refresh();
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleUnbanUser = async () => {
    if (!user) return;

    const previousUser = user;
    setUser({ ...user, status: 'active' });

    try {
      const updatedUser = await runActionWithToast(() => unbanUserById(userId), {
        loading: `Đang mở khóa ${user.name}...`,
        success: `${user.name} đã được mở khóa.`,
        error: `Không thể mở khóa ${user.name}.`,
      });
      setUser(updatedUser);
      router.refresh();
    } catch {
      setUser(previousUser);
    }
  };

  const handleRevokePasskey = async (credential: PasskeyCredential) => {
    if (!credential.isActive) return;

    setRevokingPasskeyId(credential.id);
    try {
      await runActionWithToast(() => revokeUserPasskey(userId, credential.id), {
        loading: `Đang thu hồi ${credential.deviceName}...`,
        success: 'Passkey đã được thu hồi.',
        error: 'Không thể thu hồi passkey.',
      });
      setPasskeys(await getUserPasskeys(userId));
      router.refresh();
    } finally {
      setRevokingPasskeyId(null);
    }
  };

  if (isLoading) {
    return <ListSkeleton rows={6} className="p-4 sm:p-10" />;
  }

  if (!user) {
    return (
      <ErrorState
        title="Không tìm thấy người dùng"
        message="Tài khoản này không tồn tại hoặc bạn không có quyền truy cập."
        retryLabel="Quay lại danh sách"
        onRetry={() => router.push('/users')}
      />
    );
  }

  const currentStatus = statusDisplay[user.status];

  return (
    <div className="min-h-screen px-0 pb-20 sm:px-4 lg:px-10">
      <header className="mb-8 flex flex-col gap-4 md:mb-10 md:flex-row md:items-end md:justify-between">
        <div>
          <nav className="flex items-center gap-2 text-xs font-bold uppercase tracking-widest text-slate-400 mb-2">
            <Link href="/users" className="hover:text-amber-500">
              Người dùng
            </Link>
            <ChevronRight className="w-3.5 h-3.5" />
            <span className="text-slate-600">Cập nhật người dùng</span>
          </nav>

          <h1 className="text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl">
            Chỉnh sửa tài khoản
          </h1>
          <p className="text-slate-500 mt-2 font-medium">
            Cập nhật hồ sơ và quyền truy cập hệ thống cho{' '}
            <span className="text-amber-600 font-bold">{user.name}</span>
          </p>
        </div>
        <div className="flex flex-col gap-3 sm:flex-row">
          <Link
            href="/users"
            className="rounded-xl border border-white/40 px-6 py-2.5 text-center text-sm font-bold text-slate-600 shadow-sm transition-all hover:bg-white active:scale-95 glass-panel"
          >
            Hủy thay đổi
          </Link>
          <button 
            type="submit"
            form="edit-user-form"
            disabled={isSubmitting}
            className="rounded-xl bg-amber-500 px-8 py-2.5 text-sm font-bold text-white shadow-lg shadow-amber-500/30 transition-all hover:saturate-150 active:scale-95 disabled:opacity-60"
          >
            {isSubmitting ? 'Đang cập nhật...' : 'Cập nhật hồ sơ'}
          </button>
        </div>
      </header>

      {/* Bento Grid Form Layout */}
      <div className="grid grid-cols-12 gap-6">
        {/* Profile Overview (Small Card) */}
        <div className="col-span-12 lg:col-span-4 space-y-6">
          <div className="glass-panel flex flex-col items-center rounded-[28px] border border-white/40 p-6 text-center shadow-[0_8px_32px_rgba(0,0,0,0.04)] lg:rounded-[32px] lg:p-8">
            <div className="relative mb-6">
              <div className="relative h-32 w-32 rounded-full overflow-hidden border-4 border-white shadow-xl">
                {user.avatar ? (
                  <Image
                    src={user.avatar}
                    alt={user.name}
                    fill
                    sizes="128px"
                    className="w-full h-full object-cover"
                  />
                ) : (
                  <div className="flex h-full w-full items-center justify-center bg-gradient-to-br from-amber-200 to-amber-400 text-3xl font-black text-slate-700">
                    {user.name.split(' ').map((part) => part[0]).join('')}
                  </div>
                )}
              </div>
              {/* Avatar upload API chưa có trong contract admin users nên tạm ẩn nút upload. */}
            </div>
            <h2 className="text-xl font-bold text-slate-900">{user.name}</h2>
            <p className="text-slate-500 text-sm font-medium">
              {user.role} • {user.className ?? 'Chưa có lớp'}
            </p>

            <div className="mt-8 pt-8 border-t border-slate-200/50 w-full flex justify-around">
              <div>
                <p className="text-[10px] font-bold uppercase tracking-widest text-slate-400">
                  Hoạt động
                </p>
                <p className="text-lg font-bold text-slate-900">Cao</p>
              </div>
              <div>
                <p className="text-[10px] font-bold uppercase tracking-widest text-slate-400">
                  Trạng thái
                </p>
                <div className="flex items-center gap-1.5 justify-center mt-1">
                  <span className={`h-2 w-2 rounded-full ${currentStatus.dot}`}></span>
                  <span className={`text-sm font-bold ${currentStatus.text}`}>{currentStatus.label}</span>
                </div>
              </div>
            </div>
          </div>

          {/* Quick actions reset password/send notice tạm ẩn vì API admin users chưa có endpoint tương ứng. */}
          <div className="glass-panel rounded-[28px] border border-white/40 p-5 shadow-[0_8px_32px_rgba(0,0,0,0.04)] lg:rounded-[32px]">
            <div className="mb-4 flex items-center justify-between gap-3">
              <div>
                <p className="text-[10px] font-bold uppercase tracking-widest text-slate-400">
                  Passkey
                </p>
                <h2 className="mt-1 text-lg font-bold text-slate-900">
                  {passkeys.filter((item) => item.isActive).length} credential đang hoạt động
                </h2>
              </div>
              <span className="rounded-2xl bg-amber-100 p-3 text-amber-600">
                <KeyRound className="h-5 w-5" />
              </span>
            </div>

            {passkeys.length === 0 ? (
              <p className="rounded-2xl bg-white/60 p-4 text-sm font-medium text-slate-500">
                Người dùng chưa đăng ký passkey.
              </p>
            ) : (
              <div className="space-y-3">
                {passkeys.map((credential) => (
                  <div
                    key={credential.id}
                    className="rounded-2xl border border-white/50 bg-white/70 p-4"
                  >
                    <div className="flex items-start justify-between gap-3">
                      <div className="min-w-0">
                        <p className="truncate text-sm font-bold text-slate-900">
                          {credential.deviceName}
                        </p>
                        <p className="mt-1 text-xs font-medium text-slate-500">
                          {credential.deviceType} · {credential.transports.join(', ') || 'không rõ transport'}
                        </p>
                      </div>
                      <span className={`rounded-full px-2 py-1 text-[10px] font-bold ${credential.isActive ? 'bg-emerald-100 text-emerald-700' : 'bg-slate-100 text-slate-500'}`}>
                        {credential.isActive ? 'Active' : 'Revoked'}
                      </span>
                    </div>
                    <p className="mt-3 text-xs font-medium text-slate-500">
                      Lần dùng gần nhất: {credential.lastUsedAt ? formatDateTime(credential.lastUsedAt) : 'Chưa ghi nhận'}
                    </p>
                    {credential.isActive ? (
                      <button
                        type="button"
                        disabled={revokingPasskeyId === credential.id}
                        onClick={() => {
                          void handleRevokePasskey(credential);
                        }}
                        className="mt-3 inline-flex h-9 items-center gap-2 rounded-xl border border-red-200 bg-white px-3 text-xs font-bold text-red-600 transition hover:bg-red-50 disabled:opacity-60"
                      >
                        <ShieldOff className="h-4 w-4" />
                        {revokingPasskeyId === credential.id ? 'Đang thu hồi...' : 'Thu hồi'}
                      </button>
                    ) : null}
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>

        {/* Detailed Info Form (Large Card) */}
        <div className="col-span-12 lg:col-span-8">
          <div className="glass-panel rounded-[28px] border border-white/40 p-4 shadow-[0_8px_32px_rgba(0,0,0,0.04)] sm:p-6 lg:rounded-[32px] lg:p-10">
            <div className="flex items-center gap-3 mb-8">
              <div className="h-8 w-1 bg-amber-500 rounded-full"></div>
              <h2 className="text-2xl font-bold text-slate-900">Thông tin cá nhân</h2>
            </div>

            <form id="edit-user-form" className="space-y-8" onSubmit={handleUpdateUser}>
              {/* Name & Email Row */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div className="space-y-2">
                  <label className="text-xs font-bold uppercase tracking-widest text-slate-500 ml-1">
                    Họ và tên
                  </label>
                  <input
                    name="full_name"
                    type="text"
                    defaultValue={user.name}
                    className="w-full bg-slate-200/30 border-none rounded-2xl px-5 py-4 text-slate-900 font-medium focus:ring-2 focus:ring-amber-500 focus:bg-white transition-all outline-none"
                  />
                </div>
                <div className="space-y-2">
                  <label className="text-xs font-bold uppercase tracking-widest text-slate-500 ml-1">
                    Địa chỉ email
                  </label>
                  <input
                    type="email"
                    value={user.email}
                    readOnly
                    className="w-full bg-slate-200/30 border-none rounded-2xl px-5 py-4 text-slate-500 font-medium outline-none"
                  />
                </div>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div className="space-y-2">
                  <label className="text-xs font-bold uppercase tracking-widest text-slate-500 ml-1">
                    Khoa/đơn vị
                  </label>
                  <input
                    name="faculty"
                    type="text"
                    defaultValue={user.faculty ?? ''}
                    className="w-full bg-slate-200/30 border-none rounded-2xl px-5 py-4 text-slate-900 font-medium focus:ring-2 focus:ring-amber-500 focus:bg-white transition-all outline-none"
                  />
                </div>
                <div className="space-y-2">
                  <label className="text-xs font-bold uppercase tracking-widest text-slate-500 ml-1">
                    Tên đăng nhập
                  </label>
                  <input
                    type="text"
                    value={user.username ?? ''}
                    readOnly
                    className="w-full bg-slate-200/30 border-none rounded-2xl px-5 py-4 text-slate-500 font-medium outline-none"
                  />
                </div>
              </div>

              {/* Academic Details Row */}
              <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                <div className="space-y-2">
                  <label className="text-xs font-bold uppercase tracking-widest text-slate-500 ml-1">
                    Mã sinh viên
                  </label>
                  <div className="relative">
                    <input
                      name="student_code"
                      type="text"
                      defaultValue={user.studentId === '—' ? '' : user.studentId}
                      className="w-full bg-slate-200/30 border-none rounded-2xl px-5 py-4 text-slate-900 font-medium focus:ring-2 focus:ring-amber-500 focus:bg-white transition-all outline-none"
                    />
                  </div>
                </div>
                <div className="space-y-2">
                  <label className="text-xs font-bold uppercase tracking-widest text-slate-500 ml-1">
                    Mã lớp
                  </label>
                  <input
                    name="class_name"
                    type="text"
                    defaultValue={user.className ?? ''}
                    className="w-full bg-slate-200/30 border-none rounded-2xl px-5 py-4 text-slate-900 font-medium focus:ring-2 focus:ring-amber-500 focus:bg-white transition-all outline-none"
                  />
                </div>
                <div className="space-y-2">
                  <label className="text-xs font-bold uppercase tracking-widest text-slate-500 ml-1">
                    Vai trò
                  </label>
                  <AdminSelect
                    name="role"
                    defaultValue={user.role}
                    options={roleOptions}
                    ariaLabel="Chọn vai trò người dùng"
                    triggerClassName="h-auto rounded-2xl border-none bg-slate-200/30 px-5 py-4 text-slate-900 focus:bg-white focus:ring-2 focus:ring-amber-500"
                  />
                </div>
              </div>

              <div className="pt-6">
                <div className="p-6 bg-red-50 rounded-[24px] border border-red-100 flex items-start gap-4">
                  <div className="w-5 h-5 text-red-500 mt-1 flex-shrink-0">⚠️</div>
                  <div>
                    <p className="font-bold text-red-700">Trạng thái tài khoản</p>
                    <p className="text-sm text-red-600/80 mb-4">
                      API hiện hỗ trợ khóa/mở khóa tài khoản qua ban/unban, không xóa vĩnh viễn dữ liệu người dùng.
                    </p>
                    {user.status === 'banned' ? (
                      <button
                        type="button"
                        onClick={() => {
                          void handleUnbanUser();
                        }}
                        className="inline-flex px-5 py-2 bg-white text-emerald-600 rounded-xl text-xs font-bold uppercase tracking-widest border border-emerald-200 hover:bg-emerald-50 transition-colors active:scale-95"
                      >
                        Mở khóa tài khoản
                      </button>
                    ) : (
                      <button 
                        type="button"
                        onClick={() => router.push(`/users/${userId}/ban`)}
                        className="px-5 py-2 bg-white text-red-600 rounded-xl text-xs font-bold uppercase tracking-widest border border-red-200 hover:bg-red-50 transition-colors active:scale-95"
                      >
                        Khóa tài khoản
                      </button>
                    )}
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

function formatDateTime(value: string): string {
  return new Intl.DateTimeFormat('vi-VN', {
    dateStyle: 'short',
    timeStyle: 'short',
  }).format(new Date(value));
}
