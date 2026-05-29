import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/app_snack_bar.dart';
import 'package:frontend/core/widgets/glass_container.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/core/widgets/primary_button.dart';
import 'package:frontend/features/auth/models/auth_failure.dart';
import 'package:frontend/features/auth/models/passkey_credential_model.dart';
import 'package:frontend/features/auth/providers/passkey_providers.dart';

class PasskeySetupView extends ConsumerStatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onPasskeyCreated;

  const PasskeySetupView({super.key, this.onBack, this.onPasskeyCreated});

  @override
  ConsumerState<PasskeySetupView> createState() => _PasskeySetupViewState();
}

class _PasskeySetupViewState extends ConsumerState<PasskeySetupView> {
  bool _isCreating = false;
  String? _revokingId;

  Future<void> _createPasskey() async {
    if (_isCreating) return;

    setState(() => _isCreating = true);
    try {
      await ref.read(passkeyAuthServiceProvider).register();
      ref.invalidate(passkeyCredentialsProvider);
      if (mounted) {
        showAppSnackBar(context, 'Đã tạo passkey thành công.');
        widget.onPasskeyCreated?.call();
      }
    } on AuthFailure catch (error) {
      if (mounted && error is! AuthFailureCancelled) {
        showAppSnackBar(context, error.displayMessage);
      }
    } catch (error) {
      if (mounted) {
        showAppSnackBar(context, 'Không thể tạo passkey. Vui lòng thử lại.');
      }
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  Future<void> _revokePasskey(PasskeyCredentialModel credential) async {
    if (_revokingId != null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thu hồi passkey?'),
        content: Text(
          'Passkey "${credential.displayName}" sẽ không thể dùng để đăng nhập nữa.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Thu hồi'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _revokingId = credential.id);
    try {
      await ref.read(passkeyAuthServiceProvider).revoke(credential.id);
      ref.invalidate(passkeyCredentialsProvider);
      if (mounted) showAppSnackBar(context, 'Đã thu hồi passkey.');
    } on AuthFailure catch (error) {
      if (mounted) showAppSnackBar(context, error.displayMessage);
    } catch (_) {
      if (mounted) {
        showAppSnackBar(
          context,
          'Không thể thu hồi passkey. Vui lòng thử lại.',
        );
      }
    } finally {
      if (mounted) setState(() => _revokingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final credentialsAsync = ref.watch(passkeyCredentialsProvider);
    final credentials = credentialsAsync.value ?? const [];
    final canCreatePasskey = credentialsAsync.maybeWhen(
      data: (items) => items.isEmpty,
      orElse: () => false,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(passkeyCredentialsProvider);
              await ref.read(passkeyCredentialsProvider.future);
            },
            child: CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 32),
                        _PasskeyHero(),
                        const SizedBox(height: 24),
                        Text(
                          'Bảo vệ tài khoản bằng passkey',
                          style: AppTextStyles.headlineLarge.copyWith(
                            fontSize: 24,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Dùng khóa bảo mật của thiết bị để đăng nhập nhanh mà không cần OTP khi server xác minh hợp lệ.',
                          style: AppTextStyles.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        _buildBentoItem(
                          icon: Icons.verified_user,
                          title: 'Chống giả mạo đăng nhập',
                          desc:
                              'Passkey được xác minh bằng challenge từ server và không gửi khóa bí mật lên backend.',
                        ),
                        const SizedBox(height: 16),
                        _buildBentoItem(
                          icon: Icons.speed,
                          title: 'Đăng nhập nhanh',
                          desc:
                              'Sử dụng khóa màn hình, vân tay hoặc khuôn mặt đang có trên thiết bị.',
                        ),
                        const SizedBox(height: 16),
                        _buildBentoItem(
                          icon: Icons.sync,
                          title: 'OTP vẫn là dự phòng',
                          desc:
                              'Nếu thiết bị không hỗ trợ hoặc passkey bị thu hồi, người dùng vẫn đăng nhập bằng OTP.',
                        ),
                        const SizedBox(height: 32),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16, bottom: 8),
                            child: Text(
                              'PASSKEY ĐÃ ĐĂNG KÝ',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.onSurfaceVariant.withValues(
                                  alpha: 0.6,
                                ),
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),
                        _PasskeyCredentialList(
                          credentialsAsync: credentialsAsync,
                          credentials: credentials,
                          revokingId: _revokingId,
                          onRevoke: _revokePasskey,
                        ),
                        const SizedBox(height: 32),
                        if (canCreatePasskey) ...[
                          PrimaryButton(
                            label: _isCreating
                                ? 'Đang tạo passkey'
                                : 'Tạo passkey',
                            icon: Icons.add_circle,
                            isLoading: _isCreating,
                            onPressed: _isCreating ? null : _createPasskey,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Credential được lưu trong trình quản lý passkey của hệ điều hành.',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.onSurfaceVariant.withValues(
                                alpha: 0.5,
                              ),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GlassTopBar(
              title: 'Đăng nhập bằng passkey',
              leadingIcon: Icons.chevron_left,
              onLeadingTap: widget.onBack,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBentoItem({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.primaryContainer, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(desc, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PasskeyHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primaryContainer.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
          ),
          const Icon(
            Icons.vpn_key,
            size: 56,
            color: AppColors.primaryContainer,
          ),
        ],
      ),
    );
  }
}

class _PasskeyCredentialList extends StatelessWidget {
  final AsyncValue<List<PasskeyCredentialModel>> credentialsAsync;
  final List<PasskeyCredentialModel> credentials;
  final String? revokingId;
  final ValueChanged<PasskeyCredentialModel> onRevoke;

  const _PasskeyCredentialList({
    required this.credentialsAsync,
    required this.credentials,
    required this.revokingId,
    required this.onRevoke,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: EdgeInsets.zero,
      child: credentialsAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (_, _) => Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Không thể tải danh sách passkey. Kéo xuống để thử lại.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        data: (_) {
          if (credentials.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Chưa có passkey nào cho tài khoản này.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            );
          }

          return Column(
            children: [
              for (var index = 0; index < credentials.length; index++) ...[
                _PasskeyCredentialTile(
                  credential: credentials[index],
                  isRevoking: revokingId == credentials[index].id,
                  onRevoke: () => onRevoke(credentials[index]),
                ),
                if (index != credentials.length - 1)
                  Divider(
                    height: 1,
                    color: Colors.black.withValues(alpha: 0.05),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _PasskeyCredentialTile extends StatelessWidget {
  final PasskeyCredentialModel credential;
  final bool isRevoking;
  final VoidCallback onRevoke;

  const _PasskeyCredentialTile({
    required this.credential,
    required this.isRevoking,
    required this.onRevoke,
  });

  @override
  Widget build(BuildContext context) {
    final lastUsed = credential.lastUsedAt;
    final subtitle = lastUsed == null
        ? 'Chưa dùng để đăng nhập'
        : 'Dùng lần cuối ${_dateLabel(lastUsed)}';

    return ListTile(
      leading: const Icon(Icons.vpn_key, color: AppColors.primary),
      title: Text(credential.displayName, style: AppTextStyles.bodyMedium),
      subtitle: Text(subtitle, style: AppTextStyles.bodySmall),
      trailing: IconButton(
        tooltip: 'Thu hồi passkey',
        onPressed: isRevoking ? null : onRevoke,
        icon: isRevoking
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.delete_outline, color: AppColors.error),
      ),
    );
  }

  String _dateLabel(DateTime value) {
    final local = value.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year}';
  }
}
