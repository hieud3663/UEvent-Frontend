import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';

final Queue<_AppSnackBarMessage> _pendingSnackBars =
    Queue<_AppSnackBarMessage>();
_AppSnackBarHostState? _appSnackBarHostState;
int _nextSnackBarId = 0;
const _snackBarAnimationDuration = Duration(milliseconds: 260);

class AppSnackBarHost extends StatefulWidget {
  final Widget child;

  const AppSnackBarHost({required this.child, super.key});

  @override
  State<AppSnackBarHost> createState() => _AppSnackBarHostState();
}

void showAppSnackBar(
  BuildContext context,
  String message, {
  Color? backgroundColor,
  Color? foregroundColor,
  Duration duration = const Duration(seconds: 3),
}) {
  final colorScheme = Theme.of(context).colorScheme;
  final snackBar = _AppSnackBarMessage(
    id: _nextSnackBarId++,
    text: message,
    backgroundColor: backgroundColor ?? colorScheme.inverseSurface,
    foregroundColor: foregroundColor ?? colorScheme.onInverseSurface,
    duration: duration,
  );

  _pendingSnackBars.add(snackBar);
  _appSnackBarHostState?._showNextSnackBar();
}

void dismissAppSnackBar() {
  _pendingSnackBars.clear();
  _appSnackBarHostState?._dismissCurrentSnackBar();
}

class _AppSnackBarHostState extends State<AppSnackBarHost> {
  _AppSnackBarMessage? _currentSnackBar;
  Timer? _dismissTimer;
  bool _isSnackBarVisible = false;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    _appSnackBarHostState = this;
    WidgetsBinding.instance.addPostFrameCallback((_) => _showNextSnackBar());
  }

  @override
  void dispose() {
    if (_appSnackBarHostState == this) {
      _appSnackBarHostState = null;
    }
    _dismissTimer?.cancel();
    super.dispose();
  }

  void _showNextSnackBar() {
    if (!mounted ||
        _currentSnackBar != null ||
        _isDismissing ||
        _pendingSnackBars.isEmpty) {
      return;
    }

    final snackBar = _pendingSnackBars.removeFirst();
    setState(() {
      _currentSnackBar = snackBar;
      _isSnackBarVisible = false;
      _isDismissing = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _currentSnackBar == snackBar) {
        setState(() => _isSnackBarVisible = true);
      }
    });

    _scheduleDismiss(snackBar);
  }

  void _scheduleDismiss(_AppSnackBarMessage snackBar) {
    _dismissTimer?.cancel();
    _dismissTimer = null;

    if (snackBar.duration <= Duration.zero) return;

    _dismissTimer = Timer(snackBar.duration, () {
      if (mounted && _currentSnackBar == snackBar) {
        _dismissCurrentSnackBar();
      }
    });
  }

  Future<void> _dismissCurrentSnackBar() async {
    _dismissTimer?.cancel();
    _dismissTimer = null;

    if (_currentSnackBar == null || _isDismissing) return;

    setState(() {
      _isSnackBarVisible = false;
      _isDismissing = true;
    });
    await Future<void>.delayed(_snackBarAnimationDuration);
    if (!mounted) return;

    setState(() {
      _currentSnackBar = null;
      _isDismissing = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _showNextSnackBar());
  }

  @override
  Widget build(BuildContext context) {
    final currentSnackBar = _currentSnackBar;

    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (currentSnackBar != null)
          _AppSnackBarOverlay(
            snackBar: currentSnackBar,
            isVisible: _isSnackBarVisible,
            onDismiss: _dismissCurrentSnackBar,
          ),
      ],
    );
  }
}

class _AppSnackBarMessage {
  final int id;
  final String text;
  final Color backgroundColor;
  final Color foregroundColor;
  final Duration duration;

  const _AppSnackBarMessage({
    required this.id,
    required this.text,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.duration,
  });
}

class AppSnackBarTemplate extends StatelessWidget {
  final String message;
  final Color backgroundColor;
  final Color foregroundColor;

  const AppSnackBarTemplate({
    required this.message,
    required this.backgroundColor,
    required this.foregroundColor,
    super.key,
  });

  factory AppSnackBarTemplate.fromTheme(
    BuildContext context, {
    required String message,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppSnackBarTemplate(
      message: message,
      backgroundColor: backgroundColor ?? colorScheme.inverseSurface,
      foregroundColor: foregroundColor ?? colorScheme.onInverseSurface,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: foregroundColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _AppSnackBarOverlay extends StatelessWidget {
  final _AppSnackBarMessage snackBar;
  final bool isVisible;
  final VoidCallback onDismiss;

  const _AppSnackBarOverlay({
    required this.snackBar,
    required this.isVisible,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 12,
      left: 16,
      right: 16,
      child: SafeArea(
        bottom: false,
        child: AnimatedSlide(
          offset: isVisible ? Offset.zero : const Offset(0, -0.35),
          duration: _snackBarAnimationDuration,
          curve: Curves.easeOutCubic,
          child: AnimatedOpacity(
            opacity: isVisible ? 1 : 0,
            duration: _snackBarAnimationDuration,
            curve: Curves.easeOutCubic,
            child: Dismissible(
              key: ValueKey(snackBar.id),
              direction: DismissDirection.horizontal,
              onDismissed: (_) => onDismiss(),
              child: AppSnackBarTemplate(
                message: snackBar.text,
                backgroundColor: snackBar.backgroundColor,
                foregroundColor: snackBar.foregroundColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
