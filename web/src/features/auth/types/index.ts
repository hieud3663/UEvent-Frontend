// File: src/features/auth/types/index.ts

export interface AdminUserInfo {
  id: string;
  username: string;
  fullName: string;
  email: string;
  avatarUrl: string;
  isSuperuser: boolean;
}

export interface AdminLoginPayload {
  username: string;
  password: string;
}

export interface AdminLoginResult {
  access: string;
  refresh: string;
  user: AdminUserInfo;
}

export interface AdminUserInfoDto {
  id: string;
  username: string;
  full_name: string;
  email: string;
  avatar_url: string;
  is_superuser: boolean;
}

export interface AdminLoginResultDto {
  access: string;
  refresh: string;
  user: AdminUserInfoDto;
}
