'use client';

import { FormEvent, ReactNode, useCallback, useEffect, useMemo, useState } from 'react';
import Link from 'next/link';
import { Archive, ArrowLeft, FileText, Pencil, Plus, RotateCcw, Save, Send, Trash2 } from 'lucide-react';
import { toast } from 'sonner';
import { AdminSelect, Button, Card, EmptyState, ErrorState } from '@/core/components';
import { runActionWithToast } from '@/core/lib/runActionWithToast';
import { cn } from '@/core/lib/utils';
import {
  archiveLegalDocument,
  createLegalDocument,
  deleteLegalDocument,
  getLegalDocuments,
  publishLegalDocument,
  updateLegalDocument,
  type LegalDocumentFilters,
  type SaveLegalDocumentPayload,
} from '@/features/support/services/support.service';
import type {
  HelpCenterLocale,
  LegalDocument,
  LegalDocumentStatus,
  LegalDocumentType,
} from '@/features/support/types';

type StatusFilter = 'all' | LegalDocumentStatus;
type TypeFilter = 'all' | LegalDocumentType;
type LocaleFilter = 'all' | HelpCenterLocale;

interface LegalDocumentFormState {
  id?: string;
  documentType: LegalDocumentType;
  title: string;
  version: string;
  summary: string;
  body: string;
  locale: HelpCenterLocale;
  status: LegalDocumentStatus;
}

const documentTypeOptions = [
  { value: 'privacy_policy', label: 'Chính sách quyền riêng tư' },
  { value: 'terms_of_service', label: 'Điều khoản dịch vụ' },
] as const;

const typeFilterOptions = [
  { value: 'all', label: 'Tất cả loại tài liệu' },
  ...documentTypeOptions,
] as const;

const statusOptions = [
  { value: 'all', label: 'Tất cả trạng thái' },
  { value: 'draft', label: 'Bản nháp' },
  { value: 'published', label: 'Đã publish' },
  { value: 'archived', label: 'Đã lưu trữ' },
] as const;

const formStatusOptions = [
  { value: 'draft', label: 'Bản nháp' },
  { value: 'published', label: 'Đã publish' },
  { value: 'archived', label: 'Đã lưu trữ' },
] as const;

const localeOptions = [
  { value: 'all', label: 'Tất cả ngôn ngữ' },
  { value: 'vi', label: 'Tiếng Việt' },
  { value: 'en', label: 'English' },
] as const;

const formLocaleOptions = [
  { value: 'vi', label: 'Tiếng Việt' },
  { value: 'en', label: 'English' },
] as const;

const emptyForm: LegalDocumentFormState = {
  documentType: 'privacy_policy',
  title: '',
  version: '',
  summary: '',
  body: '',
  locale: 'vi',
  status: 'draft',
};

