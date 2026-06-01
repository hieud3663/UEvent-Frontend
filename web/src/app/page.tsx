// File: src/app/page.tsx
import Image from 'next/image';
import Link from 'next/link';
import {
  Apple,
  ArrowRight,
  CalendarDays,
  Download,
  MapPin,
  ShieldCheck,
  Smartphone,
  Ticket,
  Users,
} from 'lucide-react';

const highlights = [
  {
    title: 'Khám phá sự kiện phù hợp',
    description: 'Theo dõi hội thảo, workshop, hoạt động sinh viên và sự kiện cộng đồng theo lịch cá nhân.',
    icon: CalendarDays,
  },
  {
    title: 'Đăng ký và giữ vé nhanh',
    description: 'Quản lý vé, lịch tham dự và thông báo thay đổi sự kiện ngay trong ứng dụng.',
    icon: Ticket,
  },
  {
    title: 'Kết nối ban tổ chức',
    description: 'Nhận hỗ trợ, cập nhật chính sách và trao đổi thông tin với đội ngũ vận hành UEvent.',
    icon: Users,
  },
];

const stats = [
  { value: '24/7', label: 'cập nhật lịch sự kiện' },
  { value: '2', label: 'nền tảng di động' },
  { value: 'vi', label: 'ngôn ngữ ưu tiên' },
];

