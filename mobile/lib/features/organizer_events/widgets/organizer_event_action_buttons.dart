import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/primary_button.dart';

class OrganizerEventActionButtons extends StatelessWidget {
  final VoidCallback? onNotify;
  final VoidCallback? onManage;

  const OrganizerEventActionButtons({
    super.key,
    required this.onNotify,
    required this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: PrimaryButton(
            label: 'Gửi thông báo',
            icon: Icons.send,
            isFullWidth: true,
            onPressed: onNotify,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: PrimaryButton(
            label: 'Quản lý',
            icon: Icons.settings,
            isFullWidth: true,
            onPressed: onManage,
          ),
        ),
      ],
    );
  }
}
