// File: src/app/(auth)/login/page.tsx
'use client';

import { Suspense, useState } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { Mail, Lock, Eye, EyeOff, Zap } from 'lucide-react';
import { Input, ListSkeleton } from '@/core/components';
import { loginAdmin } from '@/features/auth/services/auth.service';

export default function LoginPage() {
  return (
    <Suspense fallback={<ListSkeleton rows={4} className="m-auto w-full max-w-md p-6" />}>
      <LoginForm />
    </Suspense>
  );
}

function LoginForm() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const [showPassword, setShowPassword] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setIsLoading(true);
    setErrorMessage(null);

    const formData = new FormData(e.currentTarget);
    const username = String(formData.get('username') ?? '').trim();
    const password = String(formData.get('password') ?? '');

    try {
      await loginAdmin({ username, password });
      router.push(searchParams.get('next') || '/dashboard');
      router.refresh();
    } catch (error) {
      setErrorMessage(error instanceof Error ? error.message : 'Không thể đăng nhập. Vui lòng thử lại.');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <main className="flex flex-col items-center justify-center min-h-screen p-6 relative z-10">
      {/* Logo Section */}
      <div className="flex flex-col items-center mb-10">
        <div className="w-16 h-16 bg-primary-container rounded-2xl flex items-center justify-center shadow-2xl shadow-primary-container/20 mb-4">
          <Zap className="w-8 h-8 text-on-primary-container" fill="currentColor" />
        </div>
        <h1 className="text-2xl font-black text-on-surface tracking-tight uppercase">
          UEvents
        </h1>
        <p className="text-on-surface-variant font-medium text-sm mt-1">
          Admin Control Center
        </p>
      </div>

      <div className="w-full max-w-md glass-card rounded-[32px] p-8 shadow-2xl shadow-black/5">
        <form onSubmit={handleSubmit} className="space-y-6">
          {/* Email Field */}
          <Input
            label="Admin Email"
            name="username"
            type="text"
            placeholder="admin@uevents.com hoặc username"
            leftIcon={<Mail className="w-5 h-5" />}
            autoComplete="username"
            required
          />

          {/* Password Field */}
          <div className="space-y-2">
            <label className="text-xs font-bold uppercase tracking-widest text-on-surface-variant ml-1">
              Password
            </label>
            <div className="relative">
              <span className="absolute left-4 top-1/2 -translate-y-1/2 text-outline">
                <Lock className="w-5 h-5" />
              </span>
              <input
                name="password"
                type={showPassword ? 'text' : 'password'}
                placeholder="••••••••"
                autoComplete="current-password"
                className="w-full bg-surface-container-low/50 border-none rounded-2xl py-4 pl-12 pr-12 text-on-surface font-medium placeholder:text-outline-variant focus:ring-2 focus:ring-primary-container focus:outline-none transition-all duration-200"
                required
              />
              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                className="absolute right-4 top-1/2 -translate-y-1/2 text-outline hover:text-on-surface transition-colors"
                aria-label={showPassword ? 'Hide password' : 'Show password'}
              >
                {showPassword ? (
                  <EyeOff className="w-5 h-5" />
                ) : (
                  <Eye className="w-5 h-5" />
                )}
              </button>
            </div>
          </div>

          {errorMessage ? (
            <div className="rounded-2xl border border-red-100 bg-red-50 px-4 py-3 text-sm font-medium text-red-700">
              {errorMessage}
            </div>
          ) : null}

          {/* Submit Button */}
          <button
            type="submit"
            disabled={isLoading}
            className="w-full bg-primary-container text-on-primary-container font-bold py-4 rounded-2xl shadow-lg shadow-primary-container/30 hover:shadow-xl hover:shadow-primary-container/40 hover:scale-[1.02] active:scale-[0.98] transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {isLoading ? 'Logging in...' : 'Login to Dashboard'}
          </button>
        </form>

      </div>

      {/* Footer */}
      <div className="fixed bottom-0 left-0 right-0 p-8 flex justify-between items-end opacity-40 pointer-events-none">
        <div className="text-[10px] font-bold uppercase tracking-[0.2em] text-on-surface-variant">
          © 2024 UEvents Inc.
        </div>
        <div className="flex gap-4">
          <div className="w-8 h-[2px] bg-primary-container" />
          <div className="w-16 h-[2px] bg-outline-variant" />
        </div>
      </div>
    </main>
  );
}
