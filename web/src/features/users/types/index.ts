// File: src/features/users/types/index.ts

export interface User {
  id: string;
  name: string;
  email: string;
  studentId: string;
  role: 'student' | 'organizer' | 'admin';
  status: 'active' | 'pending' | 'banned';
  avatar?: string;
  faculty?: string;
  className?: string;
  phoneNumber?: string;
  username?: string;
  createdAt: string;
  passkeys: PasskeyCredential[];
}

export interface PasskeyCredential {
  id: string;
  deviceName: string;
  deviceType: string;
  backedUp: boolean;
  transports: string[];
  signCount: number;
  isActive: boolean;
  createdAt: string;
  lastUsedAt?: string | null;
  revokedAt?: string | null;
}

export type UserRole = User['role'];
export type UserStatus = User['status'];

export interface AdminRoleDto {
  code: string;
  name: string;
  description: string;
}

export interface AdminUserRoleDto {
  role: AdminRoleDto;
  is_primary: boolean;
  assigned_at: string;
}

export interface AdminUserDto {
  id: string;
  username: string;
  email: string;
  full_name: string;
  student_code: string | null;
  faculty: string | null;
  class_name: string | null;
  account_status: string;
  is_active: boolean;
  phone_number?: string | null;
  avatar_url?: string | null;
  created_at: string;
  updated_at: string;
  user_roles: AdminUserRoleDto[];
  passkey_credentials?: AdminPasskeyCredentialDto[];
}

export interface AdminPasskeyCredentialDto {
  id: string;
  device_name: string;
  device_type: string;
  backed_up: boolean;
  transports: string[];
  sign_count: number;
  is_active: boolean;
  created_at: string;
  last_used_at: string | null;
  revoked_at: string | null;
}

export interface UserStats {
  totalUsers: number;
  activeOrganizers: number;
  pendingRequests: number;
  bannedUsers: number;
}

export interface AdminUserStatsDto {
  total_users: number;
  total_deleted: number;
  by_status: {
    active: number;
    pending: number;
    banned: number;
  };
  by_faculty: Array<{
    faculty: string;
    count: number;
  }>;
  by_role: Array<{
    role__code: string;
    role__name: string;
    count: number;
  }>;
  new_users_per_day: Array<{
    date: string;
    count: number;
  }>;
}

export interface CreateUserPayload {
  username: string;
  email: string;
  password: string;
  full_name: string;
  student_code?: string;
  phone_number?: string;
  faculty?: string;
  class_name?: string;
  role_codes?: string[];
}

export interface UpdateUserPayload {
  full_name?: string;
  phone_number?: string;
  student_code?: string;
  faculty?: string;
  class_name?: string;
  role_codes?: string[];
}
