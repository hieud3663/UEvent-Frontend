import { mockUsers, userStats } from '../mock/mock-users';
import type { User, UserRole, UserStatus } from '../types';

export interface UserFilters {
  role?: UserRole;
  status?: UserStatus;
  keyword?: string;
}

export interface UsersResponse {
  users: User[];
  total: number;
}

export async function getUsers(filters: UserFilters = {}): Promise<UsersResponse> {
  const normalizedKeyword = filters.keyword?.trim().toLowerCase();

  const users = mockUsers.filter((user) => {
    const roleMatch = !filters.role || user.role === filters.role;
    const statusMatch = !filters.status || user.status === filters.status;
    const keywordMatch =
      !normalizedKeyword ||
      user.name.toLowerCase().includes(normalizedKeyword) ||
      user.email.toLowerCase().includes(normalizedKeyword) ||
      user.studentId.toLowerCase().includes(normalizedKeyword);

    return roleMatch && statusMatch && keywordMatch;
  });

  return Promise.resolve({ users, total: users.length });
}

export async function getUserStats() {
  return Promise.resolve(userStats);
}

export async function getUserById(userId: string): Promise<User | null> {
  const user = mockUsers.find((item) => item.id === userId) ?? null;
  return Promise.resolve(user);
}

export async function exportUsersCsv(): Promise<void> {
  return Promise.resolve();
}

export async function unbanUserById(userId: string): Promise<User> {
  const targetUser = mockUsers.find((item) => item.id === userId);

  if (!targetUser) {
    throw new Error('User not found');
  }

  return Promise.resolve({ ...targetUser, status: 'active' });
}
