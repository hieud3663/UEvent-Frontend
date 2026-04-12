import 'package:frontend/features/ticketing/models/ticket_dto.dart';

class MockTicketData {
  static final TicketDTO myValidTicket = TicketDTO(
    ticketCode: 'TK-UEVENT-001',
    qrPayload: 'mock_signed_payload_string',
    validFrom: DateTime.now(),
    validTo: DateTime.now().add(const Duration(seconds: 15)), // 15s rotating
    status: 'valid',
  );

  static final UserRegistrationDTO myRegistration = UserRegistrationDTO(
    id: 'reg-001',
    eventId: 'event-001',
    status: 'registered',
    answersLocked: true,
    registeredAt: DateTime.now().subtract(const Duration(days: 2)),
  );

  static const List<RegistrationFormFieldDTO> sampleFormFields = [
    RegistrationFormFieldDTO(
      fieldKey: 'tshirt_size',
      label: 'Kích cỡ áo',
      fieldType: 'select',
      isRequired: true,
      optionsJson: ['S', 'M', 'L', 'XL'],
    ),
    RegistrationFormFieldDTO(
      fieldKey: 'student_id_number',
      label: 'Mã số sinh viên',
      fieldType: 'text',
      isRequired: true,
    ),
  ];
}
