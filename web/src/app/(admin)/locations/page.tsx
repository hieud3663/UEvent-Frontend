'use client';

import { FormEvent, useCallback, useEffect, useMemo, useState } from 'react';
import {
  Building2,
  ChevronLeft,
  ChevronRight,
  Edit,
  MapPinned,
  Plus,
  RotateCw,
  Search,
  Trash2,
  X,
} from 'lucide-react';
import {
  AdminSelect,
  Button,
  Card,
  ConfirmActionDialog,
  EmptyState,
  ErrorState,
  Input,
  ListSkeleton,
} from '@/core/components';
import { getApiFieldErrors, type ApiFieldErrors } from '@/core/lib/api';
import { runActionWithToast } from '@/core/lib/runActionWithToast';
import { cn } from '@/core/lib/utils';
import {
  createBuilding,
  createCampus,
  createRoom,
  deleteBuildingById,
  deleteCampusById,
  deleteRoomById,
  getBuildingsPage,
  getCampusesPage,
  getLocationStats,
  getRoomsPage,
  updateBuildingById,
  updateCampusById,
  updateRoomById,
} from '@/features/locations/services/locations.service';
import type {
  Building,
  Campus,
  LocationListResult,
  LocationStats,
  LocationTab,
  Room,
} from '@/features/locations/types';

const LOCATION_PAGE_SIZE = 8;
const EMPTY_PAGINATION = {
  total: 0,
  page: 1,
  pageSize: LOCATION_PAGE_SIZE,
  totalPages: 1,
};

type StatusFilter = 'all' | 'active' | 'inactive';
type DeleteTarget = {
  kind: LocationTab;
  id: string;
  name: string;
  eventCount: number;
};

type EditorState = {
  kind: LocationTab;
  id?: string;
} | null;

interface CampusFormState {
  name: string;
  code: string;
  address: string;
  isActive: boolean;
}

interface BuildingFormState {
  campusId: string;
  name: string;
  code: string;
  isActive: boolean;
}

interface RoomFormState {
  campusId: string;
  buildingId: string;
  name: string;
  code: string;
  capacity: string;
  isActive: boolean;
}

const emptyCampusForm: CampusFormState = {
  name: '',
  code: '',
  address: '',
  isActive: true,
};

const emptyBuildingForm: BuildingFormState = {
  campusId: '',
  name: '',
  code: '',
  isActive: true,
};

const emptyRoomForm: RoomFormState = {
  campusId: '',
  buildingId: '',
  name: '',
  code: '',
  capacity: '',
  isActive: true,
};

const tabOptions: Array<{ value: LocationTab; label: string; description: string }> = [
  { value: 'campuses', label: 'Cơ sở', description: 'Quản lý khuôn viên và địa chỉ' },
  { value: 'buildings', label: 'Tòa nhà', description: 'Quản lý tòa nhà theo cơ sở' },
  { value: 'rooms', label: 'Phòng', description: 'Quản lý phòng và sức chứa' },
];

const statusOptions = [
  { value: 'all', label: 'Tất cả trạng thái' },
  { value: 'active', label: 'Đang hoạt động' },
  { value: 'inactive', label: 'Tạm ẩn' },
] as const;

const orderingOptions: Record<LocationTab, Array<{ value: string; label: string }>> = {
  campuses: [
    { value: 'name', label: 'Tên A-Z' },
    { value: '-name', label: 'Tên Z-A' },
    { value: '-building_count', label: 'Nhiều tòa nhà nhất' },
    { value: '-room_count', label: 'Nhiều phòng nhất' },
    { value: '-event_count', label: 'Nhiều sự kiện nhất' },
    { value: '-created_at', label: 'Mới tạo trước' },
  ],
  buildings: [
    { value: 'campus__name', label: 'Theo cơ sở' },
    { value: 'name', label: 'Tên A-Z' },
    { value: '-name', label: 'Tên Z-A' },
    { value: '-room_count', label: 'Nhiều phòng nhất' },
    { value: '-event_count', label: 'Nhiều sự kiện nhất' },
    { value: '-created_at', label: 'Mới tạo trước' },
  ],
  rooms: [
    { value: 'building__campus__name', label: 'Theo cơ sở' },
    { value: 'building__name', label: 'Theo tòa nhà' },
    { value: 'name', label: 'Tên A-Z' },
    { value: '-capacity', label: 'Sức chứa lớn nhất' },
    { value: '-event_count', label: 'Nhiều sự kiện nhất' },
    { value: '-created_at', label: 'Mới tạo trước' },
  ],
};

