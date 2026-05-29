'use client';

import { FormEvent, ReactNode, useCallback, useEffect, useMemo, useState } from 'react';
import Link from 'next/link';
import {
  Archive,
  ArrowLeft,
  BookOpen,
  Eye,
  FileText,
  FolderPlus,
  Layers,
  Pencil,
  Plus,
  RotateCcw,
  Save,
  Search,
  Send,
  Trash2,
  X,
} from 'lucide-react';
import { toast } from 'sonner';
import { AdminSelect, Button, Card, EmptyState, ErrorState } from '@/core/components';
import { runActionWithToast } from '@/core/lib/runActionWithToast';
import { cn } from '@/core/lib/utils';
import {
  archiveHelpCenterArticle,
  createHelpCenterArticle,
  createHelpCenterCategory,
  deleteHelpCenterArticle,
  deleteHelpCenterCategory,
  getHelpCenterArticles,
  getHelpCenterCategories,
  publishHelpCenterArticle,
  updateHelpCenterArticle,
  updateHelpCenterCategory,
  type HelpCenterArticleFilters,
  type SaveHelpCenterArticlePayload,
  type SaveHelpCenterCategoryPayload,
} from '@/features/support/services/support.service';
import type {
  HelpCenterArticle,
  HelpCenterArticleStatus,
  HelpCenterCategory,
  HelpCenterLocale,
} from '@/features/support/types';

type StatusFilter = 'all' | HelpCenterArticleStatus;
type LocaleFilter = 'all' | HelpCenterLocale;
type ActiveSection = 'articles' | 'categories';

interface CategoryFormState {
  id?: string;
  name: string;
  slug: string;
  description: string;
  sortOrder: string;
  isActive: boolean;
}

interface ArticleFormState {
  id?: string;
  categoryId: string;
  title: string;
  slug: string;
  summary: string;
  body: string;
  locale: HelpCenterLocale;
  status: HelpCenterArticleStatus;
  sortOrder: string;
}

const articleStatusOptions = [
  { value: 'all', label: 'Tất cả trạng thái' },
  { value: 'draft', label: 'Bản nháp' },
  { value: 'published', label: 'Đã publish' },
  { value: 'archived', label: 'Đã lưu trữ' },
] as const;

const articleFormStatusOptions = [
  { value: 'draft', label: 'Bản nháp' },
  { value: 'published', label: 'Đã publish' },
  { value: 'archived', label: 'Đã lưu trữ' },
] as const;

const localeFilterOptions = [
  { value: 'all', label: 'Tất cả ngôn ngữ' },
  { value: 'vi', label: 'Tiếng Việt' },
  { value: 'en', label: 'English' },
] as const;

const emptyCategoryForm: CategoryFormState = {
  name: '',
  slug: '',
  description: '',
  sortOrder: '0',
  isActive: true,
};

const emptyArticleForm: ArticleFormState = {
  categoryId: '',
  title: '',
  slug: '',
  summary: '',
  body: '',
  locale: 'vi',
  status: 'draft',
  sortOrder: '0',
};

