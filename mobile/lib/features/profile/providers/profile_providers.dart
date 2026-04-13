import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/providers/service_providers.dart';
import 'package:frontend/features/auth/models/user_model.dart';
import 'package:frontend/features/events/models/event_model.dart';

class ProfileOverviewModel {
  final UserModel user;
  final List<EventModel> events;

  const ProfileOverviewModel({required this.user, required this.events});
}

final profileOverviewProvider = FutureProvider<ProfileOverviewModel>((ref) async {
  final profileService = ref.read(profileServiceProvider);
  final eventService = ref.read(eventServiceProvider);

  final results = await Future.wait<dynamic>([
    profileService.getMyProfile(),
    eventService.getEvents(queryParams: {'scope': 'mine'}),
  ]);

  return ProfileOverviewModel(
    user: results[0] as UserModel,
    events: results[1] as List<EventModel>,
  );
});
