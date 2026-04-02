'use client';

import Image from 'next/image';
import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { Database, Info, Network, Settings, Shield, ShieldAlert } from 'lucide-react';
import { toast } from 'sonner';
import { ConfirmActionDialog } from '@/core/components';
import { additionalScopes, permissionProfile } from '@/features/permissions/mock/mock-permissions';
import { usePermissions } from '@/features/permissions/hooks/usePermissions';
import { savePermissions } from '@/features/permissions/services/permissions.service';

export default function PermissionsPage() {
  const router = useRouter();
  const { adminOps, dataAccess, setAdminOps, setDataAccess } = usePermissions();
  const [selectedScope, setSelectedScope] = useState('Audit Reporting');
  const [isConfirmOpen, setIsConfirmOpen] = useState(false);

  const handleConfirmSave = async () => {
    await savePermissions({ dataAccess, adminOps });
    toast.success('Permissions saved successfully.');
    setIsConfirmOpen(false);
    router.push('/users');
  };

  return (
    <div className="min-h-screen pb-20">
      <header className="mb-8 flex flex-col md:flex-row md:items-end justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-slate-900 tracking-tight mb-1">Permission Architect</h1>
          <p className="text-sm text-slate-500 font-medium">
            Configure granular access levels for the <span className="text-amber-600">Lead Security Analyst</span> role.
          </p>
        </div>
        <div className="flex gap-3">
          <button
            type="button"
            onClick={() => router.back()}
            className="px-6 py-2.5 bg-white/80 border border-white/40 rounded-xl text-sm font-bold text-slate-600 backdrop-blur-sm hover:bg-white transition-all shadow-sm"
          >
            Discard Changes
          </button>
          <button
            type="button"
            onClick={() => setIsConfirmOpen(true)}
            className="px-6 py-2.5 bg-amber-500 text-white rounded-xl text-sm font-bold shadow-lg shadow-amber-500/20 hover:saturate-150 active:scale-95 transition-all"
          >
            Save Permissions
          </button>
        </div>
      </header>

      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
        <div className="col-span-1 lg:col-span-4 h-full">
          <div className="bg-white/70 backdrop-blur-2xl p-6 rounded-[24px] border border-white/40 shadow-[0_8px_32px_rgba(0,0,0,0.04)] sticky top-24">
            <div className="flex flex-col items-center text-center mb-6">
              <div className="relative w-24 h-24 mb-4">
                <Image
                  className="w-full h-full object-cover rounded-[20px] shadow-lg"
                  alt={permissionProfile.name}
                  src={permissionProfile.avatar}
                  fill
                  sizes="96px"
                />
                <div className="absolute -bottom-2 -right-2 bg-amber-500 text-white p-1.5 rounded-lg shadow-lg">
                  <Shield className="w-4 h-4" />
                </div>
              </div>
              <h3 className="text-lg font-bold text-slate-900">{permissionProfile.name}</h3>
              <p className="text-sm text-slate-500 font-medium">{permissionProfile.email}</p>

              <div className="mt-4 flex flex-wrap justify-center gap-2">
                <span className="px-3 py-1 bg-amber-100 text-amber-700 text-[10px] font-bold uppercase tracking-wider rounded-full">
                  {permissionProfile.role}
                </span>
                <span className="px-3 py-1 bg-slate-100 text-slate-600 text-[10px] font-bold uppercase tracking-wider rounded-full">
                  {permissionProfile.office}
                </span>
              </div>
            </div>

            <div className="space-y-4 pt-6 border-t border-slate-200/50">
              <div className="flex justify-between items-center">
                <span className="text-xs font-bold uppercase text-slate-400">Total Assigned</span>
                <span className="text-sm font-bold text-slate-900">{permissionProfile.assigned}</span>
              </div>
              <div className="w-full bg-slate-100 h-2 rounded-full overflow-hidden">
                <div className="bg-amber-500 h-full w-[35%] rounded-full shadow-[0_0_8px_rgba(255,184,0,0.4)]"></div>
              </div>

              <div className="p-4 bg-amber-50 rounded-xl mt-4">
                <div className="flex gap-3">
                  <Info className="w-5 h-5 text-amber-600 shrink-0" />
                  <p className="text-xs leading-relaxed text-amber-800/80 font-medium">
                    This user has custom overrides active that deviate from the standard <span className="font-bold">Analyst</span> role template.
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div className="col-span-1 lg:col-span-8 space-y-6">
          <section className="bg-white rounded-[24px] p-8 shadow-sm border border-slate-100">
            <div className="flex items-center gap-3 mb-6">
              <div className="w-10 h-10 bg-blue-50 text-blue-600 rounded-xl flex items-center justify-center">
                <Database className="w-5 h-5" />
              </div>
              <div>
                <h2 className="text-lg font-bold text-slate-900">Data Access &amp; Storage</h2>
                <p className="text-xs text-slate-400 font-medium uppercase tracking-wide">Infrastructure Level 2</p>
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <PermissionItem label="Read Encryption Keys" description="Access to sensitive root certificates" checked={dataAccess.keys} onChange={() => setDataAccess((prev) => ({ ...prev, keys: !prev.keys }))} />
              <PermissionItem label="Modify DB Schemas" description="Structural changes to production tables" checked={dataAccess.schema} onChange={() => setDataAccess((prev) => ({ ...prev, schema: !prev.schema }))} />
              <PermissionItem label="PII De-masking" description="View customer identities in cleartext" checked={dataAccess.pii} onChange={() => setDataAccess((prev) => ({ ...prev, pii: !prev.pii }))} />
              <PermissionItem label="Mass Export" description="Permission to download datasets >10k" checked={dataAccess.export} onChange={() => setDataAccess((prev) => ({ ...prev, export: !prev.export }))} />
            </div>
          </section>

          <section className="bg-white rounded-[24px] p-8 shadow-sm border border-slate-100">
            <div className="flex items-center gap-3 mb-6">
              <div className="w-10 h-10 bg-amber-50 text-amber-600 rounded-xl flex items-center justify-center">
                <Settings className="w-5 h-5" />
              </div>
              <div>
                <h2 className="text-lg font-bold text-slate-900">Administrative Operations</h2>
                <p className="text-xs text-slate-400 font-medium uppercase tracking-wide">Core System Access</p>
              </div>
            </div>

            <div className="space-y-4">
              <div className="flex flex-col sm:flex-row sm:items-center justify-between p-4 bg-slate-50/50 rounded-xl gap-4">
                <div className="flex items-start gap-4">
                  <ShieldAlert className="w-6 h-6 text-slate-400 shrink-0 mt-0.5" />
                  <div className="flex flex-col">
                    <span className="text-sm font-bold text-slate-800">Global Policy Editor</span>
                    <span className="text-xs text-slate-500">Manage organizational security protocols and compliance rules</span>
                  </div>
                </div>
                <div className="flex items-center gap-3 shrink-0 self-end sm:self-auto">
                  <span className="px-3 py-1 bg-red-100 text-red-600 text-[10px] font-bold rounded-full whitespace-nowrap">High Risk</span>
                  <Switch checked={adminOps.policy} onChange={() => setAdminOps((prev) => ({ ...prev, policy: !prev.policy }))} />
                </div>
              </div>

              <div className="flex items-center justify-between p-4 bg-slate-50/50 rounded-xl">
                <div className="flex items-center gap-4">
                  <Network className="w-6 h-6 text-slate-400 shrink-0" />
                  <div className="flex flex-col">
                    <span className="text-sm font-bold text-slate-800">Network Topology View</span>
                    <span className="text-xs text-slate-500">Read-only visualization of cluster and node health</span>
                  </div>
                </div>
                <Switch checked={adminOps.topology} onChange={() => setAdminOps((prev) => ({ ...prev, topology: !prev.topology }))} />
              </div>
            </div>
          </section>

          <div className="flex items-center justify-center gap-4 py-4">
            <div className="h-[0.5px] bg-slate-200 flex-grow"></div>
            <span className="text-[10px] font-bold uppercase tracking-[0.2em] text-slate-400 whitespace-nowrap">Additional Scopes</span>
            <div className="h-[0.5px] bg-slate-200 flex-grow"></div>
          </div>

          <div className="flex flex-wrap gap-3">
            {additionalScopes.map((scope) => (
              <button
                key={scope}
                type="button"
                onClick={() => {
                  setSelectedScope(scope);
                  toast.info(`Selected scope: ${scope}`);
                }}
                className={`px-5 py-2 text-xs font-bold rounded-full transition-all ${
                  scope === selectedScope
                    ? 'bg-amber-500 text-white shadow-md shadow-amber-500/10'
                    : 'bg-white text-slate-500 border border-slate-200 hover:bg-slate-50'
                }`}
              >
                {scope}
              </button>
            ))}
          </div>
        </div>
      </div>

      <ConfirmActionDialog
        open={isConfirmOpen}
        onOpenChange={setIsConfirmOpen}
        title="Xác nhận lưu quyền truy cập"
        description="Bạn sắp ghi đè cấu hình quyền hiện tại cho người dùng này. Hãy xác nhận để tiếp tục."
        confirmLabel="Xác nhận"
        cancelLabel="Hủy"
        onConfirm={() => {
          void handleConfirmSave();
        }}
      />
    </div>
  );
}

interface PermissionItemProps {
  label: string;
  description: string;
  checked: boolean;
  onChange: () => void;
}

function PermissionItem({ label, description, checked, onChange }: PermissionItemProps) {
  return (
    <div className="flex items-center justify-between p-4 bg-slate-50/50 rounded-xl border border-transparent hover:border-amber-500/20 hover:bg-white transition-all group">
      <div className="flex flex-col">
        <span className="text-sm font-bold text-slate-800">{label}</span>
        <span className="text-xs text-slate-500">{description}</span>
      </div>
      <div className="shrink-0 ml-4">
        <Switch checked={checked} onChange={onChange} />
      </div>
    </div>
  );
}

interface SwitchProps {
  checked: boolean;
  onChange: () => void;
}

function Switch({ checked, onChange }: SwitchProps) {
  return (
    <label className="relative inline-flex items-center cursor-pointer">
      <input type="checkbox" checked={checked} onChange={onChange} className="sr-only peer" />
      <div className="w-11 h-6 bg-slate-200 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-amber-500"></div>
    </label>
  );
}