export default function LocationsPage() {
  const [activeTab, setActiveTab] = useState<LocationTab>('campuses');
  const [stats, setStats] = useState<LocationStats | null>(null);
  const [campuses, setCampuses] = useState<Campus[]>([]);
  const [buildings, setBuildings] = useState<Building[]>([]);
  const [rooms, setRooms] = useState<Room[]>([]);
  const [campusOptions, setCampusOptions] = useState<Campus[]>([]);
  const [buildingOptions, setBuildingOptions] = useState<Building[]>([]);
  const [pagination, setPagination] = useState(EMPTY_PAGINATION);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [keyword, setKeyword] = useState('');
  const [submittedKeyword, setSubmittedKeyword] = useState('');
  const [statusFilter, setStatusFilter] = useState<StatusFilter>('all');
  const [campusFilter, setCampusFilter] = useState('all');
  const [buildingFilter, setBuildingFilter] = useState('all');
  const [ordering, setOrdering] = useState(orderingOptions.campuses[0].value);
  const [currentPage, setCurrentPage] = useState(1);
  const [editor, setEditor] = useState<EditorState>(null);
  const [campusForm, setCampusForm] = useState<CampusFormState>(emptyCampusForm);
  const [buildingForm, setBuildingForm] = useState<BuildingFormState>(emptyBuildingForm);
  const [roomForm, setRoomForm] = useState<RoomFormState>(emptyRoomForm);
  const [fieldErrors, setFieldErrors] = useState<ApiFieldErrors>({});
  const [isSaving, setIsSaving] = useState(false);
  const [deleteTarget, setDeleteTarget] = useState<DeleteTarget | null>(null);

  const selectedIsActive = statusFilter === 'all' ? undefined : statusFilter === 'active';

  const loadLocations = useCallback(async () => {
    try {
      setIsLoading(true);
      setError(null);

      const commonFilters = {
        keyword: submittedKeyword,
        isActive: selectedIsActive,
        ordering,
        page: currentPage,
        pageSize: LOCATION_PAGE_SIZE,
      };

      const currentListPromise: Promise<LocationListResult<Campus | Building | Room>> =
        activeTab === 'campuses'
          ? getCampusesPage(commonFilters)
          : activeTab === 'buildings'
            ? getBuildingsPage({
                ...commonFilters,
                campusId: campusFilter === 'all' ? undefined : campusFilter,
              })
            : getRoomsPage({
                ...commonFilters,
                campusId: campusFilter === 'all' ? undefined : campusFilter,
                buildingId: buildingFilter === 'all' ? undefined : buildingFilter,
              });

      const [nextStats, nextCampusOptions, nextBuildingOptions, currentList] = await Promise.all([
        getLocationStats(),
        getCampusesPage({ pageSize: 100, ordering: 'name' }),
        getBuildingsPage({ pageSize: 100, ordering: 'campus__name' }),
        currentListPromise,
      ]);

      setStats(nextStats);
      setCampusOptions(nextCampusOptions.items);
      setBuildingOptions(nextBuildingOptions.items);
      setPagination({
        total: currentList.total,
        page: currentList.page,
        pageSize: currentList.pageSize,
        totalPages: currentList.totalPages,
      });

      if (activeTab === 'campuses') {
        setCampuses(currentList.items as Campus[]);
      } else if (activeTab === 'buildings') {
        setBuildings(currentList.items as Building[]);
      } else {
        setRooms(currentList.items as Room[]);
      }
    } catch (loadError) {
      setError(loadError instanceof Error ? loadError.message : 'Không thể tải danh sách địa điểm.');
    } finally {
      setIsLoading(false);
    }
  }, [activeTab, buildingFilter, campusFilter, currentPage, ordering, selectedIsActive, submittedKeyword]);

  useEffect(() => {
    void loadLocations();
  }, [loadLocations]);

  const campusSelectOptions = useMemo(
    () => [
      { value: 'all', label: 'Tất cả cơ sở' },
      ...campusOptions.map((campus) => ({
        value: campus.id,
        label: `${campus.name} (${campus.code})`,
      })),
    ],
    [campusOptions]
  );

  const buildingSelectOptions = useMemo(() => {
    const filteredBuildings =
      campusFilter === 'all'
        ? buildingOptions
        : buildingOptions.filter((building) => building.campus.id === campusFilter);

    return [
      { value: 'all', label: 'Tất cả tòa nhà' },
      ...filteredBuildings.map((building) => ({
        value: building.id,
        label: `${building.name} (${building.code})`,
        description: building.campus.name,
      })),
    ];
  }, [buildingOptions, campusFilter]);

  const roomFormBuildingOptions = useMemo(() => {
    const filteredBuildings = roomForm.campusId
      ? buildingOptions.filter((building) => building.campus.id === roomForm.campusId)
      : buildingOptions;

    return filteredBuildings.map((building) => ({
      value: building.id,
      label: `${building.name} (${building.code})`,
      description: building.campus.name,
    }));
  }, [buildingOptions, roomForm.campusId]);

  const totalPages = pagination.totalPages || 1;
  const safeCurrentPage = pagination.page || currentPage;
  const totalItems = pagination.total;
  const visibleStart = totalItems === 0 ? 0 : (safeCurrentPage - 1) * pagination.pageSize + 1;
  const visibleEnd = Math.min(safeCurrentPage * pagination.pageSize, totalItems);

  const handleTabChange = (nextTab: LocationTab) => {
    setActiveTab(nextTab);
    setKeyword('');
    setSubmittedKeyword('');
    setStatusFilter('all');
    setCampusFilter('all');
    setBuildingFilter('all');
    setOrdering(orderingOptions[nextTab][0].value);
    setCurrentPage(1);
  };

  const handleSearchSubmit = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    setSubmittedKeyword(keyword.trim());
    setCurrentPage(1);
  };

  const handleResetFilters = () => {
    setKeyword('');
    setSubmittedKeyword('');
    setStatusFilter('all');
    setCampusFilter('all');
    setBuildingFilter('all');
    setOrdering(orderingOptions[activeTab][0].value);
    setCurrentPage(1);
  };

  const openCreateEditor = () => {
    setFieldErrors({});
    if (activeTab === 'campuses') {
      setCampusForm(emptyCampusForm);
    } else if (activeTab === 'buildings') {
      setBuildingForm({
        ...emptyBuildingForm,
        campusId: campusOptions[0]?.id || '',
      });
    } else {
      const firstCampusId = campusOptions[0]?.id || '';
      const firstBuilding = buildingOptions.find((building) => !firstCampusId || building.campus.id === firstCampusId);
      setRoomForm({
        ...emptyRoomForm,
        campusId: firstCampusId,
        buildingId: firstBuilding?.id || '',
      });
    }
    setEditor({ kind: activeTab });
  };

  const openCampusEditor = (campus: Campus) => {
    setFieldErrors({});
    setCampusForm({
      name: campus.name,
      code: campus.code,
      address: campus.address,
      isActive: campus.isActive,
    });
    setEditor({ kind: 'campuses', id: campus.id });
  };

  const openBuildingEditor = (building: Building) => {
    setFieldErrors({});
    setBuildingForm({
      campusId: building.campus.id,
      name: building.name,
      code: building.code,
      isActive: building.isActive,
    });
    setEditor({ kind: 'buildings', id: building.id });
  };

  const openRoomEditor = (room: Room) => {
    setFieldErrors({});
    setRoomForm({
      campusId: room.building.campus.id,
      buildingId: room.building.id,
      name: room.name,
      code: room.code,
      capacity: room.capacity === null ? '' : String(room.capacity),
      isActive: room.isActive,
    });
    setEditor({ kind: 'rooms', id: room.id });
  };

  const closeEditor = () => {
    setEditor(null);
    setFieldErrors({});
    setIsSaving(false);
  };

  const handleEditorSubmit = async (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    if (!editor) return;

    try {
      setIsSaving(true);
      setFieldErrors({});

      if (editor.kind === 'campuses') {
        const payload = {
          name: campusForm.name.trim(),
          code: campusForm.code.trim(),
          address: campusForm.address.trim(),
          isActive: campusForm.isActive,
        };
        await runActionWithToast(
          () => editor.id ? updateCampusById(editor.id, payload) : createCampus(payload),
          {
            loading: editor.id ? 'Đang cập nhật cơ sở...' : 'Đang tạo cơ sở...',
            success: editor.id ? 'Đã cập nhật cơ sở.' : 'Đã tạo cơ sở mới.',
            error: editor.id ? 'Không thể cập nhật cơ sở.' : 'Không thể tạo cơ sở.',
          }
        );
      } else if (editor.kind === 'buildings') {
        const payload = {
          campusId: buildingForm.campusId,
          name: buildingForm.name.trim(),
          code: buildingForm.code.trim(),
          isActive: buildingForm.isActive,
        };
        await runActionWithToast(
          () => editor.id ? updateBuildingById(editor.id, payload) : createBuilding(payload),
          {
            loading: editor.id ? 'Đang cập nhật tòa nhà...' : 'Đang tạo tòa nhà...',
            success: editor.id ? 'Đã cập nhật tòa nhà.' : 'Đã tạo tòa nhà mới.',
            error: editor.id ? 'Không thể cập nhật tòa nhà.' : 'Không thể tạo tòa nhà.',
          }
        );
      } else {
        const capacity = roomForm.capacity.trim() ? Number(roomForm.capacity) : null;
        if (capacity !== null && (!Number.isInteger(capacity) || capacity <= 0)) {
          setFieldErrors({ capacity: ['Sức chứa phải là số nguyên lớn hơn 0.'] });
          return;
        }

        const payload = {
          buildingId: roomForm.buildingId,
          name: roomForm.name.trim(),
          code: roomForm.code.trim(),
          capacity,
          isActive: roomForm.isActive,
        };
        await runActionWithToast(
          () => editor.id ? updateRoomById(editor.id, payload) : createRoom(payload),
          {
            loading: editor.id ? 'Đang cập nhật phòng...' : 'Đang tạo phòng...',
            success: editor.id ? 'Đã cập nhật phòng.' : 'Đã tạo phòng mới.',
            error: editor.id ? 'Không thể cập nhật phòng.' : 'Không thể tạo phòng.',
          }
        );
      }

      closeEditor();
      await loadLocations();
    } catch (saveError) {
      setFieldErrors(getApiFieldErrors(saveError));
    } finally {
      setIsSaving(false);
    }
  };

  const handleDeleteConfirm = async () => {
    if (!deleteTarget) return;

    const target = deleteTarget;
    setDeleteTarget(null);

    await runActionWithToast(
      () => {
        if (target.kind === 'campuses') {
          return deleteCampusById(target.id);
        }
        if (target.kind === 'buildings') {
          return deleteBuildingById(target.id);
        }
        return deleteRoomById(target.id);
      },
      {
        loading: `Đang xử lý ${target.name}...`,
        success: target.eventCount > 0
          ? `Đã chuyển ${target.name} sang tạm ẩn để giữ lịch sử sự kiện.`
          : `Đã xóa ${target.name}.`,
        error: `Không thể xử lý ${target.name}.`,
      }
    );
    await loadLocations();
  };

  if (isLoading) {
    return <ListSkeleton rows={8} />;
  }

  if (error) {
    return (
      <ErrorState
        title="Không thể tải địa điểm"
        message={error}
        onRetry={() => {
          void loadLocations();
        }}
      />
    );
  }

  return (
    <div className="space-y-8">
      <div className="flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
        <div>
          <h2 className="text-2xl font-bold tracking-tight text-slate-900">Quản lý địa điểm</h2>
          <p className="mt-1 text-sm font-medium text-slate-500">
            Quản lý cơ sở, tòa nhà và phòng dùng cho lịch sự kiện.
          </p>
        </div>
        <Button
          type="button"
          variant="primary"
          onClick={openCreateEditor}
          leftIcon={<Plus className="h-5 w-5" />}
          className="rounded-xl shadow-lg shadow-amber-500/30"
        >
          {getCreateButtonLabel(activeTab)}
        </Button>
      </div>

      <div className="grid grid-cols-1 gap-4 md:grid-cols-4">
        <StatsCard label="Tổng cơ sở" value={stats?.totalCampuses ?? 0} subValue={`${stats?.activeCampuses ?? 0} đang hoạt động`} />
        <StatsCard label="Tổng tòa nhà" value={stats?.totalBuildings ?? 0} subValue={`${stats?.activeBuildings ?? 0} đang hoạt động`} />
        <StatsCard label="Phòng hoạt động" value={stats?.activeRooms ?? 0} subValue={`${stats?.roomsWithEvents ?? 0} phòng đã có sự kiện`} />
        <StatsCard label="Tổng sức chứa" value={(stats?.totalCapacity ?? 0).toLocaleString('vi-VN')} subValue={`${stats?.totalRooms ?? 0} phòng trong hệ thống`} highlight />
      </div>

      <div className="grid grid-cols-1 gap-3 md:grid-cols-3">
        {tabOptions.map((tab) => (
          <button
            key={tab.value}
            type="button"
            onClick={() => handleTabChange(tab.value)}
            className={cn(
              'rounded-2xl border p-4 text-left transition-all',
              activeTab === tab.value
                ? 'border-amber-300 bg-amber-50 text-amber-950 shadow-sm'
                : 'border-white/70 bg-white/70 text-slate-600 hover:border-amber-200 hover:bg-white'
            )}
          >
            <span className="text-sm font-black">{tab.label}</span>
            <span className="mt-1 block text-xs font-medium">{tab.description}</span>
          </button>
        ))}
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
            placeholder="Tìm theo tên, mã hoặc địa chỉ"
            className="h-10 w-full rounded-xl border border-slate-200 bg-white pl-10 pr-3 text-sm text-slate-800 outline-none focus:border-amber-500 focus:ring-4 focus:ring-amber-500/10"
          />
        </label>
        <AdminSelect
          value={statusFilter}
          onChange={(nextValue) => {
            setStatusFilter(nextValue as StatusFilter);
            setCurrentPage(1);
          }}
          options={statusOptions}
          ariaLabel="Lọc theo trạng thái địa điểm"
        />
        <AdminSelect
          value={ordering}
          onChange={(nextValue) => {
            setOrdering(nextValue);
            setCurrentPage(1);
          }}
          options={orderingOptions[activeTab]}
          ariaLabel="Sắp xếp danh sách địa điểm"
        />
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

        {activeTab !== 'campuses' ? (
          <AdminSelect
            value={campusFilter}
            onChange={(nextValue) => {
              setCampusFilter(nextValue);
              setBuildingFilter('all');
              setCurrentPage(1);
            }}
            options={campusSelectOptions}
            ariaLabel="Lọc theo cơ sở"
            className="md:col-span-2"
          />
        ) : null}

        {activeTab === 'rooms' ? (
          <AdminSelect
            value={buildingFilter}
            onChange={(nextValue) => {
              setBuildingFilter(nextValue);
              setCurrentPage(1);
            }}
            options={buildingSelectOptions}
            ariaLabel="Lọc theo tòa nhà"
            className="md:col-span-2"
          />
        ) : null}
      </form>

      <div className="overflow-hidden rounded-3xl border border-white/60 bg-white/80 shadow-lg backdrop-blur-xl">
        <div className="overflow-x-auto">
          {activeTab === 'campuses' ? (
            <CampusesTable campuses={campuses} onEdit={openCampusEditor} onDelete={setDeleteTarget} />
          ) : activeTab === 'buildings' ? (
            <BuildingsTable buildings={buildings} onEdit={openBuildingEditor} onDelete={setDeleteTarget} />
          ) : (
            <RoomsTable rooms={rooms} onEdit={openRoomEditor} onDelete={setDeleteTarget} />
          )}
        </div>

        {getActiveItems(activeTab, campuses, buildings, rooms).length === 0 ? (
          <div className="p-8">
            <EmptyState
              title="Không tìm thấy địa điểm"
              description="Hãy tạo dữ liệu mới hoặc xóa bộ lọc hiện tại để xem kết quả."
              actionLabel={getCreateButtonLabel(activeTab)}
              onAction={openCreateEditor}
            />
          </div>
        ) : null}

        <div className="flex flex-col gap-3 bg-slate-50/30 px-4 py-4 sm:px-8 md:flex-row md:items-center md:justify-between">
          <p className="text-xs font-medium text-slate-500">
            Hiển thị {visibleStart}-{visibleEnd} trong {totalItems} mục
          </p>
          <div className="flex gap-2">
            <button
              type="button"
              onClick={() => setCurrentPage((prev) => Math.max(1, prev - 1))}
              disabled={safeCurrentPage === 1}
              className="rounded-lg border border-slate-200 bg-white p-2 text-slate-400 transition-colors disabled:opacity-50"
            >
              <ChevronLeft className="h-4 w-4" />
            </button>
            <span className="inline-flex min-w-20 items-center justify-center rounded-lg border border-slate-200 bg-white px-3 text-xs font-bold text-slate-600">
              {safeCurrentPage}/{totalPages}
            </span>
            <button
              type="button"
              onClick={() => setCurrentPage((prev) => Math.min(totalPages, prev + 1))}
              disabled={safeCurrentPage >= totalPages}
              className="rounded-lg border border-slate-200 bg-white p-2 text-slate-400 transition-colors hover:text-amber-600 disabled:opacity-50"
            >
              <ChevronRight className="h-4 w-4" />
            </button>
          </div>
        </div>
      </div>

      {editor ? (
        <LocationEditor
          editor={editor}
          campusForm={campusForm}
          buildingForm={buildingForm}
          roomForm={roomForm}
          campusOptions={campusOptions}
          buildingOptions={roomFormBuildingOptions}
          fieldErrors={fieldErrors}
          isSaving={isSaving}
          onCampusFormChange={setCampusForm}
          onBuildingFormChange={setBuildingForm}
          onRoomFormChange={setRoomForm}
          onClose={closeEditor}
          onSubmit={handleEditorSubmit}
        />
      ) : null}

      <ConfirmActionDialog
        open={deleteTarget !== null}
        onOpenChange={(open) => {
          if (!open) {
            setDeleteTarget(null);
          }
        }}
        title="Xác nhận xóa địa điểm"
        description={deleteTarget
          ? `${deleteTarget.name} sẽ bị xóa nếu chưa có liên kết. Nếu đã có sự kiện hoặc dữ liệu con, hệ thống sẽ chuyển sang tạm ẩn để giữ lịch sử.`
          : 'Bạn sắp xóa một địa điểm.'}
        confirmLabel="Xác nhận"
        cancelLabel="Hủy"
        variant="danger"
        onConfirm={() => {
          void handleDeleteConfirm();
        }}
      />
    </div>
  );
}

