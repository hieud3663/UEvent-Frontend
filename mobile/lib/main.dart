// File: lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'apps/app_theme.dart';
import 'views/home_view.dart';
import 'views/discovery_view.dart';
import 'views/notifications_view.dart';
import 'views/create_event_view.dart';
import 'views/user_profile_view.dart';
import 'views/empty_search_view.dart';
import 'views/event_detail_organizer_view.dart';
import 'models/event_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const UEventsApp());
}

class UEventsApp extends StatelessWidget {
  const UEventsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UEvents',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AppShell(),
    );
  }
}

/// App shell that manages bottom nav tab switching + push navigation.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
  }

  // ── Push Navigation ──

  void _pushNotifications() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => NotificationsView(
        currentNavIndex: _currentIndex,
        onNavTap: (i) {
          Navigator.of(context).pop();
          _onNavTap(i);
        },
        onBack: () => Navigator.of(context).pop(),
      ),
    ));
  }

  void _pushProfile() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => UserProfileView(
        onBack: () => Navigator.of(context).pop(),
      ),
    ));
  }

  void _pushCreateEvent() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => CreateEventView(
        onBack: () => Navigator.of(context).pop(),
      ),
    ));
  }

  void _pushEmptySearch() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => EmptySearchView(
        currentNavIndex: _currentIndex,
        onNavTap: (i) {
          Navigator.of(context).pop();
          _onNavTap(i);
        },
        onBack: () => Navigator.of(context).pop(),
        onGoHome: () {
          Navigator.of(context).pop();
          _onNavTap(0);
        },
      ),
    ));
  }

  void _pushEventDetail(EventModel event) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => EventDetailOrganizerView(
        onBack: () => Navigator.of(context).pop(),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: _currentIndex,
      children: [
        // Tab 0: HOME
        HomeView(
          currentNavIndex: _currentIndex,
          onNavTap: _onNavTap,
          onNotificationsTap: _pushNotifications,
          onProfileTap: _pushProfile,
          onCreateEventTap: _pushCreateEvent,
          onEventTap: _pushEventDetail,
        ),
        // Tab 1: DISCOVER
        DiscoveryView(
          currentNavIndex: _currentIndex,
          onNavTap: _onNavTap,
          onNotificationsTap: _pushNotifications,
          onProfileTap: _pushProfile,
          onSearchEmpty: _pushEmptySearch,
          onEventTap: _pushEventDetail,
        ),
        // Tab 2: TICKETS (placeholder — reuse Home for now)
        HomeView(
          currentNavIndex: _currentIndex,
          onNavTap: _onNavTap,
          onNotificationsTap: _pushNotifications,
          onProfileTap: _pushProfile,
          onCreateEventTap: _pushCreateEvent,
        ),
        // Tab 3: SETTINGS (placeholder — reuse Home for now)
        HomeView(
          currentNavIndex: _currentIndex,
          onNavTap: _onNavTap,
          onNotificationsTap: _pushNotifications,
          onProfileTap: _pushProfile,
          onCreateEventTap: _pushCreateEvent,
        ),
      ],
    );
  }
}
