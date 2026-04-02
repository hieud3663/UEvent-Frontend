// File: src/app/(auth)/login/page.tsx
'use client';

import { useState } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { Mail, Lock, Eye, EyeOff, Zap, ArrowLeft } from 'lucide-react';
import { Input } from '@/core/components';

export default function LoginPage() {
  const router = useRouter();
  const [showPassword, setShowPassword] = useState(false);
  const [isLoading, setIsLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setIsLoading(true);

    // Simulate login - replace with actual auth logic
    await new Promise((resolve) => setTimeout(resolve, 1000));

    setIsLoading(false);
    router.push('/dashboard');
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

      {/* Login Card */}
      <div className="w-full max-w-md glass-card rounded-[32px] p-8 shadow-2xl shadow-black/5">
        <form onSubmit={handleSubmit} className="space-y-6">
          {/* Email Field */}
          <Input
            label="Admin Email"
            type="email"
            placeholder="admin@uevents.com"
            leftIcon={<Mail className="w-5 h-5" />}
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
                type={showPassword ? 'text' : 'password'}
                placeholder="••••••••"
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

          {/* Submit Button */}
          <button
            type="submit"
            disabled={isLoading}
            className="w-full bg-primary-container text-on-primary-container font-bold py-4 rounded-2xl shadow-lg shadow-primary-container/30 hover:shadow-xl hover:shadow-primary-container/40 hover:scale-[1.02] active:scale-[0.98] transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {isLoading ? 'Logging in...' : 'Login to Dashboard'}
          </button>
        </form>

        {/* Forgot Password */}
        <div className="mt-8 text-center">
          <Link
            href="#"
            className="text-sm font-semibold text-primary hover:text-on-primary-container transition-colors"
          >
            Forgot Password?
          </Link>
        </div>
      </div>

      {/* Secondary Navigation */}
      <div className="mt-12 flex items-center justify-center gap-6">
        <Link
          href="#"
          className="flex items-center gap-2 px-6 py-3 glass-card rounded-full text-sm font-bold text-on-surface-variant hover:text-on-surface transition-all"
        >
          <ArrowLeft className="w-4 h-4" />
          Return to Site
        </Link>
        <div className="w-1 h-1 bg-outline-variant rounded-full" />
        <Link
          href="#"
          className="text-sm font-bold text-outline hover:text-on-surface-variant transition-colors"
        >
          Help Center
        </Link>
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
