// File: src/app/(admin)/categories/create/page.tsx
'use client';

import { useEffect, useMemo, useState } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { toast } from 'sonner';
import {
  Music,
  Eye,
  Info,
  Sparkles,
  BarChart2,
  PartyPopper,
  Gamepad2,
  Utensils,
  Theater,
  Brush,
  Martini,
  Film,
} from 'lucide-react';
import { AdminSelect, ConfirmActionDialog, ListSkeleton } from '@/core/components';
import { getApiFieldErrors, type ApiFieldErrors } from '@/core/lib/api';
import { runActionWithToast } from '@/core/lib/runActionWithToast';
import {
  createCategory,
  getCategoryById,
  updateCategoryById,
} from '@/features/categories/services/categories.service';

type CategoryIconKey = 'music' | 'party' | 'gaming' | 'food' | 'theater' | 'art' | 'nightlife' | 'film';

const iconOptions: Array<{ key: CategoryIconKey; label: string; icon: typeof Music }> = [
  { key: 'party', label: 'Tiệc tùng', icon: PartyPopper },
  { key: 'gaming', label: 'Trò chơi', icon: Gamepad2 },
  { key: 'music', label: 'Âm nhạc', icon: Music },
  { key: 'food', label: 'Ẩm thực', icon: Utensils },
  { key: 'theater', label: 'Sân khấu', icon: Theater },
  { key: 'art', label: 'Nghệ thuật', icon: Brush },
  { key: 'nightlife', label: 'Giải trí đêm', icon: Martini },
  { key: 'film', label: 'Phim ảnh', icon: Film },
];

const iconSelectOptions = iconOptions.map((option) => ({
  value: option.key,
  label: option.label,
}));

