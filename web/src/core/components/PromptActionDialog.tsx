'use client';

import { useState, useEffect } from 'react';
import * as AlertDialog from '@radix-ui/react-alert-dialog';
import { cn } from '@/core/lib/utils';

interface PromptActionDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  title: string;
  description: string;
  placeholder?: string;
  confirmLabel?: string;
  cancelLabel?: string;
  variant?: 'default' | 'danger' | 'success';
  onConfirm: (value: string) => void | Promise<void>;
}

export function PromptActionDialog({
  open,
  onOpenChange,
  title,
  description,
  placeholder = 'Nhập nội dung...',
  confirmLabel = 'Xác nhận',
  cancelLabel = 'Hủy',
  variant = 'default',
  onConfirm,
}: PromptActionDialogProps) {
  const [value, setValue] = useState('');

  // Reset value when dialog opens
  useEffect(() => {
    if (open) {
      setValue('');
    }
  }, [open]);

  return (
    <AlertDialog.Root open={open} onOpenChange={onOpenChange}>
      <AlertDialog.Portal>
        <AlertDialog.Overlay className="fixed inset-0 z-[100] bg-slate-950/40 backdrop-blur-sm" />
        <AlertDialog.Content className="fixed left-1/2 top-1/2 z-[101] w-[92vw] max-w-md -translate-x-1/2 -translate-y-1/2 rounded-3xl border border-white/40 bg-white/90 p-6 shadow-2xl glass-card">
          <AlertDialog.Title className="text-lg font-bold tracking-tight text-slate-900">
            {title}
          </AlertDialog.Title>
          <AlertDialog.Description className="mt-2 text-sm leading-relaxed text-slate-600">
            {description}
          </AlertDialog.Description>

          <div className="mt-4">
            <textarea
              autoFocus
              value={value}
              onChange={(e) => setValue(e.target.value)}
              placeholder={placeholder}
              className="w-full min-h-[100px] rounded-xl border border-slate-200 bg-white p-3 text-sm outline-none transition-all focus:border-amber-400 focus:ring-4 focus:ring-amber-500/10 placeholder:text-slate-400 resize-none"
            />
          </div>

          <div className="mt-6 flex items-center justify-end gap-3">
            <AlertDialog.Cancel className="rounded-xl border border-slate-200 bg-white px-4 py-2 text-sm font-semibold text-slate-600 transition-colors hover:bg-slate-50">
              {cancelLabel}
            </AlertDialog.Cancel>
            <AlertDialog.Action
              onClick={(e) => {
                e.preventDefault(); // Prevent default close if onConfirm is async
                void Promise.resolve(onConfirm(value)).then(() => {
                  onOpenChange(false);
                });
              }}
              className={cn(
                'rounded-xl px-4 py-2 text-sm font-bold text-white transition-colors',
                variant === 'danger'
                  ? 'bg-red-500 hover:bg-red-600'
                  : variant === 'success'
                  ? 'bg-emerald-500 hover:bg-emerald-600'
                  : 'bg-amber-500 hover:bg-amber-600'
              )}
            >
              {confirmLabel}
            </AlertDialog.Action>
          </div>
        </AlertDialog.Content>
      </AlertDialog.Portal>
    </AlertDialog.Root>
  );
}
