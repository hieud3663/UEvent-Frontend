import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/auth/models/auth_session_model.dart';
import 'package:frontend/features/auth/providers/auth_providers.dart';
import 'package:frontend/features/auth/providers/otp_providers.dart';
import 'package:frontend/features/auth/services/otp_auth_service.dart';

sealed class OtpState {
  const OtpState();
}

class OtpIdle extends OtpState {
  const OtpIdle();
}

class OtpSending extends OtpState {
  const OtpSending();
}

class OtpSent extends OtpState {
  final String email;
  final DateTime? canResendAt;

  const OtpSent({required this.email, this.canResendAt});
}

class OtpVerifying extends OtpState {
  final String email;
  final DateTime? canResendAt;

  const OtpVerifying({required this.email, this.canResendAt});
}

class OtpVerified extends OtpState {
  final AuthSessionModel session;

  const OtpVerified(this.session);
}

class OtpError extends OtpState {
  final String email;
  final String message;
  final OtpErrorType type;
  final DateTime? canResendAt;

  const OtpError({
    required this.email,
    required this.message,
    required this.type,
    this.canResendAt,
  });
}

enum OtpErrorType { cooldown, invalid, maxAttempts, server }

class OtpController extends Notifier<OtpState> {
  @override
  OtpState build() => const OtpIdle();

  OtpAuthService get _service => ref.read(otpAuthServiceProvider);

  Future<void> sendOtp(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty) {
      state = const OtpError(
        email: '',
        message: 'Vui lòng nhập email hợp lệ.',
        type: OtpErrorType.invalid,
      );
      return;
    }

    state = const OtpSending();
    try {
      await _service.sendOtp(normalizedEmail);
      state = OtpSent(
        email: normalizedEmail,
        canResendAt: DateTime.now().add(const Duration(seconds: 60)),
      );
    } on OtpCooldownException catch (error) {
      state = OtpSent(
        email: normalizedEmail,
        canResendAt: DateTime.now().add(
          Duration(seconds: error.remainingSeconds),
        ),
      );
    } on OtpServerException catch (error) {
      state = OtpError(
        email: normalizedEmail,
        message: error.message,
        type: OtpErrorType.server,
      );
    } catch (_) {
      state = OtpError(
        email: normalizedEmail,
        message: 'Không gửi được OTP. Vui lòng thử lại.',
        type: OtpErrorType.server,
      );
    }
  }

  Future<void> verifyOtp(String code) async {
    final currentState = state;
    final email = switch (currentState) {
      OtpSent(email: final value) => value,
      OtpError(email: final value) => value,
      _ => null,
    };
    final canResendAt = switch (currentState) {
      OtpSent(canResendAt: final value) => value,
      OtpError(canResendAt: final value) => value,
      _ => null,
    };

    if (email == null || email.isEmpty || code.length != 6) return;

    state = OtpVerifying(email: email, canResendAt: canResendAt);
    try {
      final session = await _service.verifyOtp(email, code);
      await ref.read(authLocalDataSourceProvider).writeSession(session);
      state = OtpVerified(session);
    } on OtpMaxAttemptsException catch (error) {
      state = OtpError(
        email: email,
        message: error.toString(),
        type: OtpErrorType.maxAttempts,
        canResendAt: canResendAt,
      );
    } on OtpInvalidException catch (error) {
      state = OtpError(
        email: email,
        message: error.message,
        type: OtpErrorType.invalid,
        canResendAt: canResendAt,
      );
    } on OtpServerException catch (error) {
      state = OtpError(
        email: email,
        message: error.message,
        type: OtpErrorType.server,
        canResendAt: canResendAt,
      );
    } catch (_) {
      state = OtpError(
        email: email,
        message: 'Không thể xác thực OTP. Vui lòng thử lại.',
        type: OtpErrorType.server,
        canResendAt: canResendAt,
      );
    }
  }

  void reset() => state = const OtpIdle();
}