function StatsCard({
  label,
  value,
  subValue,
  highlight = false,
}: {
  label: string;
  value: string | number;
  subValue: string;
  highlight?: boolean;
}) {
  return (
    <Card className={cn('glass-card rounded-2xl border-none p-6', highlight && 'bg-amber-50/70')}>
      <p className="mb-1 text-[10px] font-bold uppercase tracking-widest text-slate-400">{label}</p>
      <p className={cn('text-3xl font-extrabold', highlight ? 'text-amber-900' : 'text-slate-900')}>{value}</p>
      <p className="mt-1 text-xs font-semibold text-slate-500">{subValue}</p>
    </Card>
  );
}

function CampusesTable({
  campuses,
  onEdit,
  onDelete,
}: {
  campuses: Campus[];
  onEdit: (campus: Campus) => void;
  onDelete: (target: DeleteTarget) => void;
}) {
  return (
    <table className="min-w-[980px] w-full border-collapse text-left">
      <TableHead columns={['Cơ sở', 'Địa chỉ', 'Tòa nhà', 'Phòng', 'Sự kiện', 'Trạng thái', 'Cập nhật', 'Hành động']} />
      <tbody className="divide-y divide-slate-100">
        {campuses.map((campus) => (
          <tr key={campus.id} className="group transition-colors hover:bg-amber-50/30">
            <td className="px-6 py-5">
              <EntityTitle icon={<MapPinned className="h-5 w-5" />} title={campus.name} subtitle={campus.code} />
            </td>
            <td className="max-w-xs px-6 py-5 text-sm font-medium text-slate-600">
              <span className="line-clamp-2">{campus.address || 'Chưa có địa chỉ'}</span>
            </td>
            <CountCell value={campus.buildingCount} label="tòa" />
            <CountCell value={campus.roomCount} label="phòng" />
            <CountCell value={campus.eventCount} label="sự kiện" />
            <td className="px-6 py-5"><StatusBadge isActive={campus.isActive} /></td>
            <DateCell value={campus.updatedAt} />
            <ActionCell
              onEdit={() => onEdit(campus)}
              onDelete={() => onDelete({ kind: 'campuses', id: campus.id, name: campus.name, eventCount: campus.eventCount })}
            />
          </tr>
        ))}
      </tbody>
    </table>
  );
}

