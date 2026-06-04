// File: lib/features/event_shared/widgets/event_action_bar.dart

import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/primary_button.dart';

enum EventActionBarMode { manage, unregistered, registered }

/// Fixed bottom action bar used in event detail screens.
/// - [unregistered]: shows price + register button
/// - [registered]: shows unregister button
class EventActionBar extends StatelessWidget {
  final EventActionBarMode mode;
  final String? price;
  final VoidCallback? onRegister;
  final VoidCallback? onManage;
  final VoidCallback? onUnregister;
  final bool isRegisterLoading;
  final bool isUnregisterLoading;

  const EventActionBar({
    super.key,
    required this.mode,
    this.price,
    this.onRegister,
    this.onManage,
    this.onUnregister,
    this.isRegisterLoading = false,
    this.isUnregisterLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: switch (mode) {
            EventActionBarMode.manage => _buildManage(),
            EventActionBarMode.unregistered => _buildUnregistered(),
            EventActionBarMode.registered => _buildRegistered(),
          },
        ),
      ),
    );
  }

  Widget _buildManage() {
    return PrimaryButton(
      label: 'Quản lý',
      icon: Icons.tune,
      onPressed: onManage,
    );
  }

  Widget _buildUnregistered() {
    return Row(
      children: [
        if (price != null) ...[
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'GIÁ',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                price!,
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
        ],
        Expanded(
          child: PrimaryButton(
            label: 'Đăng ký',
            icon: Icons.arrow_forward,
            onPressed: onRegister,
            isLoading: isRegisterLoading,
          ),
        ),
      ],
    );
  }

  Widget _buildRegistered() {
    return PrimaryButton(
      label: 'Hủy đăng ký',
      icon: Icons.event_busy_outlined,
      onPressed: onUnregister,
      isLoading: isUnregisterLoading,
    );
  }
}
