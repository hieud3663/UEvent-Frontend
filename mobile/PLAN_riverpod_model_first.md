## Plan Updated: Riverpod + Model First (No DTO)

Muc tieu: Chuyen UI tu mock sang du lieu dong, dung Riverpod va API service that, su dung truc tiep Model thay vi DTO.

### Nguyen tac da chot
- Khong tao DTO layer rieng.
- Service tra ve Model truc tiep.
- UI chi lam viec voi Model.
- State management dung Riverpod theo AsyncValue.
- Data source la API service that (khong dung mock trong luong chinh).

### Phase 0: Chuan hoa Model va Service Contract
1. Chon bo Model chinh theo feature:
- Events: EventModel
- Ticketing: TicketModel
- Notifications: NotificationModel
- Profile: User/ProfileModel
2. Chuan hoa service method de tra ve Model:
- getDiscoveryEvents() -> Future<ApiResponse<List<EventModel>>>
- getMyEvents() -> Future<ApiResponse<List<EventModel>>>
- getEventDetail(id) -> Future<ApiResponse<EventModel>>
- getUpcomingTickets() -> Future<ApiResponse<List<TicketModel>>>
- getPastTickets() -> Future<ApiResponse<List<TicketModel>>>
3. Loai bo phu thuoc DTO trong cac view/providers/service implementation.

### Phase 1: Riverpod Core + DI
1. Bao app trong ProviderScope tai main.dart.
2. Tao global providers cho ApiClient va services (event, ticketing, notifications, profile, auth).
3. Tao feature providers:
- event_providers.dart
- ticketing_providers.dart
- notification_providers.dart
- profile_providers.dart
4. Dinh nghia FutureProvider/AsyncNotifierProvider theo use-case thuc te.

### Phase 2: Events (uu tien cao)
1. HomeView va DiscoveryView chuyen sang ConsumerWidget/ConsumerStatefulWidget.
2. Thay MockEventData bang ref.watch(...provider...).
3. Hien thi 3 state day du:
- loading: shimmer/skeleton
- error: EmptyStateView + Retry
- data: render EventCard/EventCardVertical
4. Chuan hoa callback navigation de dung EventModel xuyen suot.
5. Event detail organizer tam thoi giu mock noi bo neu ban muon giu scope nho (da chot tam giu).

### Phase 3: Ticketing
1. MyTicketsView dung provider thay mock.
2. Upcoming/Past tabs lay tu API service that.
3. Ticket detail flow dung TicketModel xuyen suot.
4. Loai bo cac getter mock cu (upcomingTickets/pastTickets/attendanceSummary) neu da thay bang API.

### Phase 4: Notifications + Profile
1. Notifications view bind list tu provider.
2. Hanh dong mark-as-read goi service that va invalidate provider.
3. Profile view bind du lieu user that tu provider.

### Phase 5: Cleanup va Validation
1. Remove DTO files/imports/part files neu khong con su dung.
2. Remove mock usage trong luong production.
3. flutter analyze: khong con error.
4. Chay smoke test:
- vao Home/Discovery co loading->data
- loi API hien error state co retry
- navigation event/ticket khong mismatch type

### Danh sach sua ngay (de mo duong)
1. Doi toan bo EventDTO -> EventModel trong:
- main.dart callbacks
- home_view.dart
- discovery_view.dart
- event_card.dart
- event_card_vertical.dart
2. Doi ticketing ve TicketModel xuyen suot trong my_tickets_view.dart va providers.
3. Bo import DTO trong cac view dang dung.
4. Cap nhat EventService/TicketingService de parse JSON vao Model.

### Ghi chu ky thuat
DTO va Model co vai tro gan nhau o muc chua du lieu, nhung khac nhau ve ranh gioi kien truc:
- DTO: thuong dung cho map API boundary.
- Model: object ung dung su dung truc tiep.
Theo quyet dinh hien tai, du an se dung model truc tiep de don gian hoa va dong nhat codebase.
