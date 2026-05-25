import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/uevents_app.dart';

export 'package:frontend/app/uevents_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _configureDisplayMode();
  _configureSystemChrome();

  runApp(const ProviderScope(child: UEventsApp()));
}

Future<void> _configureDisplayMode() async {
  if (kIsWeb || !Platform.isAndroid) return;

  try {
    await FlutterDisplayMode.setHighRefreshRate();
  } catch (_) {
    // Ignore device-specific failures and continue app startup.
  }
}

void _configureSystemChrome() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
}
