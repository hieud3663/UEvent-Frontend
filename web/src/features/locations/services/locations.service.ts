import { apiRequest, apiRequestEnvelope } from '@/core/lib/api';
import type {
  AdminBuildingDto,
  AdminCampusDto,
  AdminLocationStatsDto,
  AdminRoomDto,
  Building,
  Campus,
  LocationListResult,
  LocationStats,
  SaveBuildingPayload,
  SaveCampusPayload,
  SaveRoomPayload,
  Room,
} from '../types';

export interface CampusFilters {
  keyword?: string;
  isActive?: boolean;
  ordering?: string;
  page?: number;
  pageSize?: number;
}

export interface BuildingFilters extends CampusFilters {
  campusId?: string;
}

export interface RoomFilters extends CampusFilters {
  campusId?: string;
  buildingId?: string;
}

export async function getLocationStats(): Promise<LocationStats> {
  const response = await apiRequest<AdminLocationStatsDto>('/admin/locations/statistics/');
  return {
    totalCampuses: response.total_campuses,
    activeCampuses: response.active_campuses,
    totalBuildings: response.total_buildings,
    activeBuildings: response.active_buildings,
    totalRooms: response.total_rooms,
    activeRooms: response.active_rooms,
    roomsWithEvents: response.rooms_with_events,
    totalCapacity: response.total_capacity,
  };
}

export async function getCampusesPage(filters: CampusFilters = {}): Promise<LocationListResult<Campus>> {
  const envelope = await apiRequestEnvelope<AdminCampusDto[]>(
    `/admin/locations/campuses/?${buildListParams(filters).toString()}`
  );
  const items = envelope.data.map(mapCampus);
  const pagination = envelope.meta.pagination;

  return {
    items,
    total: pagination?.count ?? items.length,
    page: pagination?.page ?? filters.page ?? 1,
    pageSize: pagination?.page_size ?? filters.pageSize ?? items.length,
    totalPages: pagination?.total_pages ?? 1,
  };
}

export async function getBuildingsPage(filters: BuildingFilters = {}): Promise<LocationListResult<Building>> {
  const params = buildListParams(filters);
  if (filters.campusId) {
    params.set('campus', filters.campusId);
  }

  const envelope = await apiRequestEnvelope<AdminBuildingDto[]>(
    `/admin/locations/buildings/?${params.toString()}`
  );
  const items = envelope.data.map(mapBuilding);
  const pagination = envelope.meta.pagination;

  return {
    items,
    total: pagination?.count ?? items.length,
    page: pagination?.page ?? filters.page ?? 1,
    pageSize: pagination?.page_size ?? filters.pageSize ?? items.length,
    totalPages: pagination?.total_pages ?? 1,
  };
}

export async function getRoomsPage(filters: RoomFilters = {}): Promise<LocationListResult<Room>> {
  const params = buildListParams(filters);
  if (filters.campusId) {
    params.set('campus', filters.campusId);
  }
  if (filters.buildingId) {
    params.set('building', filters.buildingId);
  }

  const envelope = await apiRequestEnvelope<AdminRoomDto[]>(
    `/admin/locations/rooms/?${params.toString()}`
  );
  const items = envelope.data.map(mapRoom);
  const pagination = envelope.meta.pagination;

  return {
    items,
    total: pagination?.count ?? items.length,
    page: pagination?.page ?? filters.page ?? 1,
    pageSize: pagination?.page_size ?? filters.pageSize ?? items.length,
    totalPages: pagination?.total_pages ?? 1,
  };
}

export async function createCampus(payload: SaveCampusPayload): Promise<Campus> {
  const response = await apiRequest<AdminCampusDto>('/admin/locations/campuses/', {
    method: 'POST',
    body: mapCampusPayload(payload),
  });
  return mapCampus(response);
}

export async function updateCampusById(campusId: string, payload: SaveCampusPayload): Promise<Campus> {
  const response = await apiRequest<AdminCampusDto>(`/admin/locations/campuses/${campusId}/`, {
    method: 'PATCH',
    body: mapCampusPayload(payload),
  });
  return mapCampus(response);
}

export async function deleteCampusById(
  campusId: string,
  reason = 'Quản trị viên đã xóa hoặc vô hiệu hóa cơ sở từ bảng điều khiển web.'
): Promise<void> {
  await apiRequest<void>(`/admin/locations/campuses/${campusId}/`, {
    method: 'DELETE',
    body: { reason },
  });
}

