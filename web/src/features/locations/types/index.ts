export type LocationStatusFilter = 'all' | 'active' | 'inactive';
export type LocationTab = 'campuses' | 'buildings' | 'rooms';

export interface Campus {
  id: string;
  name: string;
  code: string;
  address: string;
  isActive: boolean;
  buildingCount: number;
  roomCount: number;
  eventCount: number;
  createdAt: string;
  updatedAt: string;
}

export interface Building {
  id: string;
  campus: Pick<Campus, 'id' | 'name' | 'code'>;
  name: string;
  code: string;
  isActive: boolean;
  roomCount: number;
  eventCount: number;
  createdAt: string;
  updatedAt: string;
}

export interface Room {
  id: string;
  building: {
    id: string;
    name: string;
    code: string;
    campus: Pick<Campus, 'id' | 'name' | 'code'>;
  };
  name: string;
  code: string;
  capacity: number | null;
  isActive: boolean;
  eventCount: number;
  createdAt: string;
  updatedAt: string;
}

export interface LocationStats {
  totalCampuses: number;
  activeCampuses: number;
  totalBuildings: number;
  activeBuildings: number;
  totalRooms: number;
  activeRooms: number;
  roomsWithEvents: number;
  totalCapacity: number;
}

export interface LocationListResult<T> {
  items: T[];
  total: number;
  page: number;
  pageSize: number;
  totalPages: number;
}

export interface AdminCampusDto {
  id: string;
  name: string;
  code: string;
  address: string;
  is_active: boolean;
  building_count: number;
  room_count: number;
  event_count: number;
  created_at: string;
  updated_at: string;
}

export interface AdminCampusSummaryDto {
  id: string;
  name: string;
  code: string;
}

export interface AdminBuildingDto {
  id: string;
  campus: AdminCampusSummaryDto;
  name: string;
  code: string;
  is_active: boolean;
  room_count: number;
  event_count: number;
  created_at: string;
  updated_at: string;
}

export interface AdminBuildingSummaryDto {
  id: string;
  name: string;
  code: string;
  campus: AdminCampusSummaryDto;
}

export interface AdminRoomDto {
  id: string;
  building: AdminBuildingSummaryDto;
  name: string;
  code: string;
  capacity: number | null;
  is_active: boolean;
  event_count: number;
  created_at: string;
  updated_at: string;
}

export interface AdminLocationStatsDto {
  total_campuses: number;
  active_campuses: number;
  total_buildings: number;
  active_buildings: number;
  total_rooms: number;
  active_rooms: number;
  rooms_with_events: number;
  total_capacity: number;
}

export interface SaveCampusPayload {
  name: string;
  code: string;
  address: string;
  isActive: boolean;
}

export interface SaveBuildingPayload {
  campusId: string;
  name: string;
  code: string;
  isActive: boolean;
}

export interface SaveRoomPayload {
  buildingId: string;
  name: string;
  code: string;
  capacity: number | null;
  isActive: boolean;
}
