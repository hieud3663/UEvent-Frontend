// File: src/app/(auth)/layout.tsx
// Auth layout without sidebar - for login/register pages

export default function AuthLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="min-h-screen bg-ethereal overflow-hidden relative">
      {/* Background Decorations */}
      <div className="absolute top-[-10%] left-[-5%] w-[40%] h-[40%] bg-primary-container/20 rounded-full blur-[120px] pointer-events-none" />
      <div className="absolute bottom-[-10%] right-[-5%] w-[40%] h-[40%] bg-secondary-container/30 rounded-full blur-[120px] pointer-events-none" />

      {children}
    </div>
  );
}
