import type { CSSProperties } from 'react';
import { colorCssVariables, type CssVariableMap } from './colors';
import { typographyCssVariables } from './typography';

export const constantsTokens = {
  'radius-sm': '0.5rem',
  'radius-md': '0.75rem',
  'radius-lg': '1rem',
  'radius-xl': '1.5rem',
  'shadow-soft': '0 8px 32px rgba(0,0,0,0.04)',
  'shadow-glow': '0 0 20px rgba(255,184,0,0.3)',
} as const;

export const constantsCssVariables: CssVariableMap = Object.fromEntries(
  Object.entries(constantsTokens).map(([key, value]) => [`--token-${key}`, value])
) as CssVariableMap;

export function getThemeStyleVariables(): CSSProperties {
  return {
    ...(colorCssVariables as CSSProperties),
    ...(typographyCssVariables as CSSProperties),
    ...(constantsCssVariables as CSSProperties),
  };
}