export default function HomePage() {
  return (
    <main className="min-h-screen bg-ethereal text-on-surface">
      <section className="relative isolate h-[82svh] min-h-[520px] max-h-[680px] overflow-hidden">
        <Image
          src="https://images.unsplash.com/photo-1511795409834-ef04bbd61622?auto=format&fit=crop&w=1800&q=80"
          alt="Không gian sự kiện với người tham dự"
          fill
          priority
          sizes="100vw"
          className="object-cover"
        />
        <div className="absolute inset-0 bg-[linear-gradient(90deg,rgba(32,27,17,0.88),rgba(124,88,0,0.58),rgba(255,184,0,0.12))]" />
        <div className="absolute inset-x-0 bottom-0 h-28 bg-gradient-to-t from-[#fff8f2] to-transparent" />

        <header className="relative z-10 mx-auto flex w-full max-w-7xl items-center justify-between px-5 py-5 sm:px-8">
          <Link href="/" className="text-xl font-black tracking-tight text-white">
            UEvent
          </Link>
          <nav className="hidden items-center gap-6 text-sm font-bold text-white/82 md:flex">
            <Link href="#features" className="hover:text-white">
              Trải nghiệm
            </Link>
            <Link href="/download" className="hover:text-white">
              Tải ứng dụng
            </Link>
            <Link href="/terms" className="hover:text-white">
              Điều khoản
            </Link>
            <Link href="/privacy" className="hover:text-white">
              Chính sách
            </Link>
          </nav>
          <Link
            href="/admin"
            className="inline-flex h-10 items-center justify-center rounded-xl border border-white/40 bg-white/10 px-4 text-sm font-bold text-white backdrop-blur transition hover:bg-white hover:text-on-surface"
          >
            Quản trị
          </Link>
        </header>

        <div className="relative z-10 mx-auto flex h-[calc(100%-80px)] w-full max-w-7xl items-center px-5 pb-12 sm:px-8">
          <div className="max-w-3xl">
            <div className="mb-5 inline-flex items-center gap-2 rounded-full border border-white/20 bg-white/10 px-4 py-2 text-sm font-bold text-primary-100 backdrop-blur">
              <MapPin className="h-4 w-4" />
              Nền tảng sự kiện cho cộng đồng UEvent
            </div>
            <h1 className="max-w-3xl text-5xl font-black leading-[1.02] tracking-tight text-white sm:text-6xl lg:text-7xl">
              UEvent
            </h1>
            <p className="mt-6 max-w-2xl text-lg leading-8 text-white/88 sm:text-xl">
              Theo dõi sự kiện, đăng ký tham dự, lưu vé và nhận thông báo quan trọng trong một ứng dụng gọn gàng cho người tham dự lẫn ban tổ chức.
            </p>
            <div className="mt-8 flex flex-col gap-3 sm:flex-row">
              <Link
                href="/download"
                className="inline-flex h-12 items-center justify-center gap-2 rounded-xl bg-primary-container px-5 text-sm font-bold text-on-primary-container shadow-lg shadow-primary-container/30 transition hover:scale-[1.02]"
              >
                <Download className="h-4 w-4" />
                Tải ứng dụng
              </Link>
              <Link
                href="#features"
                className="inline-flex h-12 items-center justify-center gap-2 rounded-xl border border-white/40 bg-white/10 px-5 text-sm font-bold text-white backdrop-blur transition hover:bg-white/15"
              >
                Xem trải nghiệm
                <ArrowRight className="h-4 w-4" />
              </Link>
            </div>
          </div>
        </div>
      </section>

      <section id="features" className="relative border-b border-white/50 bg-white/30">
        <div className="mx-auto grid max-w-7xl gap-4 px-5 py-8 sm:px-8 md:grid-cols-3">
          {stats.map((item) => (
            <div key={item.label} className="glass-card rounded-[28px] p-5">
              <div className="text-3xl font-black text-primary-700">{item.value}</div>
              <div className="mt-1 text-sm font-bold text-on-surface-variant">{item.label}</div>
            </div>
          ))}
        </div>
      </section>

      <section className="py-16 sm:py-20">
        <div className="mx-auto max-w-7xl px-5 sm:px-8">
          <div className="max-w-2xl">
            <h2 className="text-3xl font-black tracking-tight text-on-surface sm:text-4xl">
              Một điểm chạm cho lịch sự kiện, vé và hỗ trợ
            </h2>
            <p className="mt-4 text-base leading-7 text-on-surface-variant">
              Web public tập trung vào thông tin chính thức, còn ứng dụng di động xử lý trải nghiệm tham dự hằng ngày.
            </p>
          </div>

          <div className="mt-10 grid gap-4 md:grid-cols-3">
            {highlights.map((item) => {
              const Icon = item.icon;
              return (
                <article key={item.title} className="glass-card rounded-[28px] p-6">
                  <div className="flex h-11 w-11 items-center justify-center rounded-2xl bg-primary-container text-on-primary-container shadow-lg shadow-primary-container/20">
                    <Icon className="h-5 w-5" />
                  </div>
                  <h3 className="mt-5 text-lg font-black text-on-surface">{item.title}</h3>
                  <p className="mt-3 text-sm leading-6 text-on-surface-variant">{item.description}</p>
                </article>
              );
            })}
          </div>
        </div>
      </section>

      <section className="py-16 sm:py-20">
        <div className="mx-auto grid max-w-7xl gap-8 px-5 sm:px-8 lg:grid-cols-[1fr_0.9fr] lg:items-center">
          <div className="glass-card rounded-[32px] p-6 sm:p-8">
            <h2 className="text-3xl font-black tracking-tight text-on-surface sm:text-4xl">Tải UEvent cho thiết bị của bạn</h2>
            <p className="mt-4 max-w-2xl text-base leading-7 text-on-surface-variant">
              Chọn bản Android APK hoặc mở trang iOS để cài ứng dụng khi bản phát hành chính thức sẵn sàng.
            </p>
          </div>
          <div className="grid gap-3 sm:grid-cols-2">
            <Link
              href="/download#android-release"
              className="glass-card inline-flex min-h-16 items-center gap-3 rounded-[24px] px-5 py-4 transition hover:bg-white"
            >
              <Smartphone className="h-5 w-5 text-primary-700" />
              <span>
                <span className="block text-sm font-black text-on-surface">Tải APK</span>
                <span className="block text-xs font-medium text-on-surface-variant">Android</span>
              </span>
            </Link>
            <Link
              href="/download#ios-release"
              className="glass-card inline-flex min-h-16 items-center gap-3 rounded-[24px] px-5 py-4 transition hover:bg-white"
            >
              <Apple className="h-5 w-5 text-slate-900" />
              <span>
                <span className="block text-sm font-black text-on-surface">Tải cho iOS</span>
                <span className="block text-xs font-medium text-on-surface-variant">App Store</span>
              </span>
            </Link>
          </div>
        </div>
      </section>

      <section className="pb-12">
        <div className="mx-auto flex max-w-7xl flex-col gap-4 px-5 sm:px-8 md:flex-row md:items-center md:justify-between">
          <div className="flex items-start gap-3">
            <ShieldCheck className="mt-1 h-5 w-5 text-primary-700" />
            <div>
              <h2 className="text-lg font-black text-on-surface">Thông tin pháp lý luôn có sẵn</h2>
              <p className="mt-1 text-sm leading-6 text-on-surface-variant">
                Người dùng có thể đọc điều khoản dịch vụ và chính sách quyền riêng tư trước khi cài đặt.
              </p>
            </div>
          </div>
          <div className="flex flex-wrap gap-3">
            <Link href="/terms" className="rounded-xl border border-black/5 bg-white/70 px-4 py-2 text-sm font-bold text-on-surface shadow-sm hover:bg-white">
              Điều khoản
            </Link>
            <Link href="/privacy" className="rounded-xl border border-black/5 bg-white/70 px-4 py-2 text-sm font-bold text-on-surface shadow-sm hover:bg-white">
              Chính sách
            </Link>
          </div>
        </div>
      </section>
    </main>
  );
}
