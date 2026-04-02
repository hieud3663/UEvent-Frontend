'use client';

import { useState } from 'react';
import type { AdminOperationSwitches, PermissionSwitches } from '../types';

export function usePermissions() {
  const [dataAccess, setDataAccess] = useState<PermissionSwitches>({
    keys: true,
    schema: false,
    pii: false,
    export: true,
  });

  const [adminOps, setAdminOps] = useState<AdminOperationSwitches>({
    policy: false,
    topology: true,
  });

  return {
    dataAccess,
    setDataAccess,
    adminOps,
    setAdminOps,
  };
}
