// File: src/core/components/AdminSelect.tsx
'use client';

import { useEffect, useId, useMemo, useRef, useState } from 'react';
import type { ReactNode } from 'react';
import { Check, ChevronDown } from 'lucide-react';
import { cn } from '@/core/lib/utils';

export interface AdminSelectOption<T extends string = string> {
  value: T;
  label: string;
  description?: string;
  disabled?: boolean;
}

interface AdminSelectProps<T extends string = string> {
  options: ReadonlyArray<AdminSelectOption<T>>;
  value?: T;
  defaultValue?: T;
  onChange?: (value: T) => void;
  name?: string;
  placeholder?: string;
  ariaLabel?: string;
  disabled?: boolean;
  invalid?: boolean;
  leftIcon?: ReactNode;
  className?: string;
  triggerClassName?: string;
  menuClassName?: string;
}

export function AdminSelect<T extends string = string>({
  options,
  value,
  defaultValue,
  onChange,
  name,
  placeholder = 'Chọn một mục',
  ariaLabel,
  disabled = false,
  invalid = false,
  leftIcon,
  className,
  triggerClassName,
  menuClassName,
}: AdminSelectProps<T>) {
  const generatedId = useId();
  const wrapperRef = useRef<HTMLDivElement>(null);
  const [isOpen, setIsOpen] = useState(false);
  const firstEnabledOption = useMemo(() => options.find((option) => !option.disabled), [options]);
  const [internalValue, setInternalValue] = useState<T | undefined>(defaultValue);
  const selectedValue = value ?? internalValue ?? firstEnabledOption?.value;
  const selectedOption = options.find((option) => option.value === selectedValue);

  useEffect(() => {
    function handlePointerDown(event: PointerEvent) {
      if (!wrapperRef.current?.contains(event.target as Node)) {
        setIsOpen(false);
      }
    }

    function handleEscape(event: KeyboardEvent) {
      if (event.key === 'Escape') {
        setIsOpen(false);
      }
    }

    document.addEventListener('pointerdown', handlePointerDown);
    document.addEventListener('keydown', handleEscape);
    return () => {
      document.removeEventListener('pointerdown', handlePointerDown);
      document.removeEventListener('keydown', handleEscape);
    };
  }, []);

  const handleSelect = (nextValue: T) => {
    if (value === undefined) {
      setInternalValue(nextValue);
    }

    onChange?.(nextValue);
    setIsOpen(false);
  };

  return (
    <div ref={wrapperRef} className={cn('relative', className)}>
      {name ? <input type="hidden" name={name} value={selectedValue ?? ''} /> : null}
      <button
        type="button"
        aria-haspopup="listbox"
        aria-expanded={isOpen}
        aria-controls={`${generatedId}-listbox`}
        aria-label={ariaLabel}
        disabled={disabled}
        onClick={() => setIsOpen((open) => !open)}
        className={cn(
          'flex h-10 w-full items-center justify-between gap-3 rounded-xl border border-slate-200 bg-white px-3 text-left text-sm font-medium text-slate-700 outline-none transition-all',
          'hover:border-amber-300 focus:border-amber-500 focus:ring-4 focus:ring-amber-500/10',
          disabled && 'cursor-not-allowed opacity-60',
          invalid && 'border-red-300 bg-red-50/80 focus:border-red-500 focus:ring-red-500/10',
          leftIcon && 'pl-4',
          triggerClassName
        )}
      >
        <span className="flex min-w-0 items-center gap-2">
          {leftIcon ? <span className="shrink-0 text-amber-500">{leftIcon}</span> : null}
          <span className={cn('truncate', !selectedOption && 'text-slate-400')}>
            {selectedOption?.label ?? placeholder}
          </span>
        </span>
        <ChevronDown className={cn('h-4 w-4 shrink-0 text-slate-400 transition-transform', isOpen && 'rotate-180')} />
      </button>

      {isOpen ? (
        <div
          id={`${generatedId}-listbox`}
          role="listbox"
          className={cn(
            'absolute left-0 right-0 top-[calc(100%+0.5rem)] z-50 max-h-72 overflow-auto rounded-2xl border border-white/70 bg-white/95 p-1.5 shadow-2xl shadow-slate-900/10 backdrop-blur-xl',
            menuClassName
          )}
        >
          {options.map((option) => {
            const isSelected = option.value === selectedValue;

            return (
              <button
                key={option.value}
                type="button"
                role="option"
                aria-selected={isSelected}
                disabled={option.disabled}
                onClick={() => handleSelect(option.value)}
                className={cn(
                  'flex w-full items-center justify-between gap-3 rounded-xl px-3 py-2.5 text-left text-sm font-semibold text-slate-700 transition-colors',
                  'hover:bg-amber-50 hover:text-slate-950 focus:bg-amber-50 focus:outline-none',
                  isSelected && 'bg-amber-500 text-white hover:bg-amber-500 hover:text-white',
                  option.disabled && 'cursor-not-allowed opacity-50 hover:bg-transparent',
                )}
              >
                <span className="min-w-0">
                  <span className="block truncate">{option.label}</span>
                  {option.description ? (
                    <span className={cn('mt-0.5 block text-xs font-medium text-slate-400', isSelected && 'text-white/80')}>
                      {option.description}
                    </span>
                  ) : null}
                </span>
                {isSelected ? <Check className="h-4 w-4 shrink-0" /> : null}
              </button>
            );
          })}
        </div>
      ) : null}
    </div>
  );
}
