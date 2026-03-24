// File: lib/mock/mock_event_data.dart

import '../models/event_model.dart';

/// Mock event data extracted from Views to comply with MOCK DATA SEPARATION rule.
/// Views MUST receive data through constructor or state management, NOT own their data.
class MockEventData {
  MockEventData._();

  // ── Home: My Events ──
  static final List<EventModel> myEvents = [
    EventModel(
      id: '1',
      title: 'Workshop Nhiếp Ảnh Căn Bản',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDuQsHATzTyDapvZjwkwkqCQweROKenFuGknzW9zUSqCQ0xGGI-3qyWIiUnQJxDofLYUmsCW77RKctoWOORYZ-C9VOyfO5onLl-SmmowvJANUGB1UyC5A6a0EZQq4ftjYn4uwWDxJC8K9QoXfIsGL927GPIeLulzLMSGWxyX2SEnL4PslhXvvwPVKIHgIt39Gl3rUlExwAcByDM3_wG9X6y5SjcOyOPvEgM06SayCpfP7qpiOJVnbxwMrfQl1gKtphIwFpFLtgmKfo',
      location: 'The Lab Studio, Quận 1',
      startDate: DateTime(2025, 5, 24),
    ),
    EventModel(
      id: '2',
      title: 'Lễ Hội Âm Nhạc Bãi Biển',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCvPC6lDKFEGyp8qY0ujcdU-w6F0GxOiIf9IWYTiyqNVfaB2IsxrVELFRzOzTTTx_IFCPh2lT7rqdNq26lIm7lx2dEdbUfRGcePsJm4RFW5HitgpSxYG3dS9vgW887rZ1YfXnLi0l1gVoF27EjJa8qS_su4uIcHVXB_P6kqtfbSM3BDOsMFSmrex-BlYAWmtAWHvazbxc_C2SoHgd8-nimw1-dhDMWGCLQryvxL3CNp11FC_4bc6FH4u0NRROb6PA29MkQtDIYnaM0',
      location: 'Vũng Tàu Beach Club',
      startDate: DateTime(2025, 5, 25),
    ),
  ];

  static const List<String> myEventDates = [
    'Thứ 7, 24 Th05',
    'Chủ nhật, 25 Th05',
  ];

  // ── Discovery: Events ──
  static final List<EventModel> discoveryEvents = [
    EventModel(
      id: '1',
      title: 'Summer Beats Festival',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCeQBq3SB4o6ijps-gBLfANONvG6DZo-EyEXFXHUHBeewAffv2GsGbC5WVz0GcR3n2_I1fpudHo-Q474dzbpPOa9HmbAYvciXGnGjyGy6wZpfIW6tn68T2pWi531NLl1k_lLniE9jXAcdVY46Yu1FBFNL0yP-JVGY3qdVF_fwo0nV8QO_04aoTz87iHApTIRBd6APoJsnNOq3D6Ub6mNFzD8uTS2PxAXr1BdF1_9oxWV84QIEnU-XGEkC2R6KmwzDeS2370Ddbr6J8',
      location: 'Main Campus Plaza, CA',
      startDate: DateTime(2024, 8, 24),
      timeRange: '08:00 PM - 02:00 AM',
      category: 'Music',
    ),
    EventModel(
      id: '2',
      title: 'Future of AI Summit',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAEe8TiBatwY617qcuKh7CbBA2RCdpsNDZV6tXtdoEBV2EtUzt_iJzl_n8BLOnEldIK96mhNyWv3ljOt1DCrOZwg35QDPlfTWQ1SJs9Nb6oJFT-HQ3Sp8WTwGnDhCUzKVCxmu4QYufHq3mj1dChw0SWQhDfZqemiu9bsS6J55OnNtM4Dus6-epR6U6Izbuaj5v1pBkljSqSJBOreAVKjqRNDuPEji5bUJ7zatWmBVhNBByt4XfpXJDqXZDYJBeaweBptbmtd9k5_dc',
      location: 'Grand Innovation Hall',
      startDate: DateTime(2024, 9, 12),
      timeRange: '10:00 AM - 04:00 PM',
      category: 'Tech',
    ),
    EventModel(
      id: '3',
      title: 'Championship Qualifiers',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDttCruWuFR4EfJM10dJpyryKeWwKmu847sRG5y07zX_HCWUP8pRW0vMm3OXLJ7M-xPmwGwo8mKm9vZkjDEOnrwoymhr6bTe61IWNw8CQgmHCfRM1DU8NRZHCKvWz20hc5FIQVh10mCUagjAiq4wWnAc6IQ6bdCsHqABwGSrF9Mujm1jCYALnnZkwi2ZcXl0QVLFieG_Pjd2Mw_W-ShWw2g5bxq1479eNVBMuRrhPe_hbonHlhnOJN3aNF-iNA3j0XAnAkQMtLVqP0',
      location: 'University Stadium',
      startDate: DateTime(2024, 9, 5),
      timeRange: '02:00 PM - 05:30 PM',
      category: 'Sports',
    ),
  ];

  static const List<String> discoveryDateBadges = ['AUG 24', 'SEP 12', 'SEP 05'];

  static const List<String> discoveryCategories = [
    'Music',
    'Academic',
    'Sports',
    'Upcoming',
    'Tech',
  ];

  // ── Event Detail Organizer ──
  static final EventModel eventDetailOrganizer = EventModel(
    id: 'evt_001',
    title: 'Future Tech Summit 2024: The AI Revolution',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuC7nwgVPoexpc7gSTL_8w5ornJCFV0UU5W66yRT2ei2S-Z9tA5RStKOFn7uMyKlxX2yo0MxSj190A7w7AEafDkZiBYczbi2cwfKVNOnYFXjRWYz86Bv4A2fywaxVa6vP4hefLNWvb9TsHNVleHeyCFgA5rWG4hGoY0J6q2MZvHkhXxe9VtFdkItOBEcOg5fXlvTkmHASYBAXZeG0W0dv0b0MaqjF4gWG91sb_tTkQt5Wfe8p2pZNjB5XYEEWKOgPs524CtvmCMqLdQ',
    location: 'Convention Center, San Francisco',
    startDate: DateTime(2024, 10, 24),
    timeRange: '09:00 AM - 06:00 PM',
    category: 'Technology & Innovation',
    description:
        'Join global leaders in artificial intelligence as we explore the future of generative models, autonomous systems, and the ethical landscape of the 2024 technological revolution. Featuring keynote speakers from OpenAI, Google, and NVIDIA.',
    guestCount: 1842,
    status: EventStatus.active,
  );
}
