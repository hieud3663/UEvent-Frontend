import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/providers/service_providers.dart';
import 'package:frontend/features/auth/models/user_model.dart';
import 'package:frontend/features/event_shared/models/event_model.dart';
import 'package:frontend/features/profile/models/help_center_models.dart';
import 'package:frontend/features/profile/services/help_center_service.dart';
import 'package:frontend/features/user_events/providers/user_event_providers.dart';

class ProfileOverviewModel {
  final UserModel user;
  final List<EventModel> events;

  const ProfileOverviewModel({required this.user, required this.events});
}

final userProfileProvider = FutureProvider<UserModel>((ref) async {
  final profileService = ref.read(profileServiceProvider);
  return profileService.getMyProfile();
});

final helpCenterServiceProvider = Provider<HelpCenterService>(
  (ref) => HelpCenterService(ref.read(apiClientProvider)),
);

final helpCenterProvider =
    FutureProvider.family<List<HelpCenterCategoryModel>, String>(
      (ref, locale) =>
          ref.read(helpCenterServiceProvider).getHelpCenter(locale: locale),
    );

final supportTicketsProvider = FutureProvider<List<SupportTicketModel>>(
  (ref) => ref.read(helpCenterServiceProvider).getSupportTickets(),
);

final privacyPolicyProvider = FutureProvider.family<LegalDocumentModel, String>(
  (ref, locale) => ref
      .read(helpCenterServiceProvider)
      .getLegalDocument(documentType: 'privacy_policy', locale: locale),
);

final profileOverviewProvider = FutureProvider<ProfileOverviewModel>((
  ref,
) async {
  final profileService = ref.read(profileServiceProvider);
  final eventRepository = ref.read(userEventRepositoryProvider);

  final results = await Future.wait<dynamic>([
    profileService.getMyProfile(),
    eventRepository.getEvents(queryParams: {'scope': 'mine'}),
  ]);

  return ProfileOverviewModel(
    user: results[0] as UserModel,
    events: results[1] as List<EventModel>,
  );
});
