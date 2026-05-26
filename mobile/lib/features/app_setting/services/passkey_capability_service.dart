import 'package:flutter/foundation.dart';

class PasskeyCapabilityService {
  final TargetPlatform? platformOverride;
  final bool? webOverride;

  const PasskeyCapabilityService({this.platformOverride, this.webOverride});

  Future<bool> isSupported() async {
    final isWeb = webOverride ?? kIsWeb;
    if (isWeb) return true;

    final platform = platformOverride ?? defaultTargetPlatform;
    return switch (platform) {
      TargetPlatform.android || TargetPlatform.iOS => true,
      TargetPlatform.macOS ||
      TargetPlatform.windows ||
      TargetPlatform.linux ||
      TargetPlatform.fuchsia => false,
    };
  }
}