export default function HelpCenterAdminPage() {
  const [categories, setCategories] = useState<HelpCenterCategory[]>([]);
  const [articles, setArticles] = useState<HelpCenterArticle[]>([]);
  const [selectedArticle, setSelectedArticle] = useState<HelpCenterArticle | null>(null);
  const [activeSection, setActiveSection] = useState<ActiveSection>('articles');
  const [isArticleEditorOpen, setIsArticleEditorOpen] = useState(false);
  const [keyword, setKeyword] = useState('');
  const [status, setStatus] = useState<StatusFilter>('all');
  const [locale, setLocale] = useState<LocaleFilter>('all');
  const [categoryFilter, setCategoryFilter] = useState('all');
  const [categoryForm, setCategoryForm] = useState<CategoryFormState>(emptyCategoryForm);
  const [articleForm, setArticleForm] = useState<ArticleFormState>(emptyArticleForm);
  const [isLoading, setIsLoading] = useState(true);
  const [isSavingCategory, setIsSavingCategory] = useState(false);
  const [isSavingArticle, setIsSavingArticle] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const articleFilters = useMemo<HelpCenterArticleFilters>(
    () => ({
      status: status === 'all' ? undefined : status,
      locale: locale === 'all' ? undefined : locale,
      categoryId: categoryFilter === 'all' ? undefined : categoryFilter,
    }),
    [categoryFilter, locale, status]
  );

  const categoryOptions = useMemo(
    () => [
      { value: 'all', label: 'Tất cả danh mục' },
      ...categories.map((category) => ({
        value: category.id,
        label: category.name,
      })),
    ],
    [categories]
  );

  const articleCategoryOptions = useMemo(
    () =>
      categories.map((category) => ({
        value: category.id,
        label: category.name,
        description: category.isActive ? undefined : 'Đang tắt',
      })),
    [categories]
  );

  const filteredArticles = useMemo(() => {
    const query = keyword.trim().toLowerCase();
    if (!query) return articles;

    return articles.filter((article) =>
      [article.title, article.slug, article.summary, article.body, article.category.name]
        .join(' ')
        .toLowerCase()
        .includes(query)
    );
  }, [articles, keyword]);

  const stats = useMemo(
    () => ({
      categories: categories.length,
      published: articles.filter((article) => article.status === 'published').length,
      drafts: articles.filter((article) => article.status === 'draft').length,
      archived: articles.filter((article) => article.status === 'archived').length,
    }),
    [articles, categories.length]
  );

  const loadData = useCallback(async () => {
    try {
      setIsLoading(true);
      setError(null);
      const [nextCategories, nextArticles] = await Promise.all([
        getHelpCenterCategories(),
        getHelpCenterArticles(articleFilters),
      ]);

      setCategories(nextCategories);
      setArticles(nextArticles);
      setArticleForm((current) => ({
        ...current,
        categoryId: current.categoryId || nextCategories[0]?.id || '',
      }));
      setSelectedArticle((current) =>
        current ? nextArticles.find((article) => article.id === current.id) ?? null : null
      );
    } catch (loadError) {
      setError(loadError instanceof Error ? loadError.message : 'Không thể tải Help Center.');
    } finally {
      setIsLoading(false);
    }
  }, [articleFilters]);

  useEffect(() => {
    void loadData();
  }, [loadData]);

  const resetCategoryForm = () => {
    setActiveSection('categories');
    setCategoryForm(emptyCategoryForm);
  };

  const resetArticleForm = () => {
    setActiveSection('articles');
    setIsArticleEditorOpen(true);
    setSelectedArticle(null);
    setArticleForm({
      ...emptyArticleForm,
      categoryId: categories[0]?.id || '',
    });
  };

  const closeArticleEditor = () => {
    setIsArticleEditorOpen(false);
    setSelectedArticle(null);
    setArticleForm({
      ...emptyArticleForm,
      categoryId: categories[0]?.id || '',
    });
  };

  const handleEditCategory = (category: HelpCenterCategory) => {
    setActiveSection('categories');
    setCategoryForm({
      id: category.id,
      name: category.name,
      slug: category.slug,
      description: category.description,
      sortOrder: String(category.sortOrder),
      isActive: category.isActive,
    });
  };

  const handleEditArticle = (article: HelpCenterArticle) => {
    setActiveSection('articles');
    setIsArticleEditorOpen(true);
    setSelectedArticle(article);
    setArticleForm({
      id: article.id,
      categoryId: article.category.id,
      title: article.title,
      slug: article.slug,
      summary: article.summary,
      body: article.body,
      locale: 'vi',
      status: article.status,
      sortOrder: String(article.sortOrder),
    });
  };

  const handleSaveCategory = async (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();

    const payload = buildCategoryPayload(categoryForm);
    if (!payload) return;

    setIsSavingCategory(true);
    try {
      await runActionWithToast(
        () =>
          categoryForm.id
            ? updateHelpCenterCategory(categoryForm.id, payload)
            : createHelpCenterCategory(payload),
        {
          loading: categoryForm.id ? 'Đang cập nhật danh mục...' : 'Đang tạo danh mục...',
          success: categoryForm.id ? 'Đã cập nhật danh mục.' : 'Đã tạo danh mục.',
          error: 'Không thể lưu danh mục.',
        }
      );
      resetCategoryForm();
      await loadData();
    } finally {
      setIsSavingCategory(false);
    }
  };

  const handleSaveArticle = async (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();

    const payload = buildArticlePayload(articleForm);
    if (!payload) return;

    setIsSavingArticle(true);
    try {
      const savedArticle = await runActionWithToast(
        () =>
          articleForm.id
            ? updateHelpCenterArticle(articleForm.id, payload)
            : createHelpCenterArticle(payload),
        {
          loading: articleForm.id ? 'Đang cập nhật bài viết...' : 'Đang tạo bài viết...',
          success: articleForm.id ? 'Đã cập nhật bài viết.' : 'Đã tạo bài viết.',
          error: 'Không thể lưu bài viết.',
        }
      );
      setSelectedArticle(savedArticle);
      setArticleForm((current) => ({ ...current, id: savedArticle.id }));
      await loadData();
    } finally {
      setIsSavingArticle(false);
    }
  };

  const handleDeleteCategory = async (category: HelpCenterCategory) => {
    if (!window.confirm(`Xóa danh mục "${category.name}"? Các bài viết trong danh mục có thể bị ảnh hưởng.`)) {
      return;
    }

    await runActionWithToast(() => deleteHelpCenterCategory(category.id), {
      loading: 'Đang xóa danh mục...',
      success: 'Đã xóa danh mục.',
      error: 'Không thể xóa danh mục.',
    });
    if (categoryForm.id === category.id) resetCategoryForm();
    await loadData();
  };

  const handleDeleteArticle = async (article: HelpCenterArticle) => {
    if (!window.confirm(`Xóa bài viết "${article.title}"?`)) {
      return;
    }

    await runActionWithToast(() => deleteHelpCenterArticle(article.id), {
      loading: 'Đang xóa bài viết...',
      success: 'Đã xóa bài viết.',
      error: 'Không thể xóa bài viết.',
    });
    if (selectedArticle?.id === article.id) resetArticleForm();
    await loadData();
  };

  const handlePublishArticle = async (article: HelpCenterArticle) => {
    const published = await runActionWithToast(() => publishHelpCenterArticle(article.id), {
      loading: 'Đang publish bài viết...',
      success: 'Đã publish bài viết.',
      error: 'Không thể publish bài viết.',
    });
    setSelectedArticle(published);
    await loadData();
  };

  const handleArchiveArticle = async (article: HelpCenterArticle) => {
    const archived = await runActionWithToast(() => archiveHelpCenterArticle(article.id), {
      loading: 'Đang lưu trữ bài viết...',
      success: 'Đã lưu trữ bài viết.',
      error: 'Không thể lưu trữ bài viết.',
    });
    setSelectedArticle(archived);
    await loadData();
  };

  return (
    <div className="mx-auto flex w-full max-w-7xl flex-col gap-6 pb-24">
      <div className="flex flex-col gap-4 lg:flex-row lg:items-end lg:justify-between">
        <div className="min-w-0">
          <Link
            href="/support"
            className="mb-3 inline-flex items-center gap-2 text-sm font-bold text-slate-500 transition hover:text-amber-600"
          >
            <ArrowLeft className="h-4 w-4" />
            Ticket hỗ trợ
          </Link>
          <h1 className="text-2xl font-bold tracking-tight text-on-surface">Help Center</h1>
          <p className="mt-1 max-w-2xl text-sm font-medium text-on-surface-variant">
            Tách luồng bài viết và danh mục để quản trị nội dung mobile rõ ràng hơn.
          </p>
        </div>
        <div className="flex flex-wrap gap-3">
          <Button
            type="button"
            variant="outline"
            leftIcon={<RotateCcw className="h-4 w-4" />}
            onClick={() => {
              void loadData();
            }}
          >
            Làm mới
          </Button>
          <Link
            href="/support/legal-documents"
            className="inline-flex h-10 items-center justify-center gap-2 rounded-xl border-2 border-slate-200 bg-transparent px-4 text-sm font-semibold text-slate-700 transition hover:border-slate-300 hover:bg-slate-50"
          >
            <FileText className="h-4 w-4" />
            Tài liệu pháp lý
          </Link>
        </div>
      </div>

      <div className="grid gap-3 sm:grid-cols-2 xl:grid-cols-4">
        <Metric label="Danh mục" value={stats.categories} />
        <Metric label="Đã publish" value={stats.published} />
        <Metric label="Bản nháp" value={stats.drafts} />
        <Metric label="Lưu trữ" value={stats.archived} />
      </div>

      <Card className="grid gap-3 border border-white/70 bg-white/80 p-2 shadow-sm backdrop-blur-xl md:grid-cols-2">
        <SectionTab
          active={activeSection === 'articles'}
          icon={<BookOpen className="h-5 w-5" />}
          title="Bài viết"
          description="Soạn, lọc, publish và lưu trữ nội dung FAQ."
          count={articles.length}
          onClick={() => setActiveSection('articles')}
        />
        <SectionTab
          active={activeSection === 'categories'}
          icon={<Layers className="h-5 w-5" />}
          title="Danh mục"
          description="Quản lý taxonomy trước khi gắn bài viết."
          count={categories.length}
          onClick={() => setActiveSection('categories')}
        />
      </Card>

      {error ? (
        <ErrorState
          title="Không thể tải Help Center"
          message={error}
          retryLabel="Tải lại"
          onRetry={() => {
            void loadData();
          }}
        />
      ) : null}

      {!error && activeSection === 'articles' ? (
        <section className="space-y-5">
          <Card className="relative z-40 border border-white/70 bg-white/80 p-4 shadow-sm backdrop-blur-xl">
            <div className="grid gap-3 lg:grid-cols-[minmax(12rem,1fr)_10rem_10rem_13rem]">
              <label className="relative block">
                <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-slate-400" />
                <input
                  value={keyword}
                  onChange={(event) => setKeyword(event.target.value)}
                  className="h-10 w-full rounded-xl border border-slate-200 bg-white pl-10 pr-3 text-sm font-medium text-slate-800 outline-none transition focus:border-amber-500 focus:ring-4 focus:ring-amber-500/10"
                  placeholder="Tìm bài viết, slug, nội dung"
                />
              </label>
              <AdminSelect
                value={status}
                onChange={setStatus}
                options={articleStatusOptions}
                ariaLabel="Lọc trạng thái"
              />
              {/* <AdminSelect
                value={locale}
                onChange={setLocale}
                options={localeFilterOptions}
                ariaLabel="Lọc ngôn ngữ"
              /> */}
              <AdminSelect
                value={categoryFilter}
                onChange={setCategoryFilter}
                options={categoryOptions}
                ariaLabel="Lọc danh mục"
              />
            </div>
          </Card>

          <div className={cn('grid gap-5', isArticleEditorOpen && '2xl:grid-cols-[minmax(0,1fr)_30rem]')}>
            <Card className="overflow-hidden border border-white/70 bg-white/80 shadow-sm backdrop-blur-xl">
              <div className="flex flex-col gap-3 border-b border-slate-100 px-5 py-4 sm:flex-row sm:items-center sm:justify-between">
                <div>
                  <p className="text-xs font-bold uppercase tracking-widest text-slate-500">Bài viết</p>
                  <p className="mt-1 text-sm text-slate-600">
                    {filteredArticles.length.toLocaleString('vi-VN')} bài phù hợp
                  </p>
                </div>
                <Button type="button" size="sm" leftIcon={<Plus className="h-4 w-4" />} onClick={resetArticleForm}>
                  Bài mới
                </Button>
              </div>

              {isLoading ? (
                <div className="space-y-3 p-5">
                  {Array.from({ length: 4 }).map((_, index) => (
                    <div key={index} className="h-24 animate-pulse rounded-xl bg-slate-100" />
                  ))}
                </div>
              ) : filteredArticles.length === 0 ? (
                <EmptyState
                  title="Chưa có bài viết phù hợp"
                  description="Tạo bài viết mới hoặc thay đổi bộ lọc để xem thêm nội dung."
                  className="m-5 bg-white/60"
                />
              ) : (
                <div className="divide-y divide-slate-100">
                  {filteredArticles.map((article) => (
                    <ArticleRow
                      key={article.id}
                      article={article}
                      selected={selectedArticle?.id === article.id}
                      onEdit={() => handleEditArticle(article)}
                      onDelete={() => {
                        void handleDeleteArticle(article);
                      }}
                      onPublish={() => {
                        void handlePublishArticle(article);
                      }}
                      onArchive={() => {
                        void handleArchiveArticle(article);
                      }}
                    />
                  ))}
                </div>
              )}
            </Card>

            {isArticleEditorOpen ? (
              <Card className="border border-white/70 bg-white/80 p-5 shadow-sm backdrop-blur-xl">
                <div className="mb-4 flex items-start justify-between gap-3">
                  <div>
                    <p className="text-xs font-bold uppercase tracking-widest text-slate-500">Editor bài viết</p>
                    <p className="mt-1 text-sm text-slate-600">
                      {articleForm.id ? 'Cập nhật bài viết hiện có.' : 'Tạo bài viết Help Center mới.'}
                    </p>
                  </div>
                  <div className="flex items-center gap-2">
                    {selectedArticle ? (
                      <span className={cn('rounded-full px-2.5 py-1 text-[11px] font-bold', statusClass(selectedArticle.status))}>
                        {statusLabel(selectedArticle.status)}
                      </span>
                    ) : null}
                    <button
                      type="button"
                      onClick={closeArticleEditor}
                      className="inline-flex h-8 w-8 items-center justify-center rounded-lg text-slate-400 transition hover:bg-slate-100 hover:text-slate-700"
                      title="Đóng editor"
                    >
                      <X className="h-4 w-4" />
                    </button>
                  </div>
                </div>

                <form className="space-y-3" onSubmit={handleSaveArticle}>
                  <AdminSelect
                    value={articleForm.categoryId || articleCategoryOptions[0]?.value}
                    onChange={(value) => setArticleForm((current) => ({ ...current, categoryId: value }))}
                    options={articleCategoryOptions}
                    placeholder="Chọn danh mục"
                    ariaLabel="Danh mục bài viết"
                    disabled={articleCategoryOptions.length === 0}
                  />
                  <Field
                    label="Tiêu đề"
                    value={articleForm.title}
                    onChange={(value) =>
                      setArticleForm((current) => ({
                        ...current,
                        title: value,
                        slug: current.slug || toSlug(value),
                      }))
                    }
                  />
                  <Field
                    label="Slug"
                    value={articleForm.slug}
                    onChange={(value) => setArticleForm((current) => ({ ...current, slug: toSlug(value) }))}
                  />
                  <TextArea
                    label="Tóm tắt"
                    value={articleForm.summary}
                    rows={3}
                    onChange={(value) => setArticleForm((current) => ({ ...current, summary: value }))}
                  />
                  <TextArea
                    label="Nội dung"
                    value={articleForm.body}
                    rows={9}
                    onChange={(value) => setArticleForm((current) => ({ ...current, body: value }))}
                  />
                  <div className="grid gap-3 sm:grid-cols-2">
                    <SelectField label="Trạng thái">
                      <AdminSelect
                        value={articleForm.status}
                        onChange={(value) => setArticleForm((current) => ({ ...current, status: value }))}
                        options={articleFormStatusOptions}
                        ariaLabel="Trạng thái bài viết"
                      />
                    </SelectField>
                    <Field
                      label="Thứ tự"
                      type="number"
                      value={articleForm.sortOrder}
                      onChange={(value) => setArticleForm((current) => ({ ...current, sortOrder: value }))}
                    />
                  </div>
                  <Button
                    type="submit"
                    className="w-full"
                    disabled={articleCategoryOptions.length === 0}
                    isLoading={isSavingArticle}
                    leftIcon={<Save className="h-4 w-4" />}
                  >
                    {articleForm.id ? 'Lưu bài viết' : 'Tạo bài viết'}
                  </Button>
                </form>

                <div className="mt-5 border-t border-slate-100 pt-5">
                  <p className="mb-3 flex items-center gap-2 text-xs font-bold uppercase tracking-widest text-slate-500">
                    <Eye className="h-4 w-4" />
                    Preview
                  </p>
                  <article className="rounded-2xl border border-slate-100 bg-white/70 p-4">
                    <p className="text-xs font-bold uppercase tracking-widest text-amber-600">
                      {articleCategoryOptions.find((option) => option.value === articleForm.categoryId)?.label ||
                        'Chưa chọn danh mục'}
                    </p>
                    <h2 className="mt-2 text-lg font-black text-slate-950">
                      {articleForm.title || 'Tiêu đề bài viết'}
                    </h2>
                    <p className="mt-2 text-sm font-medium text-slate-600">
                      {articleForm.summary || 'Tóm tắt sẽ hiển thị ở đây.'}
                    </p>
                    <p className="mt-4 whitespace-pre-wrap text-sm leading-6 text-slate-700">
                      {articleForm.body || 'Nội dung bài viết sẽ hiển thị ở đây.'}
                    </p>
                  </article>
                </div>
              </Card>
            ) : null}
          </div>
        </section>
      ) : null}

      {!error && activeSection === 'categories' ? (
        <section className="grid gap-5 xl:grid-cols-[minmax(0,1fr)_25rem]">
          <Card className="overflow-hidden border border-white/70 bg-white/80 shadow-sm backdrop-blur-xl">
            <div className="flex flex-col gap-3 border-b border-slate-100 px-5 py-4 sm:flex-row sm:items-center sm:justify-between">
              <div>
                <p className="text-xs font-bold uppercase tracking-widest text-slate-500">Danh mục</p>
                <p className="mt-1 text-sm text-slate-600">Taxonomy riêng cho Help Center.</p>
              </div>
              <Button type="button" size="sm" variant="outline" leftIcon={<FolderPlus className="h-4 w-4" />} onClick={resetCategoryForm}>
                Danh mục mới
              </Button>
            </div>

            {isLoading ? (
              <div className="space-y-2 p-5">
                {Array.from({ length: 4 }).map((_, index) => (
                  <div key={index} className="h-16 animate-pulse rounded-xl bg-slate-100" />
                ))}
              </div>
            ) : categories.length === 0 ? (
              <EmptyState
                title="Chưa có danh mục"
                description="Tạo danh mục đầu tiên trước khi viết bài Help Center."
                className="m-5 bg-white/60"
              />
            ) : (
              <div className="divide-y divide-slate-100">
                {categories.map((category) => (
                  <div key={category.id} className="grid gap-3 px-5 py-4 lg:grid-cols-[minmax(0,1fr)_8rem_auto]">
                    <button type="button" onClick={() => handleEditCategory(category)} className="min-w-0 text-left">
                      <div className="flex flex-wrap items-center gap-2">
                        <span className="truncate text-base font-bold text-slate-900">{category.name}</span>
                        <span
                          className={cn(
                            'rounded-full px-2 py-0.5 text-[11px] font-bold',
                            category.isActive ? 'bg-emerald-100 text-emerald-700' : 'bg-slate-100 text-slate-600'
                          )}
                        >
                          {category.isActive ? 'Đang bật' : 'Đang tắt'}
                        </span>
                      </div>
                      <p className="mt-1 truncate text-sm font-medium text-slate-500">{category.slug}</p>
                      {category.description ? (
                        <p className="mt-2 line-clamp-2 text-sm text-slate-600">{category.description}</p>
                      ) : null}
                    </button>
                    <p className="text-sm font-medium text-slate-600">
                      Thứ tự <span className="font-bold text-slate-900">{category.sortOrder}</span>
                    </p>
                    <div className="flex items-center gap-2 lg:justify-end">
                      <IconButton title="Sửa" onClick={() => handleEditCategory(category)}>
                        <Pencil className="h-4 w-4" />
                      </IconButton>
                      <IconButton
                        title="Xóa"
                        danger
                        onClick={() => {
                          void handleDeleteCategory(category);
                        }}
                      >
                        <Trash2 className="h-4 w-4" />
                      </IconButton>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </Card>

          <Card className="border border-white/70 bg-white/80 p-5 shadow-sm backdrop-blur-xl">
            <div className="mb-4">
              <p className="text-xs font-bold uppercase tracking-widest text-slate-500">
                {categoryForm.id ? 'Sửa danh mục' : 'Tạo danh mục'}
              </p>
              <p className="mt-1 text-sm text-slate-600">Danh mục giúp nhóm các câu hỏi thường gặp trên mobile.</p>
            </div>

            <form className="space-y-3" onSubmit={handleSaveCategory}>
              <Field
                label="Tên danh mục"
                value={categoryForm.name}
                onChange={(value) =>
                  setCategoryForm((current) => ({
                    ...current,
                    name: value,
                    slug: current.slug || toSlug(value),
                  }))
                }
              />
              <Field
                label="Slug"
                value={categoryForm.slug}
                onChange={(value) => setCategoryForm((current) => ({ ...current, slug: toSlug(value) }))}
              />
              <TextArea
                label="Mô tả"
                value={categoryForm.description}
                rows={4}
                onChange={(value) => setCategoryForm((current) => ({ ...current, description: value }))}
              />
              <div className="grid grid-cols-[1fr_auto] items-end gap-3">
                <Field
                  label="Thứ tự"
                  type="number"
                  value={categoryForm.sortOrder}
                  onChange={(value) => setCategoryForm((current) => ({ ...current, sortOrder: value }))}
                />
                <label className="flex h-11 items-center gap-2 rounded-xl border border-slate-200 bg-white px-3 text-sm font-bold text-slate-700">
                  <input
                    type="checkbox"
                    checked={categoryForm.isActive}
                    onChange={(event) =>
                      setCategoryForm((current) => ({ ...current, isActive: event.target.checked }))
                    }
                    className="h-4 w-4 accent-amber-500"
                  />
                  Bật
                </label>
              </div>
              <Button
                type="submit"
                className="w-full"
                isLoading={isSavingCategory}
                leftIcon={categoryForm.id ? <Save className="h-4 w-4" /> : <FolderPlus className="h-4 w-4" />}
              >
                {categoryForm.id ? 'Lưu danh mục' : 'Tạo danh mục'}
              </Button>
            </form>
          </Card>
        </section>
      ) : null}
    </div>
  );
}

function Metric({ label, value }: { label: string; value: number }) {
  return (
    <Card className="border border-white/70 bg-white/80 p-5 shadow-sm backdrop-blur-xl">
      <p className="text-[10px] font-bold uppercase tracking-widest text-slate-500">{label}</p>
      <p className="mt-3 text-2xl font-black text-slate-950">{value.toLocaleString('vi-VN')}</p>
    </Card>
  );
}

function SectionTab({
  active,
  icon,
  title,
  description,
  count,
  onClick,
}: {
  active: boolean;
  icon: ReactNode;
  title: string;
  description: string;
  count: number;
  onClick: () => void;
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      className={cn(
        'flex items-start gap-3 rounded-2xl border p-4 text-left transition',
        active
          ? 'border-amber-200 bg-amber-50 text-amber-950 shadow-sm'
          : 'border-transparent text-slate-700 hover:border-slate-200 hover:bg-white'
      )}
    >
      <span
        className={cn(
          'inline-flex h-10 w-10 shrink-0 items-center justify-center rounded-xl',
          active ? 'bg-amber-100 text-amber-700' : 'bg-slate-100 text-slate-500'
        )}
      >
        {icon}
      </span>
      <span className="min-w-0 flex-1">
        <span className="flex items-center justify-between gap-3">
          <span className="text-sm font-black">{title}</span>
          <span className="rounded-full bg-white/80 px-2 py-0.5 text-xs font-bold text-slate-600">
            {count.toLocaleString('vi-VN')}
          </span>
        </span>
        <span className="mt-1 block text-sm font-medium text-slate-600">{description}</span>
      </span>
    </button>
  );
}

function ArticleRow({
  article,
  selected,
  onEdit,
  onDelete,
  onPublish,
  onArchive,
}: {
  article: HelpCenterArticle;
  selected: boolean;
  onEdit: () => void;
  onDelete: () => void;
  onPublish: () => void;
  onArchive: () => void;
}) {
  return (
    <article className={cn('grid gap-4 px-5 py-4 transition lg:grid-cols-[minmax(0,1fr)_12rem_auto]', selected ? 'bg-amber-50/70' : 'hover:bg-white/80')}>
      <button type="button" onClick={onEdit} className="min-w-0 text-left">
        <div className="flex flex-wrap items-center gap-2">
          <h2 className="min-w-0 truncate text-base font-bold text-slate-950">{article.title}</h2>
          <span className={cn('rounded-full px-2.5 py-1 text-[11px] font-bold', statusClass(article.status))}>
            {statusLabel(article.status)}
          </span>
        </div>
        <p className="mt-2 line-clamp-2 text-sm text-slate-600">{article.summary}</p>
        <div className="mt-3 flex flex-wrap gap-x-4 gap-y-1 text-xs font-medium text-slate-500">
          <span>{article.category.name}</span>
          <span>{article.locale.toUpperCase()}</span>
          <span>{article.slug}</span>
        </div>
      </button>

      <div className="space-y-1 text-sm text-slate-600">
        <p>Thứ tự: <span className="font-bold text-slate-900">{article.sortOrder}</span></p>
        <p>Publish: <span className="font-bold text-slate-900">{article.publishedAt ? formatDate(article.publishedAt) : 'Chưa publish'}</span></p>
      </div>

      <div className="flex flex-wrap items-center gap-2 lg:justify-end">
        <IconButton title="Sửa" onClick={onEdit}>
          <Pencil className="h-4 w-4" />
        </IconButton>
        {article.status !== 'published' ? (
          <IconButton title="Publish" onClick={onPublish}>
            <Send className="h-4 w-4" />
          </IconButton>
        ) : (
          <IconButton title="Lưu trữ" onClick={onArchive}>
            <Archive className="h-4 w-4" />
          </IconButton>
        )}
        <IconButton title="Xóa" danger onClick={onDelete}>
          <Trash2 className="h-4 w-4" />
        </IconButton>
      </div>
    </article>
  );
}

function IconButton({
  title,
  danger = false,
  onClick,
  children,
}: {
  title: string;
  danger?: boolean;
  onClick: () => void;
  children: ReactNode;
}) {
  return (
    <button
      type="button"
      title={title}
      onClick={onClick}
      className={cn(
        'inline-flex h-9 w-9 items-center justify-center rounded-xl border border-slate-200 bg-white text-slate-500 transition hover:border-amber-300 hover:text-amber-600',
        danger && 'hover:border-red-200 hover:bg-red-50 hover:text-red-600'
      )}
    >
      {children}
    </button>
  );
}

function Field({
  label,
  value,
  type = 'text',
  onChange,
}: {
  label: string;
  value: string;
  type?: 'text' | 'number';
  onChange: (value: string) => void;
}) {
  return (
    <label className="block space-y-2">
      <span className="ml-1 text-xs font-bold uppercase tracking-widest text-slate-500">{label}</span>
      <input
        type={type}
        value={value}
        onChange={(event) => onChange(event.target.value)}
        className="h-11 w-full rounded-xl border border-slate-200 bg-white px-3 text-sm font-medium text-slate-800 outline-none transition focus:border-amber-500 focus:ring-4 focus:ring-amber-500/10"
      />
    </label>
  );
}

function SelectField({ label, children }: { label: string; children: ReactNode }) {
  return (
    <label className="block space-y-2">
      <span className="ml-1 text-xs font-bold uppercase tracking-widest text-slate-500">{label}</span>
      {children}
    </label>
  );
}

function TextArea({
  label,
  value,
  rows,
  onChange,
}: {
  label: string;
  value: string;
  rows: number;
  onChange: (value: string) => void;
}) {
  return (
    <label className="block space-y-2">
      <span className="ml-1 text-xs font-bold uppercase tracking-widest text-slate-500">{label}</span>
      <textarea
        value={value}
        rows={rows}
        onChange={(event) => onChange(event.target.value)}
        className="w-full resize-y rounded-xl border border-slate-200 bg-white px-3 py-3 text-sm font-medium leading-6 text-slate-800 outline-none transition focus:border-amber-500 focus:ring-4 focus:ring-amber-500/10"
      />
    </label>
  );
}

function buildCategoryPayload(form: CategoryFormState): SaveHelpCenterCategoryPayload | null {
  if (!form.name.trim()) {
    toast.error('Vui lòng nhập tên danh mục.');
    return null;
  }

  if (!form.slug.trim()) {
    toast.error('Vui lòng nhập slug danh mục.');
    return null;
  }

  return {
    name: form.name.trim(),
    slug: form.slug.trim(),
    description: form.description.trim(),
    sortOrder: Number(form.sortOrder || 0),
    isActive: form.isActive,
  };
}

function buildArticlePayload(form: ArticleFormState): SaveHelpCenterArticlePayload | null {
  if (!form.categoryId) {
    toast.error('Vui lòng chọn danh mục.');
    return null;
  }

  if (!form.title.trim() || !form.slug.trim() || !form.summary.trim() || !form.body.trim()) {
    toast.error('Vui lòng nhập đầy đủ tiêu đề, slug, tóm tắt và nội dung.');
    return null;
  }

  return {
    categoryId: form.categoryId,
    title: form.title.trim(),
    slug: form.slug.trim(),
    summary: form.summary.trim(),
    body: form.body.trim(),
    locale: form.locale,
    status: form.status,
    sortOrder: Number(form.sortOrder || 0),
  };
}

function toSlug(value: string): string {
  return value
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .replace(/đ/g, 'd')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '');
}

function statusLabel(status: HelpCenterArticleStatus): string {
  const labels: Record<HelpCenterArticleStatus, string> = {
    draft: 'Bản nháp',
    published: 'Đã publish',
    archived: 'Lưu trữ',
  };
  return labels[status];
}

function statusClass(status: HelpCenterArticleStatus): string {
  const classes: Record<HelpCenterArticleStatus, string> = {
    draft: 'bg-slate-100 text-slate-700',
    published: 'bg-emerald-100 text-emerald-700',
    archived: 'bg-amber-100 text-amber-700',
  };
  return classes[status];
}

function formatDate(value: string): string {
  return new Intl.DateTimeFormat('vi-VN', {
    dateStyle: 'short',
    timeStyle: 'short',
  }).format(new Date(value));
}
