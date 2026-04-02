import {
  mockNotifications,
  notificationPaginationConfig,
  notificationStats,
} from '../mock/mock-notifications';
import type {
  AudienceType,
  Notification,
  NotificationPaginationConfig,
  NotificationStatus,
  NotificationType,
} from '../types';

export interface NotificationFilters {
  status?: NotificationStatus;
  type?: NotificationType;
  audience?: AudienceType;
}

export async function getNotifications(filters: NotificationFilters = {}): Promise<Notification[]> {
  const notifications = mockNotifications.filter((notification) => {
    const statusMatch = !filters.status || notification.status === filters.status;
    const typeMatch = !filters.type || notification.type === filters.type;
    const audienceMatch = !filters.audience || notification.audience === filters.audience;

    return statusMatch && typeMatch && audienceMatch;
  });

  return Promise.resolve(notifications);
}

export async function getNotificationStats() {
  return Promise.resolve(notificationStats);
}

export async function getNotificationPaginationConfig(): Promise<NotificationPaginationConfig> {
  return Promise.resolve(notificationPaginationConfig);
}

export interface NotificationDeliveryMethods {
  push: boolean;
  email: boolean;
  inbox: boolean;
}

export interface NotificationMutationPayload {
  title: string;
  message: string;
  audience: string;
  scheduleType: 'now' | 'later';
  scheduleDate?: string;
  scheduleTime?: string;
  deliveryMethods: NotificationDeliveryMethods;
}

export async function saveNotificationDraft(_payload: NotificationMutationPayload): Promise<void> {
  void _payload;
  return Promise.resolve();
}

export async function publishNotification(_payload: NotificationMutationPayload): Promise<void> {
  void _payload;
  return Promise.resolve();
}

export async function exportNotificationsHistory(): Promise<void> {
  return Promise.resolve();
}
