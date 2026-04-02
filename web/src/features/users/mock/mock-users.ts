// File: src/features/users/mock/mock-users.ts

import type { User } from '../types';

export const mockUsers: User[] = [
  {
    id: '1',
    name: 'Sarah Jenkins',
    email: 's.jenkins@university.edu',
    studentId: 'ST-882910',
    role: 'student',
    status: 'active',
    avatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuD1fEzmSlxIkvMU6kzAxvmwZ2x8ga5KuPbaGP8jcUDF3EN130KmclliDwCWuU04VJAA32LpeG46FOPfOiixt3GTWvEQfS-53x-DkQ6lfcRIXKZrisbhBlp09qJU10zeSHHDugI0Jv6UFSLACNtkiP4iyIruBLx4qFMzkaQlwipJWj_WXl6DaZ-HlaCIFYE81bnoCcI4GfSaD18U9Rz0nNyW3LIdNdjw5CyshBGANTq9u40SI-j31YekLvCWTQ8CQhcciJG61xwiVGQ',
    createdAt: '2024-01-15',
  },
  {
    id: '2',
    name: 'Michael Chen',
    email: 'm.chen@events.org',
    studentId: 'OR-110294',
    role: 'organizer',
    status: 'active',
    avatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBA-cW-Nq4TYC5rvv-mIf6URbTjp5_0YL6bA0_04WdxOHMUxEUJu7quioeRQC3GwXCzBjOcsHsfOSKFM-qGfJFND7z-o8cFhhN41--GquylIdxCnVyWgM5mt6LF2uiid7QgnIhmyUFaBjDpZpNaETyY3zYSzENx9P_hizBxkSiwSPNq30B9Vqwwbv-_ZKqasloHHeAnm-3JRXycKbQB0axQUi42ppGc7IpRIh7Ve0fRL-0AUg2M-NFzYdbi9JD0otMnoHtFCEANjso',
    createdAt: '2024-01-10',
  },
  {
    id: '3',
    name: 'David Miller',
    email: 'd.miller@gmail.com',
    studentId: 'ST-003314',
    role: 'student',
    status: 'banned',
    avatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDI5WVh2myRf_3NY1hJ46pGKuNjW9y7Nlr0rHPvMEpAd1XWLCNCt4DrpCHNcT2mTOIVrT_zm4oO_AroRBRa0BK-yY9Hp6BMhBHti8K9ohtBz6kraXZjpIKFGkRhySCRlNGa6emjIbcntbW75-oltVNHrpogRX6xRdHYJF329YNtbCcDGhhXhAycIN_VP2tlwujZ9Ai0X-QJDqXIeUOkSNtd5kYF2yXxxszSveOAIS5099XUjqM_F4H_jwoUPNgsmTbvyAvNiOEI2sg',
    createdAt: '2023-12-20',
  },
  {
    id: '4',
    name: 'Elena Rodriguez',
    email: 'e.rodriguez@university.edu',
    studentId: 'ST-556721',
    role: 'student',
    status: 'active',
    avatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDcQZGYzMY8dZIznz2lRj77iPINxuVOQHwp1jnLRBbPWs6Ibkgd8Wq0S0TdM4oQITCdSVf6WxOPvAkELxBGXJ-7hzZYBd42q0Fhs1u5Xw6bmIhB_trrRgIftwVMp_Xy_bPjCpF5lDotZDp2CH6hULGpPOTEI4yOuwsJijnTdZ16ytSn69YQEUtzaUiXm4vWy38Pznjflq2Qj-EqstxHQLOVcXSkaINMvew8r3VvdUUidWd2plk13E56FHrerJfUjyDcutPC2z2100s',
    createdAt: '2024-02-01',
  },
  {
    id: '5',
    name: 'James Wilson',
    email: 'j.wilson@company.com',
    studentId: 'OR-889012',
    role: 'organizer',
    status: 'pending',
    avatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDV320YMqiYUJZn9nyC85F61ox_xlvreWDOTEqyzT_FR47l5PqjYlues7JX8exjtAHIJ2yVVUK5RnOQaAiFTyNWIInCwT-JZ7Qn91g-1ro-CrcgU7pGPZXkv7VNwfayOdKYwlJmxdiaBcSuAAJm9cZZiIVPAq3hupYI4jedmyGX2BCGzXOPfoJCky_ieXThT4FnivS5VNjQrzSBkpJ6UuDcFO38zPXjCLXogfbaN486bpvnr_LoT516mwma65yIzZpXSnv1D6bD8jk',
    createdAt: '2024-02-15',
  },
];

export const userStats = {
  totalUsers: 12842,
  activeOrganizers: 432,
  pendingRequests: 89,
  platformStatus: 'Optimal',
  uptime: '99.9%',
};
