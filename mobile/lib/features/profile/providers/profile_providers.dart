import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/providers/service_providers.dart';
import 'package:frontend/features/auth/models/user_model.dart';
import 'package:frontend/features/event_shared/models/event_model.dart';
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
