import 'package:local_auth/local_auth.dart';

class LocalAuthenticationService {
  const LocalAuthenticationService();

  Future<bool> isSupported({bool biometricOnly = false}) async {
    final localAuth = LocalAuthentication();
    final supported = await localAuth.isDeviceSupported().catchError(
      (_) => false,
    );
    if (!supported) return false;
    if (!biometricOnly) return true;

    final canCheckBiometrics = await localAuth.canCheckBiometrics.catchError(
      (_) => false,
    );
    if (!canCheckBiometrics) return false;

    final availableBiometrics = await localAuth
        .getAvailableBiometrics()
        .catchError((_) => <BiometricType>[]);
    return availableBiometrics.isNotEmpty;
  }

  Future<bool> authenticate(String reason, {bool biometricOnly = false}) async {
    if (!await isSupported(biometricOnly: biometricOnly)) return false;

    final localAuth = LocalAuthentication();
    return localAuth
        .authenticate(
          localizedReason: reason,
          biometricOnly: biometricOnly,
          sensitiveTransaction: true,
        )
        .catchError((_) => false);
  }
}
