// File: lib/features/ticketing/mock/mock_ticket_data.dart

import 'package:frontend/features/ticketing/models/ticket_model.dart';

/// Static mock data for the Ticketing feature.
class MockTicketData {
  MockTicketData._();

  static const String attendanceSummary =
      'You have successfully attended 3 events this semester.';

  static const List<TicketModel> upcomingTickets = [
    TicketModel(
      id: 'T-001',
      eventId: 'E-001',
      eventName: 'Global Developer Summit 2024',
      eventImageUrl:
          'https://lh3.googleusercontent.com/aida/ADBb0ui-ocnqh3tC0zIUHDDMCKd0vbs2pgWyZUQ3Uo6ScbDtXlGa5Leye2U4k1xGh071-jwP2ElOAufpFnT5hVrtIzTauCtnXnbM97HRCIUwKk5VrHr7PvPwEmibKV6BbHLNbI2C4A3uPh6U5DSWzxYqPI6DKv9kc4r117wGIHf-4q6zGF_wGOw-JoYlYgHES0R8cQ9zq2dwKmjyWdgHdaujbnCULdHdYmNcIBa_YUwW7WIhLUaPABcxXfZqYQ0',
      date: 'Oct 24, 2024',
      timeRange: '09:00 - 18:00',
      location: 'Tech Convention Center, Hall A',
      ticketCode: '#UE-88201',
      section: 'General',
      row: '5',
      seat: '12',
      orderId: 'ORD-8812039182',
      status: TicketStatus.upcoming,
    ),
    TicketModel(
      id: 'T-002',
      eventId: 'E-002',
      eventName: 'Echoes of Summer Festival',
      eventImageUrl:
          'https://lh3.googleusercontent.com/aida/ADBb0ujbX-709nUThzTMPOwqh4tUTHZ7AJUGy_5jymoXfce9WzZxzEjTXPfvZcOyP7P6Mnc_Wr20p0q6YaPEcKw1XfiURzWXzyAcoqytZLQ5IvZDHTBbkms20mR-XMW6vVtJ8Dq_CaNSKFQoMtnHmN2a5krq7Wt5XRaCSH_2K7DXEvSCNAEQOn9C9ALTEZfiX5euIlaiTGC4j5LLMjbwLmIiRmj7wnHST47qnZTiLJZlzoXdT-C7ATw_vtzFrTY',
      date: 'Nov 8, 2024',
      timeRange: '16:00 - 23:00',
      location: 'Riverside Park, Main Stage',
      ticketCode: '#AMB-992-04X',
      section: 'VIP-A',
      row: '12',
      seat: '44',
      orderId: 'ORD-1029384756',
      status: TicketStatus.upcoming,
    ),
    TicketModel(
      id: 'T-003',
      eventId: 'E-003',
      eventName: 'Culinary Masters Workshop',
      eventImageUrl:
          'https://lh3.googleusercontent.com/aida/ADBb0uixoiEtKF2wif_O3dY6xEwMPS3E8QZQECZoTvwDUfOs7V8fBIo3rBQkGjXImVgGOtix5EI96C_WBr8LFFZFWG7k6cXAXXDoGs7glS7sOSdCQkmgTL6UIfiOCQBHPI2I4fh4wtu-QxydsZQnB5xf57XDW1TaMlKa68G4Tl3j6yG9wluvQkSqEGGtS2m6qHuRZbXx4VnS99Rxvi3ysV7wWjwT-odIhVqpNBgwSieN60k2N-e1AN59HaefkOk',
      date: 'Nov 15, 2024',
      timeRange: '10:00 - 14:00',
      location: 'Culinary Arts Center, Kitchen B',
      ticketCode: '#CUL-441-99Z',
      section: 'Standard',
      orderId: 'ORD-3345672890',
      status: TicketStatus.upcoming,
    ),
  ];

  static const List<TicketModel> pastTickets = [
    TicketModel(
      id: 'T-P01',
      eventId: 'E-P01',
      eventName: 'Annual Spring Music Gala 2024',
      eventImageUrl:
          'https://lh3.googleusercontent.com/aida/ADBb0uhABrAPs2ESVrYcjG0wfnPduaSF_514tb8VwXVVaTo9mh18VRbvfEZZya324696NHw1gSVTVxwkxHxAwUKyr6skf7Wnc9Q3cQ502gFBqR7e_WnPfpIlEXNVer1lgEQHQbjjZhvXctRNUu3azY705zqb_jQpov0ImdGvsVEVt5_Rd05JZ17nrTG4ufGRyYNNos9n0ucpW_3K5rMBCdXIaw8Hb8fwey419L423RbbtJZzshZAcP1s6vN4k4U',
      date: 'May 12, 2024',
      timeRange: '7:00 PM',
      location: 'Central Campus Arena, Room 402',
      ticketCode: '#SPG-2024-A1',
      section: 'VIP Floor - A1',
      orderId: 'ORD-12345678',
      guestType: 'Premium Passholder',
      status: TicketStatus.past,
    ),
    TicketModel(
      id: 'T-P02',
      eventId: 'E-P02',
      eventName: 'Global Innovation Summit',
      eventImageUrl:
          'https://lh3.googleusercontent.com/aida/ADBb0ui-ocnqh3tC0zIUHDDMCKd0vbs2pgWyZUQ3Uo6ScbDtXlGa5Leye2U4k1xGh071-jwP2ElOAufpFnT5hVrtIzTauCtnXnbM97HRCIUwKk5VrHr7PvPwEmibKV6BbHLNbI2C4A3uPh6U5DSWzxYqPI6DKv9kc4r117wGIHf-4q6zGF_wGOw-JoYlYgHES0R8cQ9zq2dwKmjyWdgHdaujbnCULdHdYmNcIBa_YUwW7WIhLUaPABcxXfZqYQ0',
      date: 'Mar 5, 2024',
      timeRange: '09:00 - 17:00',
      location: 'Innovation Hub, Main Hall',
      ticketCode: '#GIS-2024-B2',
      section: 'Standard',
      orderId: 'ORD-87654321',
      guestType: 'General Admission',
      status: TicketStatus.past,
    ),
    TicketModel(
      id: 'T-P03',
      eventId: 'E-P03',
      eventName: 'Student Startup Weekend',
      eventImageUrl:
          'https://lh3.googleusercontent.com/aida/ADBb0uixoiEtKF2wif_O3dY6xEwMPS3E8QZQECZoTvwDUfOs7V8fBIo3rBQkGjXImVgGOtix5EI96C_WBr8LFFZFWG7k6cXAXXDoGs7glS7sOSdCQkmgTL6UIfiOCQBHPI2I4fh4wtu-QxydsZQnB5xf57XDW1TaMlKa68G4Tl3j6yG9wluvQkSqEGGtS2m6qHuRZbXx4VnS99Rxvi3ysV7wWjwT-odIhVqpNBgwSieN60k2N-e1AN59HaefkOk',
      date: 'Feb 16, 2024',
      timeRange: '08:00 - 20:00',
      location: 'Startup Lab, Floor 3',
      ticketCode: '#SSW-2024-C3',
      section: 'Participant',
      orderId: 'ORD-11223344',
      guestType: 'Competitor',
      status: TicketStatus.past,
    ),
  ];
}
