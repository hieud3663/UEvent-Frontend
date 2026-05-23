import 'dart:async';

import 'package:flutter/material.dart';

OverlayEntry? _currentSnackBarEntry;
Timer? _currentSnackBarTimer;

void showAppSnackBar(
  BuildContext context,
  String message, {
  Color? backgroundColor,
  Color? foregroundColor,
}) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;

  final colorScheme = Theme.of(context).colorScheme;
  final resolvedBackgroundColor = backgroundColor ?? colorScheme.inverseSurface;
  final resolvedForegroundColor =
      foregroundColor ?? colorScheme.onInverseSurface;

  _dismissCurrentSnackBar();

  final entry = OverlayEntry(
    builder: (context) => Positioned(
      top: 12,
      left: 16,
      right: 16,
      child: SafeArea(
        bottom: false,
        child: Dismissible(
          key: UniqueKey(),
          direction: DismissDirection.horizontal,
          onDismissed: (_) => _dismissCurrentSnackBar(),
          child: Material(
            color: resolvedBackgroundColor,
            elevation: 6,
            shadowColor: Colors.black.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(14),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: resolvedForegroundColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  _currentSnackBarEntry = entry;
  overlay.insert(entry);
  _currentSnackBarTimer = Timer(
    const Duration(seconds: 4),
    _dismissCurrentSnackBar,
  );
}

void _dismissCurrentSnackBar() {
  _currentSnackBarTimer?.cancel();
  _currentSnackBarTimer = null;

  final entry = _currentSnackBarEntry;
  _currentSnackBarEntry = null;
  if (entry?.mounted ?? false) {
    entry?.remove();
  }
}
