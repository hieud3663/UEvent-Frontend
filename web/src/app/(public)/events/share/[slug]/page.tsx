import Image from 'next/image';
import Link from 'next/link';
import { notFound } from 'next/navigation';
import {
  CalendarDays,
  ChevronRight,
  Download,
  ExternalLink,
  MapPin,
  Smartphone,
  Tag,
  Ticket,
  Users,
} from 'lucide-react';
import { ApiClientError, apiRequest } from '@/core/lib/api';
import { Badge, Card } from '@/core/components';

const FALLBACK_EVENT_IMAGE =
  'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?auto=format&fit=crop&w=1600&q=80';

type PublicEventCategory = {
  name?: string;
  color?: string;
  icon?: string;
};

type PublicEventRoom = {
  name?: string;
  code?: string;
  building_name?: string;
  campus_name?: string;
};

type PublicEvent = {
  id: string;
  title: string;
  slug: string;
  description?: string | null;
  status: string;
  visibility: string;
  category?: PublicEventCategory | null;
  start_at?: string | null;
  end_at?: string | null;
  max_capacity?: number | null;
  location_snapshot?: string | null;
  cover_image_url?: string | null;
  room?: PublicEventRoom | null;
  registration_open_at?: string | null;
  registration_close_at?: string | null;
};

type PageProps = {
  params: Promise<{ slug: string }>;
};

async function getPublicEvent(slug: string): Promise<PublicEvent> {
  try {
    return await apiRequest<PublicEvent>(`/events/slug/${encodeURIComponent(slug)}/`, {
      auth: false,
      cache: 'no-store',
    });
  } catch (error) {
    if (error instanceof ApiClientError && error.status === 404) {
      notFound();
    }
    throw error;
  }
}

function formatDateTime(value?: string | null): string {
  if (!value) return 'Chưa cập nhật';

  return new Intl.DateTimeFormat('vi-VN', {
    dateStyle: 'medium',
    timeStyle: 'short',
  }).format(new Date(value));
}

function formatLocation(event: PublicEvent): string {
  if (event.location_snapshot?.trim()) return event.location_snapshot.trim();

  const parts = [
    event.room?.name,
    event.room?.code,
    event.room?.building_name,
    event.room?.campus_name,
  ].filter(Boolean);

  return parts.length > 0 ? parts.join(', ') : 'Chưa cập nhật';
}

function statusLabel(status: string): string {
  const labels: Record<string, string> = {
    active: 'Đang diễn ra',
    approved: 'Đã duyệt',
    draft: 'Bản nháp',
    rejected: 'Từ chối',
    cancelled: 'Đã hủy',
    archived: 'Lưu trữ',
  };

  return labels[status] ?? status;
}

