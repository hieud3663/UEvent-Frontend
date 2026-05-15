// File: lib/core/providers/service_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/features/auth/providers/auth_providers.dart';
import 'package:frontend/features/events/services/event_service.dart';
import 'package:frontend/features/profile/services/profile_service.dart';
import 'package:frontend/features/ticketing/services/ticketing_service.dart';

/// Global [ApiClient] with auth interceptors wired via lazy lambdas.
///
/// The lambdas resolve at call-time (not at provider-build-time), avoiding
/// circular construction. The dependency graph terminates at
/// `flutter_appauth` (external), which never calls back through [ApiClient].
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient(
      authLocal: ref.read(authLocalDataSourceProvider),
      refreshFn: () => ref.read(authRepositoryProvider).refreshTokens(),
      onForceSignOut: () async =>
          ref.read(authControllerProvider.notifier).forceSignOut(),
    ));

// Note: authServiceProvider, authRepositoryProvider, authControllerProvider
// are defined in lib/features/auth/providers/auth_providers.dart.
// The old `authServiceProvider` that lived here has been superseded.

final eventServiceProvider = Provider<EventService>(
  (ref) => EventService(ref.read(apiClientProvider)),
);

final profileServiceProvider = Provider<ProfileService>(
  (ref) => ProfileService(ref.read(apiClientProvider)),
);

final ticketingServiceProvider = Provider<TicketingService>(
  (ref) => TicketingService(ref.read(apiClientProvider)),
);
