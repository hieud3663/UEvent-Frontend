# Báo Cáo Migration Notification

## 1. Mục tiêu
- Chuẩn hóa luồng dữ liệu Notifications theo hướng model-first + DTO mapping để dễ mở rộng.
- Giảm lặp code parse/list mapping trong service.
- Chuẩn hóa Async state UI theo Riverpod (`loading/error/success`) và dùng widget dùng chung.

## 2. Các thay đổi đã thực hiện

### 2.1 Notification model
- File: `lib/features/notifications/models/notification_model.dart`
- Chuẩn hóa field theo snake_case contract:
  - `event_id -> eventId`
  - `read_at -> readAt`
  - `delivered_at -> deliveredAt`
- Bổ sung getter phục vụ UI:
  - `description`
  - `timestamp`
  - `isRead`
  - `relatedEventId`
- Dùng `json_serializable` để parse/toJson.

### 2.2 Notification DTO với dart_mappable
- File: `lib/features/notifications/dtos/notification_dto.dart`
- Tạo `NotificationDto` để parse payload API qua `dart_mappable`.
- Tạo extension `toModel()` để map `NotificationDto -> NotificationModel`.
- Hỗ trợ type mapping:
  - `event_invite`, `eventInvite`
  - `ticket_confirm`, `ticketConfirm`
  - fallback về `announcement`.

### 2.3 Generated mapper
- File: `lib/features/notifications/dtos/notification_dto.mapper.dart`
- Sinh bởi `dart_mappable_builder`.

### 2.4 Notification service
- File: `lib/features/notifications/services/notification_service.dart`
- Mock branch: giữ nguyên.
- API branch:
  - Gọi `/notifications`.
  - Parse list qua DTO mapper.
  - Map sang model.
- Đã rút gọn mapping bằng helper generic:
  - `mapListData(...)` + mapper function.

### 2.5 Provider và view
- Provider:
  - File: `lib/features/notifications/providers/notification_providers.dart`
  - `notificationsProvider` gọi `NotificationService.getNotifications()`.
- View:
  - File: `lib/features/notifications/views/notifications_view.dart`
  - Dùng `ref.watch(notificationsProvider)`.
  - Hiển thị 3 state qua widget dùng chung:
    - `AppLoadingSliver`
    - `AppErrorSliver`
    - `AppSuccessSliver`

### 2.6 Mock data cập nhật theo model mới
- File: `lib/features/notifications/mock/mock_notification_data.dart`
- Chuyển trường constructor cũ sang field mới:
  - Bỏ `timestamp`, `isRead`, `relatedEventId`.
  - Dùng `deliveredAt`, `readAt`, `eventId`.

### 2.7 Response parsing helper
- File: `lib/core/network/response_parsing.dart`
- Bổ sung helper:
  - `extractObjectData`
  - `extractListData`
  - `mapObjectData`
  - `mapListData`
  - `mapDtoToModel`
  - `mapObjectResponseToModel`
  - `mapListResponse`

## 3. Kết quả
- Notification flow compile ổn định.
- Analyzer cho các file Notifications không còn lỗi compile.
- Code service gọn hơn, dễ mở rộng sang Events/Ticketing/Auth.

## 4. Vấn đề cần theo dõi
- `markAsRead` đang gọi API nhưng chưa wiring invalidate provider trên UI interaction.
- Cần bổ sung test mapping DTO -> Model cho type và datetime edge cases.

## 5. Đề xuất bước tiếp theo
1. Wiring `markAsRead` vào action tile + refresh provider.
2. Viết unit test cho:
   - `NotificationDtoMapper.fromMap`
   - `NotificationDto.toModel()`
3. Nhân rộng pattern DTO mapping tương tự sang Events.
