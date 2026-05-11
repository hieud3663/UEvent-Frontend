import { apiExport, apiRequest, apiRequestEnvelope } from '@/core/lib/api';
import type { ExportFileResult } from '@/core/types/api';
import type {
  AdminUserDto,
  AdminUserStatsDto,
  CreateUserPayload,
  UpdateUserPayload,
  User,
  UserRole,
  UserStats,
  UserStatus,
} from '../types';

export interface UserFilters {
  role?: UserRole;
  status?: UserStatus;
  keyword?: string;
  page?: number;
  pageSize?: number;
}

export interface UsersResponse {
  users: User[];
  total: number;
}

export type UserExportFormat = 'csv' | 'xlsx';

const roleMap: Record<string, UserRole> = {
  student: 'student',
  organizer: 'organizer',
  admin: 'admin',
  system_admin: 'admin',
  faculty_admin: 'admin',
};

function mapStatus(status: string, isActive: boolean): UserStatus {
  if (!isActive || status === 'banned') return 'banned';
  if (status === 'pending') return 'pending';
  return 'active';
}

function mapRole(dto: AdminUserDto): UserRole {
  const primaryRole = dto.user_roles.find((item) => item.is_primary)?.role.code;
  const firstRole = primaryRole ?? dto.user_roles[0]?.role.code ?? 'student';
  return roleMap[firstRole] ?? 'student';
}

function mapUser(dto: AdminUserDto): User {
  return {
    id: dto.id,
    name: dto.full_name || dto.username,
    email: dto.email,
    studentId: dto.student_code ?? '—',
    role: mapRole(dto),
    status: mapStatus(dto.account_status, dto.is_active),
    avatar: dto.avatar_url ?? undefined,
    faculty: dto.faculty ?? undefined,
    className: dto.class_name ?? undefined,
    phoneNumber: dto.phone_number ?? undefined,
    username: dto.username,
    createdAt: dto.created_at,
  };
}

function toRoleCodes(role?: UserRole): string[] | undefined {
  if (!role) return undefined;
  return [role];
}

function toBackendStatus(status?: UserStatus): string | undefined {
  if (!status) return undefined;
  return status;
}

export async function getUsers(filters: UserFilters = {}): Promise<UsersResponse> {
  const params = new URLSearchParams();
  params.set('page', String(filters.page ?? 1));
  params.set('page_size', String(filters.pageSize ?? 100));

  if (filters.keyword?.trim()) {
    params.set('search', filters.keyword.trim());
  }

  const status = toBackendStatus(filters.status);
  if (status) {
    params.set('account_status', status);
  }

  const envelope = await apiRequestEnvelope<AdminUserDto[]>(`/admin/users/?${params.toString()}`);

  let users = envelope.data.map(mapUser);
  if (filters.role) {
    users = users.filter((user) => user.role === filters.role);
  }

  return {
    users,
    total: envelope.meta.pagination?.count ?? users.length,
  };
}

export async function getUserStats(): Promise<UserStats> {
  const response = await apiRequest<AdminUserStatsDto>('/admin/users/statistics/');
  const activeOrganizers = response.by_role
    .filter((item) => item.role__code === 'organizer')
    .reduce((sum, item) => sum + item.count, 0);

  return {
    totalUsers: response.total_users,
    activeOrganizers,
    pendingRequests: response.by_status.pending,
    bannedUsers: response.by_status.banned,
  };
}

export async function getUserById(userId: string): Promise<User | null> {
  try {
    const response = await apiRequest<AdminUserDto>(`/admin/users/${userId}/`);
    return mapUser(response);
  } catch {
    return null;
  }
}

export async function createUser(payload: CreateUserPayload): Promise<User> {
  const response = await apiRequest<AdminUserDto>('/admin/users/create/', {
    method: 'POST',
    body: payload,
  });
  return mapUser(response);
}

export async function updateUserById(userId: string, payload: UpdateUserPayload): Promise<User> {
  const response = await apiRequest<AdminUserDto>(`/admin/users/${userId}/`, {
    method: 'PATCH',
    body: payload,
  });
  return mapUser(response);
}

export async function exportUsers(filters: UserFilters = {}, format: UserExportFormat = 'csv'): Promise<ExportFileResult> {
  const exportFields = ['username', 'email', 'full_name', 'student_code', 'faculty', 'account_status', 'created_at'];
  const params = new URLSearchParams();

  params.set('export_format', format);

  if (filters.keyword?.trim()) {
    params.set('search', filters.keyword.trim());
  }

  if (filters.status) {
    params.set('account_status', filters.status);
  }

  exportFields.forEach((field) => params.append('fields', field));
  const query = params.toString();

  return apiExport(`/admin/users/export/${query ? `?${query}` : ''}`);
}

export function downloadExportFile(result: ExportFileResult): void {
  if (typeof window === 'undefined') return;

  const url = window.URL.createObjectURL(result.blob);
  const link = document.createElement('a');
  link.href = url;
  link.download = result.filename;
  document.body.appendChild(link);
  link.click();
  link.remove();
  window.URL.revokeObjectURL(url);
}

export async function banUserById(userId: string, reason: string): Promise<User> {
  const response = await apiRequest<AdminUserDto>(`/admin/users/${userId}/ban/`, {
    method: 'POST',
    body: { reason },
  });
  return mapUser(response);
}

export async function unbanUserById(userId: string, reason = 'Admin mở khóa từ trang quản trị.'): Promise<User> {
  const response = await apiRequest<AdminUserDto>(`/admin/users/${userId}/unban/`, {
    method: 'POST',
    body: { reason },
  });
  return mapUser(response);
}

export async function restoreUserById(userId: string): Promise<User> {
  const response = await apiRequest<AdminUserDto>(`/admin/users/${userId}/restore/`, {
    method: 'POST',
  });
  return mapUser(response);
}

export function buildCreateUserPayload(formData: FormData): CreateUserPayload {
  const fullName = String(formData.get('full_name') ?? '').trim();
  const email = String(formData.get('email') ?? '').trim();
  const explicitUsername = String(formData.get('username') ?? '').trim();
  const role = String(formData.get('role') ?? 'student') as UserRole;

  return {
    username: explicitUsername || email,
    email,
    password: String(formData.get('password') ?? ''),
    full_name: fullName,
    student_code: String(formData.get('student_code') ?? '').trim() || undefined,
    phone_number: String(formData.get('phone_number') ?? '').trim() || undefined,
    faculty: String(formData.get('faculty') ?? '').trim() || undefined,
    class_name: String(formData.get('class_name') ?? '').trim() || undefined,
    role_codes: toRoleCodes(role),
  };
}
