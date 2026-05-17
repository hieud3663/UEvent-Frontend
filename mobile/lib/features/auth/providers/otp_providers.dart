// File: lib/features/auth/providers/otp_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/providers/service_providers.dart';
import 'package:frontend/features/auth/controller/otp_controller.dart';
import 'package:frontend/features/auth/services/otp_auth_service.dart';

// ── Service ──

final otpAuthServiceProvider = Provider<OtpAuthService>(
  (ref) => OtpAuthService(ref.read(apiClientProvider)),
);

// ── Controller ──

/// Provider cho OtpController.
/// Dùng [NotifierProvider] (không phải Async) vì state machine là synchronous —
/// các async ops xảy ra bên trong methods của controller.
final otpControllerProvider = NotifierProvider<OtpController, OtpState>(
  OtpController.new,
);
