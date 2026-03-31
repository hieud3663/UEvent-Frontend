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