function BuildingsTable({
  buildings,
  onEdit,
  onDelete,
}: {
  buildings: Building[];
  onEdit: (building: Building) => void;
  onDelete: (target: DeleteTarget) => void;
}) {
  return (
    <table className="min-w-[900px] w-full border-collapse text-left">
      <TableHead columns={['Tòa nhà', 'Cơ sở', 'Phòng', 'Sự kiện', 'Trạng thái', 'Cập nhật', 'Hành động']} />
      <tbody className="divide-y divide-slate-100">
        {buildings.map((building) => (
          <tr key={building.id} className="group transition-colors hover:bg-amber-50/30">
            <td className="px-6 py-5">
              <EntityTitle icon={<Building2 className="h-5 w-5" />} title={building.name} subtitle={building.code} />
            </td>
            <td className="px-6 py-5 text-sm font-semibold text-slate-600">
              {building.campus.name}
              <span className="ml-2 rounded-full bg-slate-100 px-2 py-0.5 text-xs text-slate-500">{building.campus.code}</span>
            </td>
            <CountCell value={building.roomCount} label="phòng" />
            <CountCell value={building.eventCount} label="sự kiện" />
            <td className="px-6 py-5"><StatusBadge isActive={building.isActive} /></td>
            <DateCell value={building.updatedAt} />
            <ActionCell
              onEdit={() => onEdit(building)}
              onDelete={() => onDelete({ kind: 'buildings', id: building.id, name: building.name, eventCount: building.eventCount })}
            />
          </tr>
        ))}
      </tbody>
    </table>
  );
}

