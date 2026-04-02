export interface PermissionSwitches {
  keys: boolean;
  schema: boolean;
  pii: boolean;
  export: boolean;
}

export interface AdminOperationSwitches {
  policy: boolean;
  topology: boolean;
}

export interface PermissionProfile {
  name: string;
  email: string;
  role: string;
  office: string;
  assigned: string;
  avatar: string;
}
