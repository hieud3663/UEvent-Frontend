// File: lib/features/events/widgets/event_action_bar.dart

import 'package:flutter/material.dart';
import '../../../apps/app_colors.dart';
import '../../../apps/app_text_styles.dart';

enum EventActionBarMode { unregistered, registered }

/// Fixed bottom action bar used in event detail screens.
/// - [unregistered]: shows price + "Register Now →"
/// - [registered]: shows "My Ticket" + "Contact" + "Unregister" text button
class EventActionBar extends StatelessWidget {
  final EventActionBarMode mode;
  final String? price;
  final VoidCallback? onRegister;
  final VoidCallback? onMyTicket;
  final VoidCallback? onContact;
  final VoidCallback? onUnregister;

  const EventActionBar({
    super.key,
    required this.mode,
    this.price,
    this.onRegister,
    this.onMyTicket,
    this.onContact,
    this.onUnregister,
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
          child: mode == EventActionBarMode.unregistered
              ? _buildUnregistered()
              : _buildRegistered(),
        ),
      ),
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
                'PRICE',
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
          child: _PrimaryActionButton(
            label: 'Register Now',
            icon: Icons.arrow_forward,
            onPressed: onRegister,
          ),
        ),
      ],
    );
  }

  Widget _buildRegistered() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _PrimaryActionButton(
                label: 'My Ticket',
                icon: Icons.confirmation_number_outlined,
                onPressed: onMyTicket,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SecondaryActionButton(
                label: 'Contact',
                icon: Icons.chat_bubble_outline,
                onPressed: onContact,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onUnregister,
          child: Text(
            'Unregister from event',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.onSurfaceVariant,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ],
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  const _PrimaryActionButton({
    required this.label,
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: AppColors.onPrimaryDark),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.titleSmall.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.onPrimaryDark,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  const _SecondaryActionButton({
    required this.label,
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outline),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: AppColors.onSurface),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.titleSmall.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