function RoomsTable({
  rooms,
  onEdit,
  onDelete,
}: {
  rooms: Room[];
  onEdit: (room: Room) => void;
  onDelete: (target: DeleteTarget) => void;
}) {
  return (
    <table className="min-w-[1000px] w-full border-collapse text-left">
      <TableHead columns={['Phòng', 'Tòa nhà', 'Cơ sở', 'Sức chứa', 'Sự kiện', 'Trạng thái', 'Cập nhật', 'Hành động']} />
      <tbody className="divide-y divide-slate-100">
        {rooms.map((room) => (
          <tr key={room.id} className="group transition-colors hover:bg-amber-50/30">
            <td className="px-6 py-5">
              <EntityTitle icon={<MapPinned className="h-5 w-5" />} title={room.name} subtitle={room.code} />
            </td>
            <td className="px-6 py-5 text-sm font-semibold text-slate-600">{room.building.name}</td>
            <td className="px-6 py-5 text-sm font-semibold text-slate-600">{room.building.campus.name}</td>
            <CountCell value={room.capacity ?? 0} label={room.capacity ? 'chỗ' : 'chưa đặt'} muted={!room.capacity} />
            <CountCell value={room.eventCount} label="sự kiện" />
            <td className="px-6 py-5"><StatusBadge isActive={room.isActive} /></td>
            <DateCell value={room.updatedAt} />
            <ActionCell
              onEdit={() => onEdit(room)}
              onDelete={() => onDelete({ kind: 'rooms', id: room.id, name: room.name, eventCount: room.eventCount })}
            />
          </tr>
        ))}
      </tbody>
    </table>
  );
}

