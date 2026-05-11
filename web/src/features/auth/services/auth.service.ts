// File: src/features/auth/services/auth.service.ts

import { adminTokenStorage, apiRequest } from '@/core/lib/api';
import type {
  AdminLoginPayload,
  AdminLoginResult,
  AdminLoginResultDto,
  AdminUserInfo,
  AdminUserInfoDto,
} from '@/features/auth/types';

function mapAdminUserInfo(dto: AdminUserInfoDto): AdminUserInfo {
  return {
    id: dto.id,
    username: dto.username,
    fullName: dto.full_name,
    email: dto.email,
    avatarUrl: dto.avatar_url,
    isSuperuser: dto.is_superuser,
  };
}

export async function loginAdmin(payload: AdminLoginPayload): Promise<AdminLoginResult> {
  const response = await apiRequest<AdminLoginResultDto>('/admin/auth/login/', {
    method: 'POST',
    auth: false,
    body: payload,
  });

  adminTokenStorage.setTokens({ access: response.access, refresh: response.refresh });

  return {
    access: response.access,
    refresh: response.refresh,
    user: mapAdminUserInfo(response.user),
  };
}

export async function getCurrentAdmin(): Promise<AdminUserInfo> {
  const response = await apiRequest<AdminUserInfoDto>('/admin/auth/me/');
  return mapAdminUserInfo(response);
}

export async function logoutAdmin(): Promise<void> {
  const refresh = adminTokenStorage.getRefreshToken();

  try {
    await apiRequest<void>('/admin/auth/logout/', {
      method: 'POST',
      body: refresh ? { refresh } : {},
    });
  } finally {
    adminTokenStorage.clearTokens();
  }
}

export function hasAdminAccessToken(): boolean {
  return Boolean(adminTokenStorage.getAccessToken());
}
