import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/providers/service_providers.dart';
import 'package:frontend/features/auth/controller/otp_controller.dart';
import 'package:frontend/features/auth/services/otp_auth_service.dart';

final otpAuthServiceProvider = Provider<OtpAuthService>(
  (ref) => OtpAuthService(ref.read(apiClientProvider)),
);

final otpControllerProvider = NotifierProvider<OtpController, OtpState>(
  OtpController.new,
);
