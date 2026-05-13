// File: src/features/categories/types/index.ts

export interface Category {
  id: string;
  name: string;
  slug: string;
  description: string;
  icon: string;
  color: string;
  eventCount: number;
  isActive: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface CategoryStats {
  totalCategories: number;
  activeCategories: number;
  totalEvents: number;
  popularCategory: string;
}

export interface AdminCategoryDto {
  id: string;
  name: string;
  slug: string;
  description: string;
  icon: string | null;
  color: string | null;
  event_count: number;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface AdminCategoryStatsDto {
  total_categories: number;
  active_categories: number;
  total_events: number;
  popular_category: {
    id: string;
    name: string;
    slug: string;
    event_count: number;
  } | null;
}

export interface UpsertCategoryPayload {
  name: string;
  slug?: string;
  description?: string;
  icon?: string;
  color?: string;
  is_active?: boolean;
}

export interface CategoryListResult {
  categories: Category[];
  total: number;
  page: number;
  pageSize: number;
  totalPages: number;
}
