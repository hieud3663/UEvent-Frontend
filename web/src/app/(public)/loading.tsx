import { Loader2 } from 'lucide-react';

export default function PublicLoading() {
  return (
    <main className="grid min-h-screen place-items-center bg-ethereal px-5 text-on-surface">
      <div className="glass-card flex items-center gap-3 rounded-[28px] px-5 py-4">
        <Loader2 className="h-5 w-5 animate-spin text-primary-700" />
        <span className="text-sm font-bold">Đang tải nội dung</span>
      </div>
    </main>
  );
}
