import 'package:frontend/features/events/models/event_dto.dart';

class MockEventData {
  static const CategoryDTO mockMusicCategory = CategoryDTO(
    id: 'cat-001',
    name: 'Âm nhạc',
    slug: 'am-nhac',
    icon: 'music_note',
    color: '#FF5733',
  );

  static const CategoryDTO mockTechCategory = CategoryDTO(
    id: 'cat-002',
    name: 'Technology',
    slug: 'tech',
    icon: 'computer',
    color: '#3388FF',
  );

  static const LocationDTO mockLocation = LocationDTO(
    id: 'loc-001',
    type: 'room',
    name: 'Hội trường C',
    address: 'Khu trung tâm, Cơ sở Quận 9',
    capacity: 500,
  );

  static final EventDTO mockEventLaunchParty = EventDTO(
    id: 'event-001',
    title: 'UEvent Launch Party 2026',
    slug: 'uevent-launch-party',
    description: 'Bữa tiệc ra mắt nền tảng UEvent hoành tráng.',
    status: 'active',
    category: mockMusicCategory,
    startAt: DateTime.now().add(const Duration(days: 7)),
    endAt: DateTime.now().add(const Duration(days: 7, hours: 3)),
    location: mockLocation,
    maxCapacity: 500,
    coverImageUrl: 'https://picsum.photos/800/400',
    registrationOpenAt: DateTime.now().subtract(const Duration(days: 1)),
    registrationCloseAt: DateTime.now().add(const Duration(days: 6)),
    cancellationDeadlineAt: DateTime.now().add(const Duration(days: 5)),
  );

  static final EventDTO mockEventTechSummit = EventDTO(
    id: 'event-002',
    title: 'Future Tech Summit 2024: The AI Revolution',
    slug: 'future-tech-summit-2024',
    description: 'Join global leaders in artificial intelligence...',
    status: 'active',
    category: mockTechCategory,
    startAt: DateTime(2024, 10, 24, 9),
    endAt: DateTime(2024, 10, 24, 18),
    location: const LocationDTO(
      id: 'loc-002', type: 'string', name: 'Convention Center, San Francisco'
    ),
    maxCapacity: 2000,
    coverImageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuC7nwgVPoexpc...LdQ',
    registrationOpenAt: DateTime(2024, 9, 24),
    registrationCloseAt: DateTime(2024, 10, 20),
  );

  static final List<EventDTO> list = [
    mockEventLaunchParty,
    mockEventTechSummit,
  ];
}
