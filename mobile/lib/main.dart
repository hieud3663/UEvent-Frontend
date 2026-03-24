// File: lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/events/views/home_view.dart';
import 'package:frontend/features/events/views/discovery_view.dart';
import 'package:frontend/features/notifications/views/notifications_view.dart';
import 'package:frontend/features/events/views/create_event_view.dart';
import 'package:frontend/features/profile/views/user_profile_view.dart';
import 'package:frontend/features/events/views/empty_search_view.dart';
import 'package:frontend/features/events/models/event_model.dart';
import 'package:frontend/features/ticketing/models/ticket_model.dart';
import 'package:frontend/features/ticketing/views/my_tickets_view.dart';
import 'package:frontend/features/ticketing/views/ticket_detail_view.dart';
import 'package:frontend/features/ticketing/views/past_event_detail_view.dart';
import 'package:frontend/features/ticketing/views/cancel_confirmation_sheet.dart';
import 'package:frontend/features/ticketing/views/cancel_error_dialog.dart';
import 'features/events/views/event_detail_screen.dart';
import 'features/events/views/registration_confirmation_screen.dart';
import 'features/events/views/registration_success_screen.dart';
import 'features/events/views/ask_question_screen.dart';
import 'features/events/views/share_event_sheet.dart';

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
      builder: (ctx) => EventDetailScreen(
        onBack: () => Navigator.of(ctx).pop(),
        onShare: () => ShareEventSheet.show(ctx),
        onRegister: () => _pushRegistrationConfirmation(ctx),
        onAskQuestion: () => _pushAskQuestion(ctx),
      ),
    ));
  }

  void _pushRegistrationConfirmation(BuildContext ctx) {
    RegistrationConfirmationScreen.show(
      ctx,
      eventName: 'Global Developer Summit 2024',
      onConfirm: () {
        Navigator.of(ctx).pop(); // close sheet
        _pushRegistrationSuccess(ctx);
      },
    );
  }

  void _pushRegistrationSuccess(BuildContext ctx) {
    Navigator.of(ctx).push(MaterialPageRoute(
      builder: (_) => RegistrationSuccessScreen(
        eventName: 'Global Developer Summit 2024',
        ticketId: '#UE-98210',
        onViewTicket: () => Navigator.of(ctx).pop(),
        onAddToWallet: () {},
      ),
    ));
  }

  void _pushAskQuestion(BuildContext ctx) {
    Navigator.of(ctx).push(MaterialPageRoute(
      builder: (_) => AskQuestionScreen(
        onBack: () => Navigator.of(ctx).pop(),
        onSend: (q, anon, notify) {},
      ),
    ));
  }

  // ── Ticketing Navigation ──

  void _pushTicketDetail(TicketModel ticket) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (ctx) => TicketDetailView(
        ticket: ticket,
        onBack: () => Navigator.of(ctx).pop(),
        onCancelTap: () => _showCancelConfirmation(ctx, ticket),
      ),
    ));
  }

  void _showCancelConfirmation(BuildContext ctx, TicketModel ticket) {
    CancelConfirmationSheet.show(
      ctx,
      eventName: ticket.eventName,
      onConfirm: () {
        Navigator.of(ctx).pop(); // close sheet
        CancelErrorDialog.show(ctx); // always show error (demo: within 24h)
      },
    );
  }

  void _pushPastEventDetail(TicketModel ticket) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (ctx) => PastEventDetailView(
        ticket: ticket,
        onBack: () => Navigator.of(ctx).pop(),
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
        // Tab 2: TICKETS
        MyTicketsView(
          currentNavIndex: _currentIndex,
          onNavTap: _onNavTap,
          onTicketTap: _pushTicketDetail,
          onPastTicketTap: _pushPastEventDetail,
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
