# Backend Models DTOs cho Flutter (UEvent)

Tài liệu này không map 100% theo các SQL Tables của Backend mà liệt kê các ranh giới mô hình giao tiếp API (Data Transfer Objects - DTOs). Nhằm đảm bảo **luồng (flow) chuẩn xác** và **nguyên tắc bảo mật** (ẩn các hash, khóa).

> **Nguyên tắc bảo mật:**
> - Các trường `password_hash`, `refresh_token_hash`, dữ liệu Admin Logs hoàn toàn bị giấu khỏi Response.
> - Các Models ở đây là JSON Schema bạn sẽ nhận/gửi khi giao tiếp với API.
> - **Quy chuẩn Key:** Luôn dùng `snake_case`.

---

## 1. Feature: Identity & Access (Auth Flow)
Khi gọi API `/auth/profile` hoặc lấy User info.

### Model: `UserDTO`
| JSON Field | Dart Type | Ghi chú |
|---|---|---|
| `id` | `String` | UUID |
| `email` | `String` | |
| `phone_number` | `String?` | Số điện thoại liên hệ (Có hỗ trợ) |
| `full_name` | `String` | |
| `student_code` | `String?` | Nullable. |
| `faculty`, `class_name` | `String?` | |
| `avatar_url` | `String?` | |
| `account_status`| `String` | `active`, `pending`, `banned` |
| `primary_role` | `String` | Trả về String Code của role (vd: `student`, `organizer`) thay vì nguyên 1 Object để làm nhẹ app. |

### Model: `AuthResponseDTO` (Khi Login thành công)
| JSON Field | Dart Type | Ghi chú |
|---|---|---|
| `access_token` | `String` | Dùng để kẹp vào Header Bearer |
| `expires_in` | `int` | Số giây sống của token |
| `user` | `UserDTO` | Thông tin người dùng |
*(Lưu ý: Luồng Refresh Token sẽ tự động xử lý qua HttpOnly Cookies hoặc một API đổi Token với logic bảo mật, không trả trực tiếp Hash về mobile)*

---

## 2. Feature: Event Core Lifecycle
Khi load danh sách hoặc chi tiết Sự kiện.

### Model: `EventDTO`
Cung cấp đủ biến thời gian để Frontend làm **Countdown Logic** và **Disable Buttons**.
| JSON Field | Dart Type | Ghi chú |
|---|---|---|
| `id` | `String` | |
| `title`, `slug` | `String` | |
| `description` | `String` | |
| `cover_image_url`| `String?` | |
| `category` | `CategoryDTO` | Tên danh mục + Icon. |
| `location` | `LocationDTO`| Trả về string hoặc Cấu trúc Phòng/Tòa nhà |
| `status` | `String` | `draft`, `pending`, `approved`, `active`, `finished`, `cancelled` |
| `max_capacity` | `int?` | |
| `start_at`, `end_at` | `DateTime` | Thời gian diễn ra sự kiện. |
| `registration_open_at`| `DateTime?`| Để Frontend làm hiển thị nút "Mở đăng ký sau X ngày". |
| `registration_close_at`| `DateTime?`| Timeout đóng đăng ký. |
| `cancellation_deadline_at`|`DateTime?`| Hạn chót để cho phép User bấm "Hủy vé". |
| `deep_link` | `String?` | Dùng để share |

### Model: `EventInvitationDTO` (Khi có thư mời private)
| JSON Field | Dart Type | Ghi chú |
|---|---|---|
| `id` | `String` | |
| `event_id` | `String` | Sự kiện được mời |
| `inviter_name` | `String` | Tên BTC gửi lời mời |
| `status` | `String` | `pending`, `accepted`, `declined` |
| `sent_at` | `DateTime` | |

---

## 3. Feature: Ticketing & Flow đăng ký (Registration)
Flow này yêu cầu user điền form từ Server trả về, sau đó nhận Vé.

