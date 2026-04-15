# Quy Tắc Mapping Dữ Liệu (DTO/Model/Service)

Tài liệu này là bộ quy tắc thực thi để cả team code đồng bộ, dễ đọc và review nhanh.

## 1. Nguyên tắc tổng quát
1. Contract API dùng snake_case.
2. UI/Provider chỉ làm việc với Model.
3. Data layer có thể dùng DTO khi cần tách contract API khỏi Model.
4. Không truyền DTO lên UI.

## 2. Trách nhiệm theo layer
1. DTO
- Dùng để parse request/response API.
- Định nghĩa key bám sát contract backend.
- Đặt tại `lib/features/<feature>/dtos/`.

2. Model
- Dùng cho app/business/UI.
- Có thể có computed getter phục vụ UI.
- Đặt tại `lib/features/<feature>/models/`.

3. Service
- Gọi API.
- Parse response sang DTO (nếu có).
- Map DTO -> Model.
- Public API của service nên trả về Model.

## 3. Quy tắc khi parse JSON
1. Ưu tiên parser sinh tự động (`json_serializable` hoặc `dart_mappable`).
2. Hạn chế map tay trong `fromJson`.
3. Nếu bắt buộc fallback key, đặt rõ tại một điểm (DTO mapper hoặc helper), không rải rác.
4. Nếu contract đã chốt snake_case, bỏ fallback camelCase để code ngắn và dễ đọc.

## 4. Quy tắc helper
1. Helper mức object:
- `mapObjectData(responseData, mapper)`
- Mapper nhận `Map<String, dynamic>` và trả về một object.

2. Helper mức list:
- `mapListData(responseData, mapper)`
- Mapper nhận một item và trả về một object.

3. Không chèn logic nghiệp vụ vào helper.
4. Helper chỉ làm 2 việc:
- Rút object/list từ payload.
- Map item qua callback.

## 5. Quy tắc DTO -> Model
1. Có extension `toModel()` trên DTO hoặc mapper class riêng.
2. Enum mapping phải có fallback an toàn.
3. DateTime parse phải rõ timezone/nullable.
4. Bất kỳ transform nào không thuộc contract API (ví dụ field phục vụ UI) đặt ở Model layer.

## 6. Quy tắc triển khai service
1. Service method trả list
- Gọi API.
- `return mapListData(response.data, (raw) => DtoMapper.fromMap(raw).toModel());`

2. Service method trả object
- Gọi API.
- `return mapObjectData(response.data, (raw) => DtoMapper.fromMap(raw).toModel());`

3. Nhánh Mock và nhánh API phải trả cùng một kiểu Model.

## 7. Quy tắc đặt tên file
1. DTO: `<name>_dto.dart`
2. Model: `<name>_model.dart`
3. File sinh tự động:
- `*.mapper.dart` (dart_mappable)
- `*.g.dart` (json_serializable)

## 8. Quy tắc review/checklist
1. Đã đúng snake_case contract chưa?
2. Service có trả Model không?
3. UI có import DTO không? (nếu có là sai)
4. Analyzer có sạch không?
5. Có test mapping cho các field quan trọng không?

## 9. Quy tắc migrate feature mới (ít lỗi)
1. Tạo DTO.
2. Tạo mapping DTO -> Model.
3. Refactor Service, giữ signature trả Model.
4. Chạy codegen.
5. Chạy analyze.
6. Test smoke flow màn hình.

## 10. Anti-pattern cần tránh
1. DTO xuất hiện ở View/Provider.
2. Viết map tay lặp lại trong nhiều service.
3. Trộn camelCase và snake_case trong cùng model khi contract đã chốt.
4. Đưa business rule vào helper parse chung.