function TableHead({ columns }: { columns: string[] }) {
  return (
    <thead>
      <tr className="bg-slate-50/50">
        {columns.map((column) => (
          <th key={column} className="px-6 py-5 text-[10px] font-extrabold uppercase tracking-widest text-slate-400">
            {column}
          </th>
        ))}
      </tr>
    </thead>
  );
}

function EntityTitle({ icon, title, subtitle }: { icon: React.ReactNode; title: string; subtitle: string }) {
  return (
    <div className="flex items-center gap-3">
      <span className="flex h-10 w-10 items-center justify-center rounded-xl bg-amber-50 text-amber-600">
        {icon}
      </span>
      <span className="min-w-0">
        <span className="block truncate text-sm font-bold text-slate-900">{title}</span>
        <span className="text-xs font-bold uppercase tracking-wider text-slate-400">{subtitle}</span>
      </span>
    </div>
  );
}

function CountCell({ value, label, muted = false }: { value: number; label: string; muted?: boolean }) {
  return (
    <td className="px-6 py-5">
      <span className={cn('rounded-full px-3 py-1 text-sm font-semibold', muted ? 'bg-slate-50 text-slate-400' : 'bg-slate-100 text-slate-600')}>
        {value} {label}
      </span>
    </td>
  );
}

function DateCell({ value }: { value: string }) {
  return (
    <td className="px-6 py-5">
      <span className="text-sm font-medium text-slate-500">
        {new Date(value).toLocaleDateString('vi-VN', {
          day: '2-digit',
          month: 'short',
          year: 'numeric',
        })}
      </span>
    </td>
  );
}

