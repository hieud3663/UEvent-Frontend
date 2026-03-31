// File: src/core/types/navigation.ts

import { type LucideIcon } from 'lucide-react';

export interface NavItem {
  label: string;
  href: string;
  icon: LucideIcon;
  badge?: number;
  isActive?: boolean;
}

export interface NavSection {
  title?: string;
  items: NavItem[];
}