export async function createBuilding(payload: SaveBuildingPayload): Promise<Building> {
  const response = await apiRequest<AdminBuildingDto>('/admin/locations/buildings/', {
    method: 'POST',
    body: mapBuildingPayload(payload),
  });
  return mapBuilding(response);
}

export async function updateBuildingById(buildingId: string, payload: SaveBuildingPayload): Promise<Building> {
  const response = await apiRequest<AdminBuildingDto>(`/admin/locations/buildings/${buildingId}/`, {
    method: 'PATCH',
    body: mapBuildingPayload(payload),
  });
  return mapBuilding(response);
}

export async function deleteBuildingById(
  buildingId: string,
  reason = 'Quản trị viên đã xóa hoặc vô hiệu hóa tòa nhà từ bảng điều khiển web.'
): Promise<void> {
  await apiRequest<void>(`/admin/locations/buildings/${buildingId}/`, {
    method: 'DELETE',
    body: { reason },
  });
}

export async function createRoom(payload: SaveRoomPayload): Promise<Room> {
  const response = await apiRequest<AdminRoomDto>('/admin/locations/rooms/', {
    method: 'POST',
    body: mapRoomPayload(payload),
  });
  return mapRoom(response);
}

export async function updateRoomById(roomId: string, payload: SaveRoomPayload): Promise<Room> {
  const response = await apiRequest<AdminRoomDto>(`/admin/locations/rooms/${roomId}/`, {
    method: 'PATCH',
    body: mapRoomPayload(payload),
  });
  return mapRoom(response);
}

export async function deleteRoomById(
  roomId: string,
  reason = 'Quản trị viên đã xóa hoặc vô hiệu hóa phòng từ bảng điều khiển web.'
): Promise<void> {
  await apiRequest<void>(`/admin/locations/rooms/${roomId}/`, {
    method: 'DELETE',
    body: { reason },
  });
}

function buildListParams(filters: CampusFilters): URLSearchParams {
  const params = new URLSearchParams();
  params.set('page', String(filters.page ?? 1));
  params.set('page_size', String(filters.pageSize ?? 10));

  if (filters.keyword?.trim()) {
    params.set('search', filters.keyword.trim());
  }

  if (filters.isActive !== undefined) {
    params.set('is_active', String(filters.isActive));
  }

  if (filters.ordering) {
    params.set('ordering', filters.ordering);
  }

  return params;
}

function mapCampus(dto: AdminCampusDto): Campus {
  return {
    id: dto.id,
    name: dto.name,
    code: dto.code,
    address: dto.address,
    isActive: dto.is_active,
    buildingCount: dto.building_count,
    roomCount: dto.room_count,
    eventCount: dto.event_count,
    createdAt: dto.created_at,
    updatedAt: dto.updated_at,
  };
}

function mapBuilding(dto: AdminBuildingDto): Building {
  return {
    id: dto.id,
    campus: dto.campus,
    name: dto.name,
    code: dto.code,
    isActive: dto.is_active,
    roomCount: dto.room_count,
    eventCount: dto.event_count,
    createdAt: dto.created_at,
    updatedAt: dto.updated_at,
  };
}

function mapRoom(dto: AdminRoomDto): Room {
  return {
    id: dto.id,
    building: dto.building,
    name: dto.name,
    code: dto.code,
    capacity: dto.capacity,
    isActive: dto.is_active,
    eventCount: dto.event_count,
    createdAt: dto.created_at,
    updatedAt: dto.updated_at,
  };
}

function mapCampusPayload(payload: SaveCampusPayload) {
  return {
    name: payload.name,
    code: payload.code,
    address: payload.address,
    is_active: payload.isActive,
  };
}

function mapBuildingPayload(payload: SaveBuildingPayload) {
  return {
    campus_id: payload.campusId,
    name: payload.name,
    code: payload.code,
    is_active: payload.isActive,
  };
}

function mapRoomPayload(payload: SaveRoomPayload) {
  return {
    building_id: payload.buildingId,
    name: payload.name,
    code: payload.code,
    capacity: payload.capacity,
    is_active: payload.isActive,
  };
}