function StatusBadge({ isActive }: { isActive: boolean }) {
  return (
    <div className={cn('flex items-center gap-1.5', isActive ? 'text-emerald-600' : 'text-slate-400')}>
      <span className={cn('h-2 w-2 rounded-full', isActive ? 'bg-emerald-500' : 'bg-slate-300')} />
      <span className="text-xs font-bold uppercase tracking-wider">
        {isActive ? 'Đang hoạt động' : 'Tạm ẩn'}
      </span>
    </div>
  );
}

function ActionCell({ onEdit, onDelete }: { onEdit: () => void; onDelete: () => void }) {
  return (
    <td className="px-6 py-5 text-right">
      <div className="flex items-center justify-end gap-2 opacity-100 transition-opacity lg:opacity-0 lg:group-hover:opacity-100">
        <button
          type="button"
          onClick={onEdit}
          className="rounded-lg p-2 text-slate-400 transition-all hover:bg-amber-50 hover:text-amber-600"
          aria-label="Chỉnh sửa"
        >
          <Edit className="h-4 w-4" />
        </button>
        <button
          type="button"
          onClick={onDelete}
          className="rounded-lg p-2 text-slate-400 transition-all hover:bg-red-50 hover:text-red-600"
          aria-label="Xóa"
        >
          <Trash2 className="h-4 w-4" />
        </button>
      </div>
    </td>
  );
}

