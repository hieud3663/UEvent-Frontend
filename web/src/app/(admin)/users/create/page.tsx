// File: src/app/(admin)/users/create/page.tsx
'use client';

import { useState } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { ChevronRight, UserPlus } from 'lucide-react';
import { buildCreateUserPayload, createUser } from '@/features/users/services/users.service';
import { getApiFieldErrors, type ApiFieldErrors } from '@/core/lib/api';
import { AdminSelect } from '@/core/components';
import { runActionWithToast } from '@/core/lib/runActionWithToast';

const baseFieldClassName =
  'w-full bg-slate-200/30 border-none rounded-2xl px-5 py-4 text-slate-900 font-medium focus:ring-2 focus:ring-amber-500 focus:bg-white transition-all outline-none';

export default function CreateUserPage() {
  const router = useRouter();
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [fieldErrors, setFieldErrors] = useState<ApiFieldErrors>({});
  const roleOptions = [
    { value: 'student', label: 'Sinh viên' },
    { value: 'organizer', label: 'Nhà tổ chức' },
    { value: 'admin', label: 'Quản trị viên' },
  ] as const;

  const getFieldMessages = (...fields: string[]) => fields.flatMap((field) => fieldErrors[field] ?? []);

  const getFieldClassName = (...fields: string[]) => {
    const hasError = getFieldMessages(...fields).length > 0;
    return hasError
      ? `${baseFieldClassName} ring-2 ring-red-400 bg-red-50/80 focus:ring-red-500`
      : baseFieldClassName;
  };

  const handleCreateUser = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setIsSubmitting(true);
    setFieldErrors({});

    try {
      const formData = new FormData(e.currentTarget);
      await runActionWithToast(() => createUser(buildCreateUserPayload(formData)), {
        loading: 'Đang tạo tài khoản...',
        success: 'Tài khoản đã được tạo.',
        error: 'Không thể tạo tài khoản.',
      });
      router.push('/users');
      router.refresh();
    } catch (error) {
      setFieldErrors(getApiFieldErrors(error));
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="min-h-screen px-0 pb-20 sm:px-4 lg:px-10">
      <header className="mb-8 flex flex-col gap-4 md:mb-10 md:flex-row md:items-end md:justify-between">
        <div>
          <nav className="flex items-center gap-2 text-xs font-bold uppercase tracking-widest text-slate-400 mb-2">
            <Link href="/users" className="hover:text-amber-500">
              Người dùng
            </Link>
            <ChevronRight className="w-3.5 h-3.5" />
            <span className="text-slate-600">Tạo người dùng mới</span>
          </nav>

          <h1 className="text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl">
            Tạo tài khoản
          </h1>
          <p className="text-slate-500 mt-2 font-medium">
            Thiết lập hồ sơ người dùng mới và phân quyền truy cập hệ thống.
          </p>
        </div>
        <div className="flex flex-col gap-3 sm:flex-row">
          <Link
            href="/users"
            className="flex items-center justify-center rounded-xl border border-white/40 px-6 py-2.5 text-sm font-bold text-slate-600 shadow-sm transition-all hover:bg-white active:scale-95 glass-panel"
          >
            Hủy
          </Link>
          <button 
            type="submit" 
            form="create-user-form"
            disabled={isSubmitting}
            className="flex items-center justify-center gap-2 rounded-xl bg-amber-500 px-8 py-2.5 text-sm font-bold text-white shadow-lg shadow-amber-500/30 transition-all hover:saturate-150 active:scale-95 disabled:opacity-60"
          >
            <UserPlus className="w-4 h-4" />
            {isSubmitting ? 'Đang tạo...' : 'Tạo người dùng'}
          </button>
        </div>
      </header>

      {/* Form Content */}
      <div className="max-w-4xl">
        <div className="glass-panel rounded-[28px] border border-white/40 p-4 shadow-[0_8px_32px_rgba(0,0,0,0.04)] sm:p-6 lg:rounded-[32px] lg:p-10">
          <div className="flex items-center gap-3 mb-8">
            <div className="h-8 w-1 bg-amber-500 rounded-full"></div>
            <h2 className="text-2xl font-bold text-slate-900">Thông tin cá nhân</h2>
          </div>

          <form id="create-user-form" className="space-y-8" onSubmit={handleCreateUser}>
            <FieldErrorMessages messages={getFieldMessages('non_field_errors', 'detail')} />

            {/* Name & Email Row */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="space-y-2">
                <label className="text-xs font-bold uppercase tracking-widest text-slate-500 ml-1">
                  Họ và tên
                </label>
                <input
                  name="full_name"
                  type="text"
                  placeholder="VD: Nguyễn Văn A"
                  required
                  aria-invalid={getFieldMessages('full_name').length > 0}
                  className={getFieldClassName('full_name')}
                />
                <FieldErrorMessages messages={getFieldMessages('full_name')} />
              </div>
              <div className="space-y-2">
                <label className="text-xs font-bold uppercase tracking-widest text-slate-500 ml-1">
                  Địa chỉ email
                </label>
                <input
                  name="email"
                  type="email"
                  placeholder="VD: nva@university.edu.vn"
                  required
                  aria-invalid={getFieldMessages('email').length > 0}
                  className={getFieldClassName('email')}
                />
                <FieldErrorMessages messages={getFieldMessages('email')} />
              </div>
            </div>

            {/* Academic Details Row */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
              <div className="space-y-2">
                <label className="text-xs font-bold uppercase tracking-widest text-slate-500 ml-1">
                  Mã sinh viên 
                </label>
                <input
                  name="student_code"
                  type="text"
                  placeholder="VD: 20241234"
                  aria-invalid={getFieldMessages('student_code').length > 0}
                  className={getFieldClassName('student_code')}
                />
                <FieldErrorMessages messages={getFieldMessages('student_code')} />
              </div>
              <div className="space-y-2">
                <label className="text-xs font-bold uppercase tracking-widest text-slate-500 ml-1">
                  Mã lớp
                </label>
                <input
                  name="class_name"
                  type="text"
                  placeholder="VD: CS-K65"
                  aria-invalid={getFieldMessages('class_name').length > 0}
                  className={getFieldClassName('class_name')}
                />
                <FieldErrorMessages messages={getFieldMessages('class_name')} />
              </div>
              <div className="space-y-2">
                <label className="text-xs font-bold uppercase tracking-widest text-slate-500 ml-1">
                  Vai trò
                </label>
                <AdminSelect
                  name="role"
                  defaultValue="student"
                  options={roleOptions}
                  invalid={getFieldMessages('role', 'role_codes').length > 0}
                  ariaLabel="Chọn vai trò người dùng"
                  triggerClassName={`${getFieldClassName('role', 'role_codes')} h-auto cursor-pointer py-4`}
                />
                <FieldErrorMessages messages={getFieldMessages('role', 'role_codes')} />
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
              <div className="space-y-2">
                <label className="text-xs font-bold uppercase tracking-widest text-slate-500 ml-1">
                  Tên đăng nhập
                </label>
                <input
                  name="username"
                  type="text"
                  placeholder="Mặc định dùng email"
                  aria-invalid={getFieldMessages('username').length > 0}
                  className={getFieldClassName('username')}
                />
                <FieldErrorMessages messages={getFieldMessages('username')} />
              </div>
              <div className="space-y-2">
                <label className="text-xs font-bold uppercase tracking-widest text-slate-500 ml-1">
                  Mật khẩu
                </label>
                <input
                  value={'12345678@'}
                  name="password"
                  type="password"
                  placeholder="Mật khẩu tạm"
                  required
                  minLength={8}
                  aria-invalid={getFieldMessages('password').length > 0}
                  className={getFieldClassName('password')}
                />
                <FieldErrorMessages messages={getFieldMessages('password')} />
              </div>
              <div className="space-y-2">
                <label className="text-xs font-bold uppercase tracking-widest text-slate-500 ml-1">
                  Khoa/đơn vị
                </label>
                <input
                  name="faculty"
                  type="text"
                  placeholder="VD: Công nghệ thông tin"
                  aria-invalid={getFieldMessages('faculty').length > 0}
                  className={getFieldClassName('faculty')}
                />
                <FieldErrorMessages messages={getFieldMessages('faculty')} />
              </div>
            </div>

            {/* Permission checkbox mock UI tạm ẩn vì API admin users hiện chỉ hỗ trợ role_codes.
                Khi backend có contract permission chi tiết, khối này sẽ được bật lại và bind với API thật. */}
            
            {/* Action Buttons for Mobile mostly, but good to have at bottom too */}
            <div className="pt-8 border-t border-slate-200/50 flex justify-end gap-3 md:hidden">
              <button 
                type="submit"
                className="w-full py-3.5 bg-amber-500 text-white rounded-xl font-bold hover:bg-amber-600 transition-colors shadow-md"
              >
                Tạo người dùng
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
}

function FieldErrorMessages({ messages }: { messages: string[] }) {
  if (messages.length === 0) return null;

  return (
    <div className="space-y-1 rounded-xl bg-red-50/80 px-3 py-2 text-xs font-semibold text-red-600">
      {messages.map((message) => (
        <p key={message}>{message}</p>
      ))}
    </div>
  );
}
