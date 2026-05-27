import 'package:flutter/foundation.dart';
import 'package:passkeys/authenticator.dart';

class PasskeyCapabilityService {
  final TargetPlatform? platformOverride;
  final bool? webOverride;
  final PasskeyAuthenticator? authenticator;

  const PasskeyCapabilityService({
    this.platformOverride,
    this.webOverride,
    this.authenticator,
  });

  Future<bool> isSupported() async {
    final isWeb = webOverride ?? kIsWeb;
    final platform = platformOverride ?? defaultTargetPlatform;

    if (platformOverride != null || webOverride != null) {
      if (isWeb) return true;
      return switch (platform) {
        TargetPlatform.android || TargetPlatform.iOS => true,
        TargetPlatform.macOS ||
        TargetPlatform.windows ||
        TargetPlatform.linux ||
        TargetPlatform.fuchsia => false,
      };
    }

    final availability =
        authenticator?.getAvailability() ??
        PasskeyAuthenticator().getAvailability();

    try {
      if (isWeb) {
        return (await availability.web()).hasPasskeySupport;
      }

      return switch (platform) {
        TargetPlatform.android =>
          (await availability.android()).hasPasskeySupport,
        TargetPlatform.iOS => (await availability.iOS()).hasPasskeySupport,
        TargetPlatform.macOS ||
        TargetPlatform.windows ||
        TargetPlatform.linux ||
        TargetPlatform.fuchsia => false,
      };
    } catch (_) {
      return false;
    }
  }
}