export default function CreateCategoryPage() {
  const router = useRouter();
  const [categoryId, setCategoryId] = useState<string | null>(null);
  const [name, setName] = useState('');
  const [slug, setSlug] = useState('');
  const [isSlugTouched, setIsSlugTouched] = useState(false);
  const [description, setDescription] = useState('');
  const [iconKey, setIconKey] = useState<CategoryIconKey>('music');
  const [color, setColor] = useState('#F59E0B');
  const [isActive, setIsActive] = useState(true);
  const [isConfirmOpen, setIsConfirmOpen] = useState(false);
  const [isLoadingCategory, setIsLoadingCategory] = useState(false);
  const [isSaving, setIsSaving] = useState(false);
  const [fieldErrors, setFieldErrors] = useState<ApiFieldErrors>({});

  const selectedIcon = useMemo(
    () => iconOptions.find((option) => option.key === iconKey) ?? iconOptions[2],
    [iconKey]
  );

  const validateBeforeSubmit = () => {
    if (!name.trim()) {
      toast.error('Vui lòng nhập tên danh mục.');
      return false;
    }

    if (!slug.trim()) {
      toast.error('Vui lòng nhập slug danh mục.');
      return false;
    }

    if (!/^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(slug.trim())) {
      toast.error('Slug chỉ được dùng chữ thường, số và dấu gạch ngang.');
      return false;
    }

    if (!description.trim()) {
      toast.error('Vui lòng nhập mô tả danh mục.');
      return false;
    }

    if (!/^#[0-9A-Fa-f]{6}$/.test(color.trim())) {
      toast.error('Màu nhấn phải là mã hex hợp lệ, ví dụ #F59E0B.');
      return false;
    }

    return true;
  };

  const handleCreateRequest = () => {
    if (!validateBeforeSubmit()) {
      return;
    }

    setIsConfirmOpen(true);
  };

  const handleConfirmCreate = async () => {
    setIsConfirmOpen(false);
    setIsSaving(true);

    const payload = {
      name: name.trim(),
      slug: slug.trim(),
      description: description.trim(),
      icon: iconKey,
      color,
      is_active: isActive,
    };

    try {
      setFieldErrors({});
      await runActionWithToast(
        () => categoryId ? updateCategoryById(categoryId, payload) : createCategory(payload),
        {
          loading: categoryId ? 'Đang cập nhật danh mục...' : 'Đang tạo danh mục...',
          success: categoryId ? 'Đã cập nhật danh mục thành công.' : 'Đã tạo danh mục thành công.',
          error: categoryId ? 'Không thể cập nhật danh mục.' : 'Không thể tạo danh mục.',
        }
      );
      router.push('/categories');
    } catch (error) {
      setFieldErrors(getApiFieldErrors(error));
    } finally {
      setIsSaving(false);
    }
  };

  useEffect(() => {
    const categoryIdParam = new URLSearchParams(window.location.search).get('categoryId');
    setCategoryId(categoryIdParam);

    if (!categoryIdParam) {
      return;
    }

    const resolvedCategoryId = categoryIdParam;
    let isMounted = true;

    async function loadCategory() {
      try {
        setIsLoadingCategory(true);
        const category = await getCategoryById(resolvedCategoryId);

        if (!isMounted) {
          return;
        }

        setName(category.name);
        setSlug(category.slug);
        setIsSlugTouched(true);
        setDescription(category.description);
        setIconKey((category.icon as CategoryIconKey) || 'music');
        setColor(category.color);
        setIsActive(category.isActive);
      } catch (error) {
        toast.error(error instanceof Error ? error.message : 'Không thể tải danh mục.');
      } finally {
        if (isMounted) {
          setIsLoadingCategory(false);
        }
      }
    }

    void loadCategory();

    return () => {
      isMounted = false;
    };
  }, []);

  useEffect(() => {
    if (!isSlugTouched) {
      setSlug(buildSlug(name));
    }
  }, [isSlugTouched, name]);

  const SelectedIcon = selectedIcon.icon;
  const baseInputClass =
    'w-full rounded-xl border border-slate-200 bg-white/70 px-4 py-3 text-sm text-slate-800 outline-none transition-all placeholder:text-slate-400 focus:border-amber-500 focus:ring-4 focus:ring-amber-500/10';

  if (isLoadingCategory) {
    return (
      <div className="relative min-h-screen overflow-hidden p-4 sm:p-8">
        <div className="fixed top-[-10%] right-[-5%] w-[500px] h-[500px] bg-amber-200/20 blur-[120px] rounded-full z-[-1]" />
        <div className="fixed bottom-[-10%] left-[10%] w-[400px] h-[400px] bg-sky-200/20 blur-[100px] rounded-full z-[-1]" />
        <ListSkeleton rows={5} className="mx-auto max-w-4xl" />
      </div>
    );
  }

  return (
    <div className="relative min-h-screen overflow-hidden p-4 sm:p-8">
      {/* Background Decorative Elements */}
      <div className="fixed top-[-10%] right-[-5%] w-[500px] h-[500px] bg-amber-200/20 blur-[120px] rounded-full z-[-1]"></div>
      <div className="fixed bottom-[-10%] left-[10%] w-[400px] h-[400px] bg-sky-200/20 blur-[100px] rounded-full z-[-1]"></div>

      <header className="mb-8">
        <h2 className="text-xl font-bold tracking-tight text-slate-900">
          {categoryId ? 'Chỉnh sửa danh mục' : 'Tạo danh mục mới'}
        </h2>
      </header>

      {/* Form Content */}
      <div className="max-w-4xl mx-auto">
        <div className="glass-panel overflow-hidden rounded-[24px] border border-white/40 shadow-[0_8px_32px_rgba(0,0,0,0.04)]">
          {/* Header of the Modal Section */}
          <div className="border-b border-black/5 bg-white/40 px-4 py-5 sm:px-8 sm:py-6">
            <h3 className="text-xl font-bold text-slate-900">Thông tin danh mục</h3>
            <p className="text-sm text-slate-500 mt-1">
              Thiết lập các thuộc tính cho nhóm sự kiện mới.
            </p>
          </div>

          {/* Form Fields */}
          <div className="space-y-8 p-4 sm:p-8">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
              {/* Category Name */}
              <div className="space-y-2">
                <label className="block text-[10px] font-bold uppercase tracking-wider text-slate-400">
                  Tên danh mục
                </label>
                <input
                  type="text"
                  value={name}
                  onChange={(event) => setName(event.target.value)}
                  placeholder="Ví dụ: Âm nhạc & Lễ hội"
                  className={baseInputClass}
                />
                <FieldError messages={fieldErrors.name} />
              </div>

              {/* Category Icon */}
              <div className="space-y-2">
                <label className="block text-[10px] font-bold uppercase tracking-wider text-slate-400">
                  Biểu tượng danh mục
                </label>
                <AdminSelect
                  value={iconKey}
                  onChange={(nextValue) => setIconKey(nextValue as CategoryIconKey)}
                  options={iconSelectOptions}
                  ariaLabel="Chọn biểu tượng danh mục"
                  leftIcon={<SelectedIcon className="h-5 w-5" />}
                  triggerClassName="h-auto bg-white/70 py-3 pl-4 pr-3"
                />
                <FieldError messages={fieldErrors.icon} />
              </div>
            </div>

            <div className="space-y-2">
              <label className="block text-[10px] font-bold uppercase tracking-wider text-slate-400">
                Slug danh mục
              </label>
              <input
                type="text"
                value={slug}
                onChange={(event) => {
                  setIsSlugTouched(true);
                  setSlug(buildSlug(event.target.value));
                }}
                placeholder="am-nhac-le-hoi"
                className={baseInputClass}
              />
              <p className="text-[11px] text-slate-400">
                Slug dùng cho đường dẫn và bộ lọc kỹ thuật, chỉ gồm chữ thường, số và dấu gạch ngang.
              </p>
              <FieldError messages={fieldErrors.slug} />
            </div>

            <div className="space-y-2">
              <label className="block text-[10px] font-bold uppercase tracking-wider text-slate-400">
                Màu nhấn
              </label>
              <div className="flex items-center gap-3">
                <input
                  type="color"
                  value={color}
                  onChange={(event) => setColor(event.target.value)}
                  className="h-11 w-14 rounded-lg border border-slate-200 bg-white p-1"
                  aria-label="Màu nhấn của danh mục"
                />
                <input
                  type="text"
                  value={color}
                  onChange={(event) => setColor(event.target.value)}
                  className={baseInputClass}
                />
              </div>
              <FieldError messages={fieldErrors.color} />
            </div>

            {/* Description */}
            <div className="space-y-2">
              <label className="block text-[10px] font-bold uppercase tracking-wider text-slate-400">
                Mô tả
              </label>
              <textarea
                value={description}
                onChange={(event) => setDescription(event.target.value)}
                placeholder="Mô tả những sự kiện thuộc danh mục này..."
                rows={4}
                className={`${baseInputClass} min-h-[112px] resize-none`}
              ></textarea>
              <p className="text-[11px] text-slate-400 text-right">
                {description.length}/280
              </p>
              <FieldError messages={fieldErrors.description} />
            </div>

            {/* Visibility & Meta */}
            <div className="flex flex-col md:flex-row items-center justify-between gap-6 p-6 bg-amber-50/50 rounded-2xl border border-amber-100/50">
              <div className="flex items-center gap-4">
                <div className="w-12 h-12 rounded-full bg-amber-500/10 flex items-center justify-center">
                  <Eye className="text-amber-500 w-6 h-6" />
                </div>
                <div>
                  <h4 className="text-sm font-bold text-slate-900">Trạng thái hiển thị</h4>
                  <p className="text-xs text-slate-500">
                    Quyết định danh mục này có hiển thị cho người dùng hay không.
                  </p>
                </div>
              </div>
              <div className="flex bg-white/80 p-1.5 rounded-full border border-slate-200 shadow-sm">
                <button
                  type="button"
                  onClick={() => setIsActive(true)}
                  className={isActive ? 'px-6 py-2 text-xs font-bold rounded-full bg-amber-500 text-white shadow-md' : 'px-6 py-2 text-xs font-bold rounded-full text-slate-400 hover:text-slate-600'}
                >
                  Hoạt động
                </button>
                <button
                  type="button"
                  onClick={() => setIsActive(false)}
                  className={!isActive ? 'px-6 py-2 text-xs font-bold rounded-full bg-slate-800 text-white shadow-md' : 'px-6 py-2 text-xs font-bold rounded-full text-slate-400 hover:text-slate-600'}
                >
                  Tạm ẩn
                </button>
              </div>
            </div>

            {/* Icon Preview Grid (Decorative Visual Element) */}
            <div className="space-y-4">
              <p className="text-[10px] font-bold uppercase tracking-wider text-slate-400">
                Biểu tượng gợi ý
              </p>
              <div className="grid grid-cols-4 sm:grid-cols-6 md:grid-cols-8 gap-3">
                {iconOptions.map((option) => {
                  const OptionIcon = option.icon;
                  const isSelected = option.key === iconKey;

                  return (
                    <button
                      key={option.key}
                      type="button"
                      onClick={() => setIconKey(option.key)}
                      className={isSelected
                        ? 'aspect-square flex items-center justify-center bg-amber-500/10 border border-amber-500 rounded-lg cursor-pointer'
                        : 'aspect-square flex items-center justify-center bg-white/50 border border-slate-100 rounded-lg hover:border-amber-500 cursor-pointer transition-colors'}
                    >
                      <OptionIcon className={isSelected ? 'text-amber-500 w-5 h-5' : 'text-slate-500 w-5 h-5'} />
                    </button>
                  );
                })}
              </div>
            </div>

            <div className="rounded-2xl border border-slate-200 bg-white/50 p-5">
              <p className="text-[10px] font-bold uppercase tracking-wider text-slate-400">Xem trước</p>
              <div className="mt-3 flex items-center gap-3">
                <div
                  className="flex h-10 w-10 items-center justify-center rounded-xl"
                  style={{ backgroundColor: `${color}20`, color }}
                >
                  <SelectedIcon className="w-5 h-5" />
                </div>
                <div>
                  <p className="text-sm font-bold text-slate-900">{name.trim() || 'Tên danh mục mới'}</p>
                  <p className="text-xs text-slate-500">{slug || 'slug-danh-muc'} • {isActive ? 'Hiển thị với người dùng' : 'Ẩn với người dùng'}</p>
                </div>
              </div>
            </div>
          </div>

          {/* Footer Actions */}
          <div className="flex flex-col gap-3 border-t border-black/5 bg-slate-50/50 px-4 py-5 sm:flex-row sm:items-center sm:justify-end sm:px-8 sm:py-6">
            <Link
              href="/categories"
              className="px-6 py-2.5 text-center text-sm font-bold text-slate-500 transition-colors hover:text-slate-800"
            >
              Hủy
            </Link>
            <button 
              type="button"
              onClick={handleCreateRequest}
              disabled={isSaving || isLoadingCategory}
              className="rounded-xl bg-amber-500 px-8 py-2.5 text-sm font-bold text-white shadow-[0_4px_12px_rgba(255,184,0,0.3)] transition-all hover:brightness-105 active:scale-95"
            >
              {categoryId ? 'Cập nhật danh mục' : 'Tạo danh mục'}
            </button>
          </div>
        </div>

        {/* Contextual Information Card */}
        <div className="mt-8 grid grid-cols-1 md:grid-cols-3 gap-6">
          <div className="p-5 glass-panel rounded-2xl border border-white/40 flex items-start gap-4">
            <div className="text-amber-500">
              <Info className="w-5 h-5" />
            </div>
            <div>
              <p className="text-xs font-bold text-slate-900 mb-1">Xem trước tác động</p>
              <p className="text-[11px] text-slate-500 leading-relaxed">
                Danh mục này sẽ xuất hiện ngay trong menu lọc của ứng dụng người dùng.
              </p>
            </div>
          </div>
          <div className="p-5 glass-panel rounded-2xl border border-white/40 flex items-start gap-4">
            <div className="text-amber-500">
              <Sparkles className="w-5 h-5" />
            </div>
            <div>
              <p className="text-xs font-bold text-slate-900 mb-1">Gợi ý AI</p>
              <p className="text-[11px] text-slate-500 leading-relaxed">
                Cân nhắc thêm thẻ phụ như &quot;Trong nhà&quot; hoặc &quot;Giải trí đêm&quot; để người dùng dễ khám phá hơn.
              </p>
            </div>
          </div>
          <div className="p-5 glass-panel rounded-2xl border border-white/40 flex items-start gap-4">
            <div className="text-amber-500">
              <BarChart2 className="w-5 h-5" />
            </div>
            <div>
              <p className="text-xs font-bold text-slate-900 mb-1">Phạm vi dự kiến</p>
              <p className="text-[11px] text-slate-500 leading-relaxed">
                Ánh xạ danh mục có thể ảnh hưởng khoảng hơn 450 sự kiện hiện có.
              </p>
            </div>
          </div>
        </div>
      </div>

      <ConfirmActionDialog
        open={isConfirmOpen}
        onOpenChange={setIsConfirmOpen}
        title={categoryId ? 'Xác nhận cập nhật danh mục' : 'Xác nhận tạo danh mục'}
        description={categoryId
          ? 'Bạn sắp cập nhật danh mục này. Thao tác này sẽ thay đổi bộ lọc sự kiện liên quan.'
          : 'Bạn sắp tạo một danh mục mới. Thao tác này sẽ ảnh hưởng đến bộ lọc sự kiện và danh sách hiển thị trên hệ thống.'}
        confirmLabel="Xác nhận"
        cancelLabel="Hủy"
        onConfirm={() => {
          void handleConfirmCreate();
        }}
      />
    </div>
  );
}

function buildSlug(value: string): string {
  return value
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/đ/g, 'd')
    .replace(/Đ/g, 'd')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '');
}

function FieldError({ messages }: { messages?: string[] }) {
  if (!messages || messages.length === 0) {
    return null;
  }

  return (
    <p className="text-xs font-medium text-red-600">
      {messages.join(' ')}
    </p>
  );
}
