import 'package:intl/intl.dart';
import 'package:frontend/features/event_shared/models/event_model.dart';

class MockEventData {
  static final EventModel mockEventLaunchParty = EventModel(
    id: 'event-001',
    title: 'UEvent Launch Party 2026',
    description: 'Bữa tiệc ra mắt nền tảng UEvent hoành tráng.',
    category: 'Âm nhạc',
    startDate: DateTime.now().add(const Duration(days: 7)),
    endDate: DateTime.now().add(const Duration(days: 7, hours: 3)),
    location: 'Hội trường C - Cơ sở Quận 9',
    guestCount: 500,
    imageUrl: 'https://picsum.photos/800/400',
    isOrganizer: true,
    timeRange: '18:00 - 21:00',
  );

  static final EventModel mockEventTechSummit = EventModel(
    id: 'event-002',
    title: 'Future Tech Summit 2024: The AI Revolution',
    description: 'Join global leaders in artificial intelligence...',
    category: 'Technology',
    startDate: DateTime(2024, 10, 24, 9),
    endDate: DateTime(2024, 10, 24, 18),
    location: 'Convention Center, San Francisco',
    guestCount: 2000,
    imageUrl: 'https://picsum.photos/900/420',
    isOrganizer: false,
    timeRange: '09:00 - 18:00',
  );

  static final EventModel eventDetailOrganizer = mockEventLaunchParty;

  static const List<String> discoveryCategories = [
    'All',
    'Technology',
    'Music',
    'Workshop',
  ];

  static final List<EventModel> discoveryEvents = [
    mockEventTechSummit,
    mockEventLaunchParty,
  ];

  static final List<String> discoveryDateBadges = discoveryEvents
      .map((e) => DateFormat('MMM d').format(e.startDate))
      .toList();

  static final List<EventModel> myEvents = [
    mockEventLaunchParty,
    mockEventTechSummit.copyWith(isOrganizer: true),
  ];

  static final List<String> myEventDates = myEvents
      .map((e) => DateFormat('EEE, d MMM').format(e.startDate))
      .toList();

  static final List<EventModel> list = [
    mockEventLaunchParty,
    mockEventTechSummit,
  ];
}
