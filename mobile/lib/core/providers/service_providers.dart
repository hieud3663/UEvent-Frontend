import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/features/auth/services/auth_service.dart';
import 'package:frontend/features/events/services/event_service.dart';
import 'package:frontend/features/profile/services/profile_service.dart';
import 'package:frontend/features/ticketing/services/ticketing_service.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(ref.read(apiClientProvider)),
);

final eventServiceProvider = Provider<EventService>(
  (ref) => EventService(ref.read(apiClientProvider)),
);

final profileServiceProvider = Provider<ProfileService>(
  (ref) => ProfileService(ref.read(apiClientProvider)),
);

final ticketingServiceProvider = Provider<TicketingService>(
  (ref) => TicketingService(ref.read(apiClientProvider)),
);