export default async function EventShareLandingPage({ params }: PageProps) {
  const { slug } = await params;
  const event = await getPublicEvent(slug);
  const coverImage = event.cover_image_url || FALLBACK_EVENT_IMAGE;
  const categoryName = event.category?.name || 'Sự kiện';
  const location = formatLocation(event);
  const appDeepLink = `uevent://events/share/${encodeURIComponent(event.slug)}`;

  return (
    <main className="min-h-screen bg-surface-container-low text-on-surface">
      <header className="border-b border-neutral-200 bg-white/95 backdrop-blur">
        <div className="mx-auto flex min-h-16 max-w-7xl flex-wrap items-center justify-between gap-3 px-4 py-3 sm:px-8">
          <Link href="/" className="text-xl font-black tracking-tight text-neutral-900">
            UEvent
          </Link>
          <Link
            href="/download"
            className="inline-flex h-10 items-center justify-center gap-2 rounded-xl bg-primary-container px-3 text-sm font-bold text-on-primary-container transition hover:shadow-lg hover:shadow-primary-container/30 sm:px-4"
          >
            <Download className="h-4 w-4" />
            Tải ứng dụng
          </Link>
        </div>
      </header>

      <div className="mx-auto max-w-7xl px-4 py-5 sm:px-8 sm:py-8 lg:py-10">
        <section className="mb-5 grid gap-5 lg:mb-6 lg:grid-cols-[minmax(0,1fr)_360px] lg:items-end">
          <div className="min-w-0">
            <div className="mb-3 flex flex-wrap items-center gap-2 sm:mb-4">
              <Badge variant="info">{categoryName}</Badge>
              <Badge variant={event.status === 'active' ? 'success' : 'neutral'}>
                {statusLabel(event.status)}
              </Badge>
              <Badge variant="neutral">Công khai</Badge>
            </div>
            <h1 className="max-w-4xl text-2xl font-black leading-tight tracking-tight text-neutral-900 sm:text-4xl lg:text-5xl">
              {event.title}
            </h1>
            <p className="mt-3 max-w-2xl text-sm leading-6 text-neutral-600 sm:text-base sm:leading-7">
              Link chia sẻ sự kiện public trên UEvent. Người tham dự có thể xem thông tin chính và mở ứng dụng để đăng ký.
            </p>
          </div>
          <div className="flex flex-col gap-3 sm:flex-row lg:flex-col">
            <Link
              href={appDeepLink}
              className="inline-flex h-12 w-full items-center justify-center gap-2 rounded-xl bg-primary-container px-4 text-sm font-bold text-on-primary-container transition hover:shadow-lg hover:shadow-primary-container/30 sm:flex-1 lg:flex-none"
            >
              <Smartphone className="h-6 w-6" />
              Mở trong ứng dụng
              <ChevronRight className="h-6 w-6" />
            </Link>
            <Link
              href="/download"
              className="inline-flex h-12 w-full items-center justify-center gap-2 rounded-xl border border-neutral-200 bg-white px-4 text-sm font-bold text-neutral-700 transition hover:bg-neutral-50 sm:flex-1 lg:flex-none"
            >
              <Download className="h-6 w-6" />
              Tải ứng dụng
            </Link>
          </div>
        </section>

        <div className="grid gap-5 lg:grid-cols-[minmax(0,1fr)_360px] lg:gap-6">
          <div className="space-y-6">
            <Card className="overflow-hidden p-0">
              <div className="relative aspect-[4/3] min-h-56 bg-neutral-100 sm:aspect-[16/8] lg:aspect-[16/7] lg:min-h-64">
                <Image
                  src={coverImage}
                  alt={event.title}
                  fill
                  priority
                  sizes="(min-width: 1024px) 760px, (min-width: 640px) 92vw, 100vw"
                  className="object-cover"
                />
              </div>
            </Card>

            <Card>
              <div className="mb-5 flex items-center gap-2">
                <Ticket className="h-5 w-5 text-primary-700" />
                <h2 className="text-lg font-black text-neutral-900">Thông tin sự kiện</h2>
              </div>
              <p className="whitespace-pre-line text-sm leading-7 text-neutral-700">
                {event.description?.trim() || 'Thông tin chi tiết của sự kiện sẽ được cập nhật trong ứng dụng UEvent.'}
              </p>
            </Card>
          </div>

          <aside className="space-y-5 lg:sticky lg:top-6 lg:self-start">
            <Card>
              <h2 className="mb-4 text-lg font-black text-neutral-900">Tóm tắt</h2>
              <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-1">
                <InfoRow
                  icon={<CalendarDays className="h-4 w-4" />}
                  label="Bắt đầu"
                  value={formatDateTime(event.start_at)}
                />
                <InfoRow
                  icon={<CalendarDays className="h-4 w-4" />}
                  label="Kết thúc"
                  value={formatDateTime(event.end_at)}
                />
                <InfoRow
                  icon={<MapPin className="h-4 w-4" />}
                  label="Địa điểm"
                  value={location}
                />
                <InfoRow
                  icon={<Users className="h-4 w-4" />}
                  label="Sức chứa"
                  value={event.max_capacity ? `${event.max_capacity} người` : 'Không giới hạn'}
                />
                <InfoRow
                  icon={<Tag className="h-4 w-4" />}
                  label="Danh mục"
                  value={categoryName}
                />
              </div>
            </Card>

            <Card>
              <h2 className="text-lg font-black text-neutral-900">Tham gia qua UEvent</h2>
              <p className="mt-3 text-sm leading-6 text-neutral-600">
                Dùng ứng dụng để đăng ký, lưu vé QR và nhận thông báo mới nhất từ ban tổ chức.
              </p>
              <Link
                href="/"
                className="mt-5 inline-flex h-11 w-full items-center justify-center gap-2 rounded-xl border border-neutral-200 bg-white px-4 text-sm font-bold text-neutral-700 transition hover:bg-neutral-50"
              >
                <ExternalLink className="h-4 w-4" />
                Về trang chủ
              </Link>
            </Card>
          </aside>
        </div>
      </div>
    </main>
  );
}

function InfoRow({
  icon,
  label,
  value,
}: {
  icon: React.ReactNode;
  label: string;
  value: string;
}) {
  return (
    <div className="flex min-w-0 gap-3">
      <div className="mt-0.5 flex h-8 w-8 shrink-0 items-center justify-center rounded-xl bg-slate-100 text-slate-600">
        {icon}
      </div>
      <div className="min-w-0">
        <div className="text-xs font-bold uppercase tracking-wide text-neutral-500">
          {label}
        </div>
        <div className="mt-1 break-words text-sm font-semibold leading-5 text-neutral-900">
          {value}
        </div>
      </div>
    </div>
  );
}
