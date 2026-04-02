import type { AdminOperationSwitches, PermissionSwitches } from '../types';

interface SavePermissionsPayload {
  dataAccess: PermissionSwitches;
  adminOps: AdminOperationSwitches;
}

export async function savePermissions(_payload: SavePermissionsPayload): Promise<void> {
  void _payload;
  return Promise.resolve();
}