function LocationEditor({
  editor,
  campusForm,
  buildingForm,
  roomForm,
  campusOptions,
  buildingOptions,
  fieldErrors,
  isSaving,
  onCampusFormChange,
  onBuildingFormChange,
  onRoomFormChange,
  onClose,
  onSubmit,
}: {
  editor: NonNullable<EditorState>;
  campusForm: CampusFormState;
  buildingForm: BuildingFormState;
  roomForm: RoomFormState;
  campusOptions: Campus[];
  buildingOptions: Array<{ value: string; label: string; description?: string }>;
  fieldErrors: ApiFieldErrors;
  isSaving: boolean;
  onCampusFormChange: (form: CampusFormState) => void;
  onBuildingFormChange: (form: BuildingFormState) => void;
  onRoomFormChange: (form: RoomFormState) => void;
  onClose: () => void;
  onSubmit: (event: FormEvent<HTMLFormElement>) => void;
}) {
  const title = `${editor.id ? 'Cập nhật' : 'Tạo'} ${getEntityLabel(editor.kind).toLowerCase()}`;
  const campusSelectValues = campusOptions.map((campus) => ({
    value: campus.id,
    label: `${campus.name} (${campus.code})`,
  }));

  return (
    <div className="fixed inset-0 z-[90] bg-slate-950/40 backdrop-blur-sm">
      <div className="fixed bottom-0 right-0 top-0 w-full overflow-y-auto border-l border-white/60 bg-white p-6 shadow-2xl sm:max-w-xl">
        <div className="mb-6 flex items-start justify-between gap-4">
          <div>
            <p className="text-xs font-bold uppercase tracking-widest text-amber-600">{getEntityLabel(editor.kind)}</p>
            <h3 className="mt-1 text-xl font-black text-slate-900">{title}</h3>
          </div>
          <button
            type="button"
            onClick={onClose}
            className="rounded-xl p-2 text-slate-400 transition hover:bg-slate-100 hover:text-slate-700"
            aria-label="Đóng"
          >
            <X className="h-5 w-5" />
          </button>
        </div>

        <form onSubmit={onSubmit} className="space-y-5">
          {editor.kind === 'campuses' ? (
            <>
              <Input
                label="Tên cơ sở"
                value={campusForm.name}
                onChange={(event) => onCampusFormChange({ ...campusForm, name: event.target.value })}
                error={fieldErrors.name?.[0]}
                required
              />
              <Input
                label="Mã cơ sở"
                value={campusForm.code}
                onChange={(event) => onCampusFormChange({ ...campusForm, code: event.target.value })}
                error={fieldErrors.code?.[0]}
                required
              />
              <Input
                label="Địa chỉ"
                value={campusForm.address}
                onChange={(event) => onCampusFormChange({ ...campusForm, address: event.target.value })}
                error={fieldErrors.address?.[0]}
              />
              <ActiveToggle
                checked={campusForm.isActive}
                onChange={(checked) => onCampusFormChange({ ...campusForm, isActive: checked })}
              />
            </>
          ) : null}

          {editor.kind === 'buildings' ? (
            <>
              <SelectField label="Cơ sở" error={fieldErrors.campus_id?.[0] || fieldErrors.campus?.[0]}>
                <AdminSelect
                  value={buildingForm.campusId}
                  onChange={(nextValue) => onBuildingFormChange({ ...buildingForm, campusId: nextValue })}
                  options={campusSelectValues}
                  disabled={campusSelectValues.length === 0}
                  ariaLabel="Chọn cơ sở cho tòa nhà"
                />
              </SelectField>
              <Input
                label="Tên tòa nhà"
                value={buildingForm.name}
                onChange={(event) => onBuildingFormChange({ ...buildingForm, name: event.target.value })}
                error={fieldErrors.name?.[0]}
                required
              />
              <Input
                label="Mã tòa nhà"
                value={buildingForm.code}
                onChange={(event) => onBuildingFormChange({ ...buildingForm, code: event.target.value })}
                error={fieldErrors.code?.[0]}
                required
              />
              <ActiveToggle
                checked={buildingForm.isActive}
                onChange={(checked) => onBuildingFormChange({ ...buildingForm, isActive: checked })}
              />
            </>
          ) : null}

          {editor.kind === 'rooms' ? (
            <>
              <SelectField label="Cơ sở" error={fieldErrors.campus_id?.[0]}>
                <AdminSelect
                  value={roomForm.campusId}
                  onChange={(nextValue) => {
                    onRoomFormChange({
                      ...roomForm,
                      campusId: nextValue,
                      buildingId: '',
                    });
                  }}
                  options={campusSelectValues}
                  disabled={campusSelectValues.length === 0}
                  ariaLabel="Chọn cơ sở để lọc tòa nhà"
                />
              </SelectField>
              <SelectField label="Tòa nhà" error={fieldErrors.building_id?.[0] || fieldErrors.building?.[0]}>
                <AdminSelect
                  value={roomForm.buildingId}
                  onChange={(nextValue) => onRoomFormChange({ ...roomForm, buildingId: nextValue })}
                  options={buildingOptions}
                  disabled={buildingOptions.length === 0}
                  ariaLabel="Chọn tòa nhà cho phòng"
                />
              </SelectField>
              <Input
                label="Tên phòng"
                value={roomForm.name}
                onChange={(event) => onRoomFormChange({ ...roomForm, name: event.target.value })}
                error={fieldErrors.name?.[0]}
                required
              />
              <Input
                label="Mã phòng"
                value={roomForm.code}
                onChange={(event) => onRoomFormChange({ ...roomForm, code: event.target.value })}
                error={fieldErrors.code?.[0]}
                required
              />
              <Input
                label="Sức chứa"
                type="number"
                min={1}
                value={roomForm.capacity}
                onChange={(event) => onRoomFormChange({ ...roomForm, capacity: event.target.value })}
                error={fieldErrors.capacity?.[0]}
                hint="Có thể bỏ trống nếu chưa xác định."
              />
              <ActiveToggle
                checked={roomForm.isActive}
                onChange={(checked) => onRoomFormChange({ ...roomForm, isActive: checked })}
              />
            </>
          ) : null}

          <div className="flex justify-end gap-3 border-t border-slate-100 pt-5">
            <Button type="button" variant="outline" onClick={onClose}>
              Hủy
            </Button>
            <Button type="submit" isLoading={isSaving}>
              Lưu
            </Button>
          </div>
        </form>
      </div>
    </div>
  );
}

function SelectField({ label, error, children }: { label: string; error?: string; children: React.ReactNode }) {
  return (
    <div className="space-y-2">
      <p className="ml-1 text-xs font-bold uppercase tracking-widest text-on-surface-variant">{label}</p>
      {children}
      {error ? <p className="ml-1 text-xs text-error">{error}</p> : null}
    </div>
  );
}

function ActiveToggle({ checked, onChange }: { checked: boolean; onChange: (checked: boolean) => void }) {
  return (
    <label className="flex items-center justify-between rounded-2xl bg-slate-50 px-4 py-3">
      <span>
        <span className="block text-sm font-bold text-slate-800">Đang hoạt động</span>
        <span className="text-xs font-medium text-slate-500">Hiển thị trong các form chọn địa điểm mới.</span>
      </span>
      <input
        type="checkbox"
        checked={checked}
        onChange={(event) => onChange(event.target.checked)}
        className="h-5 w-5 rounded border-slate-300 text-amber-500 focus:ring-amber-500"
      />
    </label>
  );
}

function getCreateButtonLabel(tab: LocationTab): string {
  if (tab === 'campuses') return 'Thêm cơ sở';
  if (tab === 'buildings') return 'Thêm tòa nhà';
  return 'Thêm phòng';
}

function getEntityLabel(tab: LocationTab): string {
  if (tab === 'campuses') return 'Cơ sở';
  if (tab === 'buildings') return 'Tòa nhà';
  return 'Phòng';
}

function getActiveItems(tab: LocationTab, campuses: Campus[], buildings: Building[], rooms: Room[]) {
  if (tab === 'campuses') return campuses;
  if (tab === 'buildings') return buildings;
  return rooms;
}
