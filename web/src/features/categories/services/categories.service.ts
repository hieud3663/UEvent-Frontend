import { categoryStats, mockCategories } from '../mock/mock-categories';
import type { Category } from '../types';

export async function getCategories(): Promise<Category[]> {
  return Promise.resolve(mockCategories);
}

export async function getCategoryStats() {
  return Promise.resolve(categoryStats);
}

export async function deleteCategoryById(categoryId: string): Promise<void> {
  const targetCategory = mockCategories.find((item) => item.id === categoryId);

  if (!targetCategory) {
    throw new Error('Category not found');
  }

  return Promise.resolve();
}
