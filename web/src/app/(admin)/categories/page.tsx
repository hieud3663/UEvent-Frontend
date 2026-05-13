// File: src/app/(admin)/categories/page.tsx
'use client';

import { useCallback, useEffect, useState } from 'react';
import type { FormEvent } from 'react';
import { Plus, Edit, Trash2, Music, ChevronLeft, ChevronRight, Search, RotateCw } from 'lucide-react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { Button, Card, ConfirmActionDialog, EmptyState, ErrorState, ListSkeleton } from '@/core/components';
import {
  deleteCategoryById,
  getCategoriesPage,
  getCategoryStats,
} from '@/features/categories/services/categories.service';
import { categoryIconMap } from '@/features/categories/utils/category-display';
import { cn } from '@/core/lib/utils';
import type { Category, CategoryListResult } from '@/features/categories/types';
import { toast } from 'sonner';
import { runActionWithToast } from '@/core/lib/runActionWithToast';

const CATEGORY_PAGE_SIZE = 8;
type CategoryStatusFilter = 'all' | 'active' | 'inactive';
type CategoryOrdering = 'name' | '-name' | 'created_at' | '-created_at' | 'event_count' | '-event_count';

export default function CategoriesPage() {
  const [categories, setCategories] = useState<Category[]>([]);
  const [stats, setStats] = useState<Awaited<ReturnType<typeof getCategoryStats>> | null>(null);
  const [pagination, setPagination] = useState<Omit<CategoryListResult, 'categories'> | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [keyword, setKeyword] = useState('');
  const [submittedKeyword, setSubmittedKeyword] = useState('');
  const [statusFilter, setStatusFilter] = useState<CategoryStatusFilter>('all');
  const [ordering, setOrdering] = useState<CategoryOrdering>('name');
  const [currentPage, setCurrentPage] = useState(1);
  const [categoryToDelete, setCategoryToDelete] = useState<Category | null>(null);
  const router = useRouter();

  const loadCategoriesPageData = useCallback(async () => {
    try {
      setIsLoading(true);
      setError(null);
      const isActive = statusFilter === 'all' ? undefined : statusFilter === 'active';
      const [categoriesResponse, categoriesStats] = await Promise.all([
        getCategoriesPage({
          keyword: submittedKeyword,
          isActive,
          ordering,
          page: currentPage,
          pageSize: CATEGORY_PAGE_SIZE,
        }),
        getCategoryStats(),
      ]);

      setCategories(categoriesResponse.categories);
      setPagination({
        total: categoriesResponse.total,
        page: categoriesResponse.page,
        pageSize: categoriesResponse.pageSize,
        totalPages: categoriesResponse.totalPages,
      });
      setStats(categoriesStats);
    } catch (loadError) {
      setError(loadError instanceof Error ? loadError.message : 'Không thể tải danh mục.');
    } finally {
      setIsLoading(false);
    }
  }, [currentPage, ordering, statusFilter, submittedKeyword]);

  useEffect(() => {
    void loadCategoriesPageData();
  }, [loadCategoriesPageData]);

  const totalPages = pagination?.totalPages ?? 1;
  const safeCurrentPage = pagination?.page ?? currentPage;
  const totalCategories = pagination?.total ?? categories.length;

  const handleEditCategory = (category: Category) => {
    toast.info(`Đang mở trình chỉnh sửa cho ${category.name}.`);
    router.push(`/categories/create?categoryId=${category.id}`);
  };

  const handleDeleteCategory = async (category: Category) => {
    const previousCategories = categories;
    setCategories((prev) => prev.filter((item) => item.id !== category.id));

    try {
      await runActionWithToast(() => deleteCategoryById(category.id), {
        loading: `Đang xóa ${category.name}...`,
        success: category.eventCount > 0
          ? `Đã chuyển danh mục ${category.name} sang tạm ẩn vì vẫn còn sự kiện.`
          : `Đã xóa danh mục ${category.name}.`,
        error: `Không thể xóa ${category.name}.`,
      });
      await loadCategoriesPageData();
    } catch {
      setCategories(previousCategories);
    }
  };

  const handleDeleteRequest = (category: Category) => {
    setCategoryToDelete(category);
  };

  const handleConfirmDelete = async () => {
    if (!categoryToDelete) {
      return;
    }

    const target = categoryToDelete;
    setCategoryToDelete(null);
    await handleDeleteCategory(target);
  };

  const handleSearchSubmit = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    setCurrentPage(1);
    setSubmittedKeyword(keyword.trim());
  };

  const handleResetFilters = () => {
    setKeyword('');
    setSubmittedKeyword('');
    setStatusFilter('all');
    setOrdering('name');
    setCurrentPage(1);
  };

  if (isLoading) {
    return <ListSkeleton rows={8} />;
  }

  if (error) {
    return (
      <ErrorState
        title="Không thể tải danh mục"
        message={error}
        onRetry={() => {
          void loadCategoriesPageData();
        }}
      />
    );
  }

  if (!stats) {
    return null;
  }

  return (
    <div className="space-y-8">
      {/* Header Section */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h2 className="text-2xl font-bold text-slate-900 tracking-tight">
            Quản lý danh mục
          </h2>
          <p className="text-slate-500 text-sm font-medium mt-1">
            Sắp xếp và kiểm soát phân loại sự kiện trên toàn hệ thống.
          </p>
        </div>
        <Button
          variant="primary"
          onClick={() => router.push('/categories/create')}
          className="rounded-xl shadow-lg shadow-amber-500/30"
          leftIcon={<Plus className="w-5 h-5" />}
        >
          Tạo danh mục mới
        </Button>
      </div>

      <form
        onSubmit={handleSearchSubmit}
        className="grid grid-cols-1 gap-3 rounded-2xl border border-white/60 bg-white/70 p-4 shadow-sm md:grid-cols-[minmax(0,1fr)_180px_220px_auto]"
      >
        <label className="relative">
          <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-slate-400" />
          <input
            value={keyword}
            onChange={(event) => setKeyword(event.target.value)}
            placeholder="Tìm theo tên, slug hoặc mô tả danh mục"
            className="h-10 w-full rounded-xl border border-slate-200 bg-white pl-10 pr-3 text-sm text-slate-800 outline-none focus:border-amber-500 focus:ring-4 focus:ring-amber-500/10"
          />
        </label>
        <select
          value={statusFilter}
          onChange={(event) => {
            setStatusFilter(event.target.value as CategoryStatusFilter);
            setCurrentPage(1);
          }}
          className="h-10 rounded-xl border border-slate-200 bg-white px-3 text-sm font-medium text-slate-700 outline-none focus:border-amber-500"
        >
          <option value="all">Tất cả trạng thái</option>
          <option value="active">Đang hoạt động</option>
          <option value="inactive">Tạm ẩn</option>
        </select>
        <select
          value={ordering}
          onChange={(event) => {
            setOrdering(event.target.value as CategoryOrdering);
            setCurrentPage(1);
          }}
          className="h-10 rounded-xl border border-slate-200 bg-white px-3 text-sm font-medium text-slate-700 outline-none focus:border-amber-500"
        >
          <option value="name">Tên A-Z</option>
          <option value="-name">Tên Z-A</option>
          <option value="-event_count">Nhiều sự kiện nhất</option>
          <option value="event_count">Ít sự kiện nhất</option>
          <option value="-created_at">Mới tạo trước</option>
          <option value="created_at">Cũ nhất trước</option>
        </select>
        <div className="flex gap-2">
          <Button type="submit" size="md" className="shrink-0">
            Tìm kiếm
          </Button>
          <Button
            type="button"
            variant="outline"
            size="md"
            onClick={handleResetFilters}
            leftIcon={<RotateCw className="h-4 w-4" />}
          >
            Đặt lại
          </Button>
        </div>
      </form>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <Card className="glass-card border-none rounded-2xl p-6">
          <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest mb-1">
            Tổng danh mục
          </p>
          <p className="text-3xl font-extrabold text-slate-900">{stats.totalCategories}</p>
        </Card>
        <Card className="glass-card border-none rounded-2xl p-6">
          <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest mb-1">
            Đang hoạt động
          </p>
          <div className="flex items-center gap-2">
            <p className="text-3xl font-extrabold text-slate-900">{stats.activeCategories}</p>
            <span className="text-xs font-bold text-emerald-500 bg-emerald-50 px-2 py-0.5 rounded-full">
              +2 mới
            </span>
          </div>
        </Card>
        <Card className="glass-card border-none rounded-2xl p-6">
          <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest mb-1">
            Tổng sự kiện
          </p>
          <p className="text-3xl font-extrabold text-slate-900">{stats.totalEvents.toLocaleString('vi-VN')}</p>
        </Card>
        <Card className="glass-card border-none rounded-2xl p-6 bg-amber-50/50 border-amber-200/50">
          <p className="text-[10px] font-bold text-amber-600/70 uppercase tracking-widest mb-1">
            Nổi bật
          </p>
          <p className="text-xl font-bold text-amber-900">{stats.popularCategory}</p>
        </Card>
      </div>

      {/* Category Table */}
      <div className="bg-white/80 backdrop-blur-xl rounded-3xl border border-white/60 shadow-lg overflow-hidden">
        <table className="w-full text-left border-collapse">
          <thead>
            <tr className="bg-slate-50/50">
              <th className="px-8 py-5 text-[10px] font-extrabold text-slate-400 uppercase tracking-widest">
                Tên danh mục
              </th>
              <th className="px-8 py-5 text-[10px] font-extrabold text-slate-400 uppercase tracking-widest">
                Số sự kiện
              </th>
              <th className="px-8 py-5 text-[10px] font-extrabold text-slate-400 uppercase tracking-widest">
                Trạng thái
              </th>
              <th className="px-8 py-5 text-[10px] font-extrabold text-slate-400 uppercase tracking-widest">
                Cập nhật lần cuối
              </th>
              <th className="px-8 py-5 text-[10px] font-extrabold text-slate-400 uppercase tracking-widest text-right">
                Hành động
              </th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100">
            {categories.map((category) => (
              <CategoryRow
                key={category.id}
                category={category}
                onEdit={handleEditCategory}
                onDelete={handleDeleteRequest}
              />
            ))}
          </tbody>
        </table>

        {categories.length === 0 ? (
          <div className="p-8">
            <EmptyState
              title="Không tìm thấy danh mục"
              description="Hãy tạo danh mục mới hoặc xóa bộ lọc hiện tại để xem kết quả."
              actionLabel="Tạo danh mục"
              onAction={() => router.push('/categories/create')}
            />
          </div>
        ) : null}

        {/* Pagination */}
        <div className="px-8 py-4 bg-slate-50/30 flex items-center justify-between">
          <p className="text-xs font-medium text-slate-500">
            Hiển thị {(safeCurrentPage - 1) * CATEGORY_PAGE_SIZE + 1}-{Math.min(safeCurrentPage * CATEGORY_PAGE_SIZE, totalCategories)} trong {totalCategories} danh mục
          </p>
          <div className="flex gap-2">
            <button
              type="button"
              onClick={() => setCurrentPage((prev) => Math.max(1, prev - 1))}
              disabled={safeCurrentPage === 1}
              className="p-2 bg-white border border-slate-200 rounded-lg text-slate-400 transition-colors disabled:opacity-50"
            >
              <ChevronLeft className="w-4 h-4" />
            </button>
            <span className="inline-flex min-w-20 items-center justify-center rounded-lg border border-slate-200 bg-white px-3 text-xs font-bold text-slate-600">
              {safeCurrentPage}/{totalPages}
            </span>
            <button
              type="button"
              onClick={() => setCurrentPage((prev) => Math.min(totalPages, prev + 1))}
              disabled={safeCurrentPage >= totalPages}
              className="p-2 bg-white border border-slate-200 rounded-lg text-slate-400 hover:text-amber-600 transition-colors"
            >
              <ChevronRight className="w-4 h-4" />
            </button>
          </div>
        </div>
      </div>

      {/* Floating Action Button */}
      <Link href="/categories/create" className="fixed bottom-8 right-8 w-14 h-14 bg-on-surface text-white rounded-full shadow-2xl shadow-black/30 flex items-center justify-center hover:scale-110 active:scale-95 transition-all z-50">
        <Plus className="w-6 h-6" />
      </Link>

      <ConfirmActionDialog
        open={categoryToDelete !== null}
        onOpenChange={(open) => {
          if (!open) {
            setCategoryToDelete(null);
          }
        }}
        title="Xác nhận xóa danh mục"
        description={categoryToDelete
          ? `Bạn sắp xóa danh mục ${categoryToDelete.name}. Hành động này có thể ảnh hưởng đến dữ liệu phân loại và không thể hoàn tác.`
          : 'Bạn sắp xóa một danh mục.'}
        confirmLabel="Xác nhận"
        cancelLabel="Hủy"
        variant="danger"
        onConfirm={() => {
          void handleConfirmDelete();
        }}
      />
    </div>
  );
}