### Model: `RegistrationFormFieldDTO`
Backend thiết kế Event trả về danh sách các Fields này để Flutter "vẽ" UI Input.
| JSON Field | Dart Type | Ghi chú |
|---|---|---|
| `field_key` | `String` | Key để Flutter put data vào (Ví dụ: `tshirt_size`) |
| `label` | `String` | Tên hiển thị input |
| `field_type` | `String` | `text`, `select`, `number`, `checkbox` |
| `is_required` | `bool` | Kiểm tra Form validation |
| `options_json` | `List<String>?`| Khai báo các lựa chọn cho Select/Checkbox |

### Model: `UserRegistrationDTO` (Trạng thái vé của My Ticket)
| JSON Field | Dart Type | Ghi chú |
|---|---|---|
| `id` | `String` | |
| `event_id` | `String` | |
| `status` | `String` | `registered` (Thành công), `waitlisted` (Hàng đợi chờ rớt vé), `checked_in`. |
| `answers_locked`| `bool` | Xác định user có được Edit form answers nữa không. |
| `registered_at` | `DateTime` | |

### Model: `TicketDTO` & Anti-Fraud check-in
Dùng cho màn hình Ví điện tử để quét mã.
| JSON Field | Dart Type | Ghi chú |
|---|---|---|
| `ticket_code` | `String` | Hiển thị ra UI: "TK-2024..." |
| `qr_payload` | `String` | Chuỗi String (đã được backend mã hóa signature) dùng để Flutter gen ra hình ảnh QR. |
| `valid_from` | `DateTime` | Token sẽ rotate liên tục, hiệu lực bắt đầu |
| `valid_to` | `DateTime` | Token hết hạn sau X giây. Khi hết, Flutter call lại API lấy mã mới. |
| `status` | `String` | `valid`, `used`, `expired` |

### Model: `CancellationRequestDTO`
| JSON Field | Dart Type | Ghi chú |
|---|---|---|
| `registration_id`| `String` | |
| `status` | `String` | `pending` (Đang chờ BTC duyệt hủy), `approved` |
| `reason` | `String?` | |

---

## 4. Feature: Notifications & Q&A
Các mô hình tương tác thời gian thực / chuông thông báo.

### Model: `NotificationDTO`
| JSON Field | Dart Type | Ghi chú |
|---|---|---|
| `id` | `String` | |
| `event_id` | `String?` | Nếu thông báo này gắn với sự kiện |
| `title`, `message`| `String` | Giao diện đã format thành nội dung hoàn chỉnh |
| `type` | `String` | `announcement`, `reminder`, `alert`... |
| `read_at` | `DateTime?`| Check xem đã đọc chưa (trạng thái Bubble Unread) |
| `delivered_at` | `DateTime?`| |

### Model: `EventQuestionDTO` (Hệ thống hỏi đáp trong Event)
| JSON Field | Dart Type | Ghi chú |
|---|---|---|
| `id` | `String` | |
| `user_name` | `String` | Hiển thị "Ẩn danh" nếu `is_anonymous = true` ở Backend |
| `question_text` | `String` | |
| `answer_text` | `String?` | BTC trả lời |
| `asked_at` | `DateTime` | Thời điểm đặt câu hỏi |

### Model: `EventFeedbackDTO`
| JSON Field | Dart Type | Ghi chú |
|---|---|---|
| `rating` | `int` | 1-5 |
| `content` | `String` | (alias từ comment) |
| `created_at` | `DateTime`| |

---

## 5. Support System
Giao diện Report lỗi ứng dụng.

### Model: `SupportTicketDTO`
| JSON Field | Dart Type | Ghi chú |
|---|---|---|
| `id` | `String` | |
| `subject` | `String` | |
| `category` | `String` | `account`, `event`, `payment`, `technical` |
| `status` | `String` | `open`, `in_progress`, `resolved` |
| `last_updated_at`| `DateTime`| |