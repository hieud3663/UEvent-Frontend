// File: src/app/(admin)/tickets/page.tsx
export default function TicketsPage() {
  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-neutral-900">Tickets</h1>
          <p className="text-neutral-500">Manage ticket sales and validations</p>
        </div>
      </div>

      <div className="rounded-xl border border-neutral-200 bg-white p-6 shadow-sm">
        <p className="text-neutral-500">Tickets table will be added here</p>
        <div className="mt-4 h-96 rounded-lg bg-neutral-100"></div>
      </div>
    </div>
  );
}
