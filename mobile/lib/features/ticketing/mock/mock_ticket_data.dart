import 'package:frontend/features/ticketing/models/ticket_model.dart';

class MockTicketData {
  static final TicketModel myValidTicket = TicketModel(
    id: 'ticket-001',
    eventId: 'event-001',
    eventName: 'UEvent Launch Party 2026',
    eventImageUrl: 'https://picsum.photos/420/220',
    date: '24 Oct, 2026',
    timeRange: '18:00 - 21:00',
    location: 'Hội trường C',
    ticketCode: 'TK-UEVENT-001',
    section: 'General',
    orderId: 'ORD-001',
    status: TicketStatus.upcoming,
  );

  static final UserRegistrationModel myRegistration = UserRegistrationModel(
    id: 'reg-001',
    eventId: 'event-001',
    status: 'registered',
    answersLocked: true,
    registeredAt: DateTime.now().subtract(const Duration(days: 2)),
  );

  static const List<RegistrationFormFieldModel> sampleFormFields = [
    RegistrationFormFieldModel(
      fieldKey: 'tshirt_size',
      label: 'Kích cỡ áo',
      fieldType: 'select',
      isRequired: true,
      options: ['S', 'M', 'L', 'XL'],
    ),
    RegistrationFormFieldModel(
      fieldKey: 'student_id_number',
      label: 'Mã số sinh viên',
      fieldType: 'text',
      isRequired: true,
    ),
  ];

  static final List<TicketModel> upcomingTickets = [
    myValidTicket,
  ];

  static final List<TicketModel> pastTickets = [
    myValidTicket.copyWith(
      id: 'ticket-002',
      eventName: 'Future Tech Summit 2024',
      date: '24 Oct, 2024',
      status: TicketStatus.past,
      ticketCode: 'TK-UEVENT-002',
      orderId: 'ORD-002',
    ),
  ];

  static const String attendanceSummary = 'Bạn đã tham gia 1 sự kiện trong tháng này.';
}