export default function LegalDocumentsPage() {
  const [documents, setDocuments] = useState<LegalDocument[]>([]);
  const [selectedDocument, setSelectedDocument] = useState<LegalDocument | null>(null);
  const [typeFilter, setTypeFilter] = useState<TypeFilter>('all');
  const [status, setStatus] = useState<StatusFilter>('all');
  const [locale, setLocale] = useState<LocaleFilter>('all');
  const [form, setForm] = useState<LegalDocumentFormState>(emptyForm);
  const [isLoading, setIsLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const filters = useMemo<LegalDocumentFilters>(
    () => ({
      documentType: typeFilter === 'all' ? undefined : typeFilter,
      status: status === 'all' ? undefined : status,
      locale: locale === 'all' ? undefined : locale,
    }),
    [locale, status, typeFilter]
  );

  const stats = useMemo(
    () => ({
      total: documents.length,
      published: documents.filter((document) => document.status === 'published').length,
      drafts: documents.filter((document) => document.status === 'draft').length,
      archived: documents.filter((document) => document.status === 'archived').length,
    }),
    [documents]
  );

  const loadData = useCallback(async () => {
    try {
      setIsLoading(true);
      setError(null);
      const nextDocuments = await getLegalDocuments(filters);
      setDocuments(nextDocuments);
      setSelectedDocument((current) =>
        current ? nextDocuments.find((document) => document.id === current.id) ?? null : null
      );
    } catch (loadError) {
      setError(loadError instanceof Error ? loadError.message : 'Không thể tải tài liệu pháp lý.');
    } finally {
      setIsLoading(false);
    }
  }, [filters]);

  useEffect(() => {
    void loadData();
  }, [loadData]);

  const resetForm = () => {
    setSelectedDocument(null);
    setForm(emptyForm);
  };

  const handleEdit = (document: LegalDocument) => {
    setSelectedDocument(document);
    setForm({
      id: document.id,
      documentType: document.documentType,
      title: document.title,
      version: document.version,
      summary: document.summary,
      body: document.body,
      locale: document.locale,
      status: document.status,
    });
  };

  const handleSave = async (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    const payload = buildPayload(form);
    if (!payload) return;

    setIsSaving(true);
    try {
      const savedDocument = await runActionWithToast(
        () => (form.id ? updateLegalDocument(form.id, payload) : createLegalDocument(payload)),
        {
          loading: form.id ? 'Đang cập nhật tài liệu...' : 'Đang tạo tài liệu...',
          success: form.id ? 'Đã cập nhật tài liệu.' : 'Đã tạo tài liệu.',
          error: 'Không thể lưu tài liệu pháp lý.',
        }
      );
      setSelectedDocument(savedDocument);
      setForm((current) => ({ ...current, id: savedDocument.id }));
      await loadData();
    } finally {
      setIsSaving(false);
    }
  };

  const handleDelete = async (document: LegalDocument) => {
    if (!window.confirm(`Xóa tài liệu "${document.title}" phiên bản ${document.version}?`)) {
      return;
    }

    await runActionWithToast(() => deleteLegalDocument(document.id), {
      loading: 'Đang xóa tài liệu...',
      success: 'Đã xóa tài liệu.',
      error: 'Không thể xóa tài liệu pháp lý.',
    });
    if (selectedDocument?.id === document.id) resetForm();
    await loadData();
  };

  const handlePublish = async (document: LegalDocument) => {
    const published = await runActionWithToast(() => publishLegalDocument(document.id), {
      loading: 'Đang publish tài liệu...',
      success: 'Đã publish tài liệu.',
      error: 'Không thể publish tài liệu pháp lý.',
    });
    setSelectedDocument(published);
    await loadData();
  };

  const handleArchive = async (document: LegalDocument) => {
    const archived = await runActionWithToast(() => archiveLegalDocument(document.id), {
      loading: 'Đang lưu trữ tài liệu...',
      success: 'Đã lưu trữ tài liệu.',
      error: 'Không thể lưu trữ tài liệu pháp lý.',
    });
    setSelectedDocument(archived);
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
          <h1 className="text-2xl font-bold tracking-tight text-on-surface">Tài liệu pháp lý</h1>
          <p className="mt-1 max-w-2xl text-sm font-medium text-on-surface-variant">
            Publish chính sách quyền riêng tư và điều khoản để mobile đọc trực tiếp từ backend.
          </p>
        </div>
        <Button type="button" variant="outline" leftIcon={<RotateCcw className="h-4 w-4" />} onClick={() => void loadData()}>
          Làm mới
        </Button>
      </div>

      <div className="grid gap-3 sm:grid-cols-2 xl:grid-cols-4">
        <Metric label="Tổng tài liệu" value={stats.total} />
        <Metric label="Đã publish" value={stats.published} />
        <Metric label="Bản nháp" value={stats.drafts} />
        <Metric label="Lưu trữ" value={stats.archived} />
      </div>

      {error ? (
        <ErrorState
          title="Không thể tải tài liệu pháp lý"
          message={error}
          retryLabel="Tải lại"
          onRetry={() => void loadData()}
        />
      ) : null}

      {!error ? (
        <div className="grid gap-5 xl:grid-cols-[minmax(0,1fr)_28rem]">
          <section className="space-y-4">
            <Card className="relative z-40 border border-white/70 bg-white/80 p-4 shadow-sm backdrop-blur-xl">
              <div className="grid gap-3 md:grid-cols-3">
                <AdminSelect value={typeFilter} onChange={setTypeFilter} options={typeFilterOptions} ariaLabel="Lọc loại tài liệu" />
                <AdminSelect value={status} onChange={setStatus} options={statusOptions} ariaLabel="Lọc trạng thái" />
                <AdminSelect value={locale} onChange={setLocale} options={localeOptions} ariaLabel="Lọc ngôn ngữ" />
              </div>
            </Card>

            <Card className="overflow-hidden border border-white/70 bg-white/80 shadow-sm backdrop-blur-xl">
              <div className="flex items-center justify-between gap-3 border-b border-slate-100 px-5 py-4">
                <div>
                  <p className="text-xs font-bold uppercase tracking-widest text-slate-500">Danh sách</p>
                  <p className="mt-1 text-sm text-slate-600">{documents.length.toLocaleString('vi-VN')} tài liệu phù hợp</p>
                </div>
                <Button type="button" size="sm" leftIcon={<Plus className="h-4 w-4" />} onClick={resetForm}>
                  Tài liệu mới
                </Button>
              </div>

              {isLoading ? (
                <div className="space-y-3 p-5">
                  {Array.from({ length: 4 }).map((_, index) => (
                    <div key={index} className="h-24 animate-pulse rounded-xl bg-slate-100" />
                  ))}
                </div>
              ) : documents.length === 0 ? (
                <EmptyState
                  title="Chưa có tài liệu phù hợp"
                  description="Tạo tài liệu mới hoặc thay đổi bộ lọc để xem thêm nội dung."
                  className="m-5 bg-white/60"
                />
              ) : (
                <div className="divide-y divide-slate-100">
                  {documents.map((document) => (
                    <DocumentRow
                      key={document.id}
                      document={document}
                      selected={selectedDocument?.id === document.id}
                      onEdit={() => handleEdit(document)}
                      onDelete={() => void handleDelete(document)}
                      onPublish={() => void handlePublish(document)}
                      onArchive={() => void handleArchive(document)}
                    />
                  ))}
                </div>
              )}
            </Card>
          </section>

          <Card className="border border-white/70 bg-white/80 p-5 shadow-sm backdrop-blur-xl">
            <div className="mb-4 flex items-center justify-between gap-3">
              <div>
                <p className="text-xs font-bold uppercase tracking-widest text-slate-500">Editor</p>
                <p className="mt-1 text-sm text-slate-600">
                  {form.id ? 'Cập nhật tài liệu hiện có.' : 'Tạo tài liệu pháp lý mới.'}
                </p>
              </div>
              {selectedDocument ? (
                <span className={cn('rounded-full px-2.5 py-1 text-[11px] font-bold', statusClass(selectedDocument.status))}>
                  {statusLabel(selectedDocument.status)}
                </span>
              ) : null}
            </div>

            <form className="space-y-3" onSubmit={handleSave}>
              <AdminSelect
                value={form.documentType}
                onChange={(value) => setForm((current) => ({ ...current, documentType: value }))}
                options={documentTypeOptions}
                ariaLabel="Loại tài liệu"
              />
              <Field label="Tiêu đề" value={form.title} onChange={(value) => setForm((current) => ({ ...current, title: value }))} />
              <Field label="Phiên bản" value={form.version} onChange={(value) => setForm((current) => ({ ...current, version: value }))} />
              <TextArea label="Tóm tắt" value={form.summary} rows={3} onChange={(value) => setForm((current) => ({ ...current, summary: value }))} />
              <TextArea label="Nội dung" value={form.body} rows={12} onChange={(value) => setForm((current) => ({ ...current, body: value }))} />
              <div className="grid gap-3 sm:grid-cols-2">
                <AdminSelect
                  value={form.locale}
                  onChange={(value) => setForm((current) => ({ ...current, locale: value }))}
                  options={formLocaleOptions}
                  ariaLabel="Ngôn ngữ"
                />
                <AdminSelect
                  value={form.status}
                  onChange={(value) => setForm((current) => ({ ...current, status: value }))}
                  options={formStatusOptions}
                  ariaLabel="Trạng thái"
                />
              </div>
              <Button type="submit" className="w-full" isLoading={isSaving} leftIcon={<Save className="h-4 w-4" />}>
                {form.id ? 'Lưu tài liệu' : 'Tạo tài liệu'}
              </Button>
            </form>
          </Card>
        </div>
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

function DocumentRow({
  document,
  selected,
  onEdit,
  onDelete,
  onPublish,
  onArchive,
}: {
  document: LegalDocument;
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
          <FileText className="h-4 w-4 text-amber-600" />
          <h2 className="min-w-0 truncate text-base font-bold text-slate-950">{document.title}</h2>
          <span className={cn('rounded-full px-2.5 py-1 text-[11px] font-bold', statusClass(document.status))}>
            {statusLabel(document.status)}
          </span>
        </div>
        <p className="mt-2 line-clamp-2 text-sm text-slate-600">{document.summary}</p>
        <div className="mt-3 flex flex-wrap gap-x-4 gap-y-1 text-xs font-medium text-slate-500">
          <span>{typeLabel(document.documentType)}</span>
          <span>{document.locale.toUpperCase()}</span>
          <span>v{document.version}</span>
        </div>
      </button>

      <div className="space-y-1 text-sm text-slate-600">
        <p>Publish: <span className="font-bold text-slate-900">{document.publishedAt ? formatDate(document.publishedAt) : 'Chưa publish'}</span></p>
        <p>Cập nhật: <span className="font-bold text-slate-900">{formatDate(document.updatedAt)}</span></p>
      </div>

      <div className="flex flex-wrap items-center gap-2 lg:justify-end">
        <IconButton title="Sửa" onClick={onEdit}>
          <Pencil className="h-4 w-4" />
        </IconButton>
        {document.status !== 'published' ? (
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

function Field({ label, value, onChange }: { label: string; value: string; onChange: (value: string) => void }) {
  return (
    <label className="block space-y-2">
      <span className="ml-1 text-xs font-bold uppercase tracking-widest text-slate-500">{label}</span>
      <input
        value={value}
        onChange={(event) => onChange(event.target.value)}
        className="h-11 w-full rounded-xl border border-slate-200 bg-white px-3 text-sm font-medium text-slate-800 outline-none transition focus:border-amber-500 focus:ring-4 focus:ring-amber-500/10"
      />
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

function buildPayload(form: LegalDocumentFormState): SaveLegalDocumentPayload | null {
  if (!form.title.trim() || !form.version.trim() || !form.body.trim()) {
    toast.error('Vui lòng nhập tiêu đề, phiên bản và nội dung.');
    return null;
  }

  return {
    documentType: form.documentType,
    title: form.title.trim(),
    version: form.version.trim(),
    summary: form.summary.trim(),
    body: form.body.trim(),
    locale: form.locale,
    status: form.status,
  };
}

function typeLabel(type: LegalDocumentType): string {
  return documentTypeOptions.find((option) => option.value === type)?.label ?? type;
}

function statusLabel(status: LegalDocumentStatus): string {
  const labels: Record<LegalDocumentStatus, string> = {
    draft: 'Bản nháp',
    published: 'Đã publish',
    archived: 'Lưu trữ',
  };
  return labels[status];
}

function statusClass(status: LegalDocumentStatus): string {
  const classes: Record<LegalDocumentStatus, string> = {
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
