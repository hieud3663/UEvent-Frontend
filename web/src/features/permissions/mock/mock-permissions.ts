import type { PermissionProfile } from '../types';

export const permissionProfile: PermissionProfile = {
  name: 'Sarah Jenkins',
  email: 's.jenkins@amberglass.sys',
  role: 'Security Analyst',
  office: 'HQ Office',
  assigned: '42 / 120',
  avatar:
    'https://lh3.googleusercontent.com/aida-public/AB6AXuAcyMNGbKoQsK6RoDd0gnJO1R61MH9DrlP6Gr4g-82KDWDKbIzPaZzkkyCbtVLmNinWzjhitEx0xa_FLJ_kRRefVPxGRZY3X7su-ZNc8R4VVDeZwPH19coV8gPZ72SZgs7S26o0l_PU49rkgXswovS5dxd7uW8PjPXaWQBfFZZiBhjTLRlKD27XoRc6i_E0zMmjZj0OwnfFg-Fd6sRmTI5JpKCGsdxpKP4KbrFuO4RIq38EmfE3QeNe86uzsSmO88TAstAufwdjwLY',
};

export const additionalScopes = [
  'Audit Reporting',
  'Webhooks v2',
  'API Key Rotation',
  'Tenant Isolation',
  'Session Management',
] as const;
