import { apiRequest, apiRequestEnvelope } from '@/core/lib/api';
import type {
  AdminCategoryDto,
  AdminCategoryStatsDto,
  Category,
  CategoryListResult,
  CategoryStats,
  UpsertCategoryPayload,
} from '../types';

export interface CategoryFilters {
  keyword?: string;
  isActive?: boolean;
  ordering?: 'name' | '-name' | 'created_at' | '-created_at' | 'event_count' | '-event_count';
  page?: number;
  pageSize?: number;
}

function mapCategory(dto: AdminCategoryDto): Category {
  return {
    id: dto.id,
    name: dto.name,
    slug: dto.slug,
    description: dto.description,
    icon: dto.icon ?? 'music',
    color: dto.color ?? '#F59E0B',
    eventCount: dto.event_count,
    isActive: dto.is_active,
    createdAt: dto.created_at,
    updatedAt: dto.updated_at,
  };
}

function mapCategoryStats(dto: AdminCategoryStatsDto): CategoryStats {
  return {
    totalCategories: dto.total_categories,
    activeCategories: dto.active_categories,
    totalEvents: dto.total_events,
    popularCategory: dto.popular_category?.name ?? 'Chưa có dữ liệu',
  };
}

export async function getCategoriesPage(filters: CategoryFilters = {}): Promise<CategoryListResult> {
  const params = new URLSearchParams();
  params.set('page', String(filters.page ?? 1));
  params.set('page_size', String(filters.pageSize ?? 10));

  if (filters.keyword?.trim()) {
    params.set('search', filters.keyword.trim());
  }

  if (filters.isActive !== undefined) {
    params.set('is_active', String(filters.isActive));
  }

  if (filters.ordering) {
    params.set('ordering', filters.ordering);
  }

  const envelope = await apiRequestEnvelope<AdminCategoryDto[]>(`/admin/categories/?${params.toString()}`);
  const pagination = envelope.meta.pagination;
  const categories = envelope.data.map(mapCategory);

  return {
    categories,
    total: pagination?.count ?? categories.length,
    page: pagination?.page ?? filters.page ?? 1,
    pageSize: pagination?.page_size ?? filters.pageSize ?? categories.length,
    totalPages: pagination?.total_pages ?? 1,
  };
}

export async function getCategories(filters: CategoryFilters = {}): Promise<Category[]> {
  const response = await getCategoriesPage({ pageSize: 100, ...filters });
  return response.categories;
}

export async function getCategoryStats(): Promise<CategoryStats> {
  const response = await apiRequest<AdminCategoryStatsDto>('/admin/categories/statistics/');
  return mapCategoryStats(response);
}

export async function getCategoryById(categoryId: string): Promise<Category> {
  const response = await apiRequest<AdminCategoryDto>(`/admin/categories/${categoryId}/`);
  return mapCategory(response);
}

export async function createCategory(payload: UpsertCategoryPayload): Promise<Category> {
  const response = await apiRequest<AdminCategoryDto>('/admin/categories/', {
    method: 'POST',
    body: payload,
  });
  return mapCategory(response);
}

export async function updateCategoryById(categoryId: string, payload: UpsertCategoryPayload): Promise<Category> {
  const response = await apiRequest<AdminCategoryDto>(`/admin/categories/${categoryId}/`, {
    method: 'PATCH',
    body: payload,
  });
  return mapCategory(response);
}

export async function deleteCategoryById(categoryId: string, reason = 'Quản trị viên đã xóa danh mục từ bảng điều khiển web.'): Promise<void> {
  await apiRequest(`/admin/categories/${categoryId}/`, {
    method: 'DELETE',
    body: { reason },
  });
}
