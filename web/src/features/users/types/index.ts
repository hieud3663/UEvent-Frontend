// File: src/features/users/types/index.ts

export interface User {
  id: string;
  name: string;
  email: string;
  studentId: string;
  role: 'student' | 'organizer' | 'admin';
  status: 'active' | 'pending' | 'banned';
  avatar?: string;
  createdAt: string;
}

export type UserRole = User['role'];
export type UserStatus = User['status'];
