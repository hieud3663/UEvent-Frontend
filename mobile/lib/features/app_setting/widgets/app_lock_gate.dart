import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/features/app_setting/models/app_setting_key.dart';
import 'package:frontend/features/app_setting/providers/app_setting_providers.dart';

class AppLockGate extends ConsumerStatefulWidget {
  final Widget child;

  const AppLockGate({required this.child, super.key});

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate>
    with WidgetsBindingObserver {
  DateTime? _lastInactiveAt;
  bool _locked = false;
  bool _authenticating = false;
  bool _initialLockChecked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _lastInactiveAt = DateTime.now();
      return;
    }

    if (state == AppLifecycleState.resumed) {
      _lockIfNeeded();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingControllerProvider).value;
    final appLockEnabled =
        settings?.boolValue(AppSettingKey.securityAppLockEnabled) ?? false;

    if (!appLockEnabled && (_locked || _initialLockChecked)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _locked = false;
          _initialLockChecked = false;
        });
      });
    }

    if (appLockEnabled && !_initialLockChecked) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _initialLockChecked) return;
        setState(() {
          _initialLockChecked = true;
          _locked = true;
        });
        _authenticate();
      });
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (_locked && appLockEnabled)
          _AppLockOverlay(
            authenticating: _authenticating,
            onUnlock: _authenticate,
          ),
      ],
    );
  }

  void _lockIfNeeded() {
    final settings = ref.read(appSettingControllerProvider).value;
    if (settings == null ||
        !settings.boolValue(AppSettingKey.securityAppLockEnabled)) {
      return;
    }

    final lockAfterSeconds = settings.intValue(
      AppSettingKey.securityLockAfterSeconds,
      fallback: 60,
    );
    final lastInactiveAt = _lastInactiveAt;
    if (lastInactiveAt == null) return;

    final elapsed = DateTime.now().difference(lastInactiveAt).inSeconds;
    if (elapsed < lockAfterSeconds) return;

    setState(() => _locked = true);
    _authenticate();
  }

  Future<void> _authenticate() async {
    if (_authenticating) return;

    setState(() => _authenticating = true);
    try {
      final authService = ref.read(localAuthenticationServiceProvider);
      final settings = ref.read(appSettingControllerProvider).value;
      final biometricOnly =
          settings?.boolValue(AppSettingKey.securityBiometricUnlockEnabled) ??
          false;
      final supported = await authService.isSupported(
        biometricOnly: biometricOnly,
      );
      if (!supported) {
        if (mounted) setState(() => _locked = false);
        return;
      }

      final authenticated = await authService.authenticate(
        'Xác thực để mở khóa UEvents.',
        biometricOnly: biometricOnly,
      );
      if (authenticated && mounted) {
        setState(() => _locked = false);
      }
    } finally {
      if (mounted) setState(() => _authenticating = false);
    }
  }
}

class _AppLockOverlay extends StatelessWidget {
  final bool authenticating;
  final VoidCallback onUnlock;

  const _AppLockOverlay({required this.authenticating, required this.onUnlock});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock,
                    color: AppColors.primary,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 20),
                Text('UEvents đang khóa', style: AppTextStyles.titleLarge),
                const SizedBox(height: 8),
                Text(
                  'Vui lòng xác thực để tiếp tục sử dụng ứng dụng.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: authenticating ? null : onUnlock,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(authenticating ? 'Đang xác thực...' : 'Mở khóa'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
