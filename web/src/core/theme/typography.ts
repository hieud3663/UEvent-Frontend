import type { CssVariableMap } from './colors';

export const typographyTokens = {
  'font-sans-fallback': "'Inter', 'Segoe UI', Arial, Helvetica, sans-serif",
  'font-mono-fallback': "'Fira Code', 'Cascadia Code', Consolas, monospace",
  'font-size-xs': '0.75rem',
  'font-size-sm': '0.875rem',
  'font-size-base': '1rem',
  'font-size-lg': '1.125rem',
  'font-size-xl': '1.25rem',
} as const;

export const typographyCssVariables: CssVariableMap = Object.fromEntries(
  Object.entries(typographyTokens).map(([key, value]) => [`--token-${key}`, value])
) as CssVariableMap;
