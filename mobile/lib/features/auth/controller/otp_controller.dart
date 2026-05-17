// File: lib/features/auth/controller/otp_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/auth/models/auth_session_model.dart';
import 'package:frontend/features/auth/providers/auth_providers.dart';
import 'package:frontend/features/auth/providers/otp_providers.dart';
import 'package:frontend/features/auth/services/otp_auth_service.dart';

/// Trạng thái của luồng OTP.
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
  /// Thời điểm có thể gửi lại (null = có thể gửi lại ngay).
  final DateTime? canResendAt;

  const OtpSent({required this.email, this.canResendAt});
}

class OtpVerifying extends OtpState {
  const OtpVerifying();
}

class OtpVerified extends OtpState {
  final AuthSessionModel session;

  const OtpVerified(this.session);
}

class OtpError extends OtpState {
  final String message;
  final OtpErrorType type;

  const OtpError(this.message, this.type);
}

enum OtpErrorType { cooldown, invalid, maxAttempts, server }

/// Controller quản lý toàn bộ luồng OTP:
///   Idle → Sending → Sent → Verifying → Verified
///
/// UI dùng [sendOtp] và [verifyOtp].
/// AuthController nhận session sau khi verify xong.
class OtpController extends Notifier<OtpState> {
  @override
  OtpState build() => const OtpIdle();

  OtpAuthService get _service => ref.read(otpAuthServiceProvider);

  /// Gửi OTP đến [email].
  Future<void> sendOtp(String email) async {
    state = const OtpSending();
    try {
      await _service.sendOtp(email);
      state = OtpSent(
        email: email,
        canResendAt: DateTime.now().add(const Duration(seconds: 60)),
      );
    } on OtpCooldownException catch (e) {
      state = OtpSent(
        email: email,
        canResendAt: DateTime.now().add(Duration(seconds: e.remainingSeconds)),
      );
    } on OtpServerException catch (e) {
      state = OtpError(e.toString(), OtpErrorType.server);
    } catch (e) {
      state = OtpError(e.toString(), OtpErrorType.server);
    }
  }

  /// Xác thực [code] cho email đã gửi.
  /// Thành công → lưu session → state = [OtpVerified].
  Future<void> verifyOtp(String code) async {
    final sent = state;
    if (sent is! OtpSent) return;

    state = const OtpVerifying();
    try {
      final service = _service;
      final session = await service.verifyOtp(sent.email, code);

      // Lưu session vào secure storage qua AuthLocalDataSource
      final local = ref.read(authLocalDataSourceProvider);
      await local.writeSession(session);

      state = OtpVerified(session);
    } on OtpMaxAttemptsException {
      state = const OtpError(
        'Bạn đã nhập sai quá nhiều lần. Vui lòng yêu cầu mã mới.',
        OtpErrorType.maxAttempts,
      );
    } on OtpInvalidException catch (e) {
      // Giữ lại email để user có thể thử lại
      state = OtpSent(
        email: sent.email,
        canResendAt: sent.canResendAt,
      );
      // Rethrow để View bắt và hiển thị message
      throw OtpInvalidException(e.message);
    } on OtpServerException catch (e) {
      state = OtpError(e.toString(), OtpErrorType.server);
    } catch (e) {
      state = OtpError(e.toString(), OtpErrorType.server);
    }
  }

  /// Reset về Idle (khi user quay lại màn hình Login).
  void reset() => state = const OtpIdle();
}
