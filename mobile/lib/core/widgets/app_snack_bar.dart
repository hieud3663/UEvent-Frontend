import 'dart:async';

import 'package:flutter/material.dart';

OverlayEntry? _currentSnackBarEntry;

final NavigatorObserver appSnackBarRouteObserver = _AppSnackBarRouteObserver();

void showAppSnackBar(
  BuildContext context,
  String message, {
  Color? backgroundColor,
  Color? foregroundColor,
  Duration duration = const Duration(seconds: 3),
}) {
  final route = ModalRoute.of(context);
  if (route != null && !route.isCurrent) {
    _dismissCurrentSnackBar();
    return;
  }

  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;

  final colorScheme = Theme.of(context).colorScheme;
  final resolvedBackgroundColor = backgroundColor ?? colorScheme.inverseSurface;
  final resolvedForegroundColor =
      foregroundColor ?? colorScheme.onInverseSurface;

  _dismissCurrentSnackBar();

  final entry = OverlayEntry(
    builder: (context) => _AppSnackBarOverlay(
      message: message,
      backgroundColor: resolvedBackgroundColor,
      foregroundColor: resolvedForegroundColor,
      duration: duration,
      onDismiss: _dismissCurrentSnackBar,
    ),
  );

  _currentSnackBarEntry = entry;
  overlay.insert(entry);
}

void dismissAppSnackBar() {
  _dismissCurrentSnackBar();
}

void _dismissCurrentSnackBar() {
  final entry = _currentSnackBarEntry;
  _currentSnackBarEntry = null;
  if (entry?.mounted ?? false) {
    entry?.remove();
  }
}

class _AppSnackBarOverlay extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final Color foregroundColor;
  final Duration duration;
  final VoidCallback onDismiss;

  const _AppSnackBarOverlay({
    required this.message,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_AppSnackBarOverlay> createState() => _AppSnackBarOverlayState();
}

class _AppSnackBarOverlayState extends State<_AppSnackBarOverlay> {
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _scheduleDismiss();
  }

  @override
  void didUpdateWidget(covariant _AppSnackBarOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration ||
        oldWidget.message != widget.message) {
      _scheduleDismiss();
    }
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }

  void _scheduleDismiss() {
    _dismissTimer?.cancel();
    _dismissTimer = null;

    if (widget.duration <= Duration.zero) return;

    _dismissTimer = Timer(widget.duration, () {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 12,
      left: 16,
      right: 16,
      child: SafeArea(
        bottom: false,
        child: Dismissible(
          key: ValueKey(widget.message),
          direction: DismissDirection.horizontal,
          onDismissed: (_) => widget.onDismiss(),
          child: Material(
            color: widget.backgroundColor,
            elevation: 6,
            shadowColor: Colors.black.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(14),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Text(
                widget.message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: widget.foregroundColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AppSnackBarRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _dismissCurrentSnackBar();
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _dismissCurrentSnackBar();
    super.didPop(route, previousRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _dismissCurrentSnackBar();
    super.didRemove(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _dismissCurrentSnackBar();
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}