function CategoryRow({
  category,
  onEdit,
  onDelete,
}: {
  category: Category;
  onEdit: (category: Category) => void;
  onDelete: (category: Category) => void;
}) {
  const Icon = categoryIconMap[category.icon] || Music;

  return (
    <tr className="hover:bg-amber-50/30 transition-colors group">
      <td className="px-8 py-5">
        <div className="flex items-center gap-4">
          <div
            className="w-10 h-10 rounded-xl flex items-center justify-center"
            style={{ backgroundColor: `${category.color}20` }}
          >
            <Icon className="w-5 h-5" style={{ color: category.color }} />
          </div>
          <span className="font-bold text-slate-900">{category.name}</span>
        </div>
      </td>
      <td className="px-8 py-5">
        <span className="text-sm font-semibold text-slate-600 bg-slate-100 px-3 py-1 rounded-full">
          {category.eventCount} sự kiện
        </span>
      </td>
      <td className="px-8 py-5">
        <div
          className={cn(
            'flex items-center gap-1.5',
            category.isActive ? 'text-emerald-600' : 'text-slate-400'
          )}
        >
          <span
            className={cn(
              'w-2 h-2 rounded-full',
              category.isActive ? 'bg-emerald-500 animate-pulse' : 'bg-slate-300'
            )}
          />
          <span className="text-xs font-bold uppercase tracking-wider">
            {category.isActive ? 'Đang hoạt động' : 'Tạm ẩn'}
          </span>
        </div>
      </td>
      <td className="px-8 py-5">
        <span className="text-sm text-slate-500 font-medium">
          {new Date(category.updatedAt).toLocaleDateString('vi-VN', {
            month: 'short',
            day: 'numeric',
            year: 'numeric',
          })}
        </span>
      </td>
      <td className="px-8 py-5 text-right">
        <div className="flex items-center justify-end gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
          <button
            type="button"
            onClick={() => onEdit(category)}
            className="p-2 text-slate-400 hover:text-amber-600 hover:bg-amber-50 rounded-lg transition-all"
          >
            <Edit className="w-4 h-4" />
          </button>
          <button
            type="button"
            onClick={() => {
              void onDelete(category);
            }}
            className="p-2 text-slate-400 hover:text-red-600 hover:bg-red-50 rounded-lg transition-all"
          >
            <Trash2 className="w-4 h-4" />
          </button>
        </div>
      </td>
    </tr>
  );
}
