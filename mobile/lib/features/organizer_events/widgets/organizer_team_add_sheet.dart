import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/app_snack_bar.dart';
import 'package:frontend/core/widgets/glass_container.dart';
import 'package:frontend/core/widgets/glass_input_field.dart';
import 'package:frontend/core/widgets/primary_button.dart';
import 'package:frontend/features/organizer_events/controller/organizer_event_controller.dart';

class OrganizerTeamAddSheet extends ConsumerStatefulWidget {
  final String eventId;

  const OrganizerTeamAddSheet({super.key, required this.eventId});

  @override
  ConsumerState<OrganizerTeamAddSheet> createState() =>
      _OrganizerTeamAddSheetState();
}

class _OrganizerTeamAddSheetState extends ConsumerState<OrganizerTeamAddSheet> {
  final _emailController = TextEditingController();
  bool _isAdding = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 12,
          right: 12,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 12,
        ),
        child: GlassContainer(
          padding: const EdgeInsets.all(20),
          borderRadius: 24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Thêm BTC', style: AppTextStyles.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'Nhập email tài khoản UEvent để cấp quyền đồng tổ chức.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              GlassInputField(
                label: 'Email',
                placeholder: 'name@example.com',
                leadingIcon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'Thêm BTC',
                icon: Icons.person_add_alt_1,
                isLoading: _isAdding,
                onPressed: _isAdding ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      showAppSnackBar(context, 'Vui lòng nhập email.');
      return;
    }

    setState(() => _isAdding = true);

    final ok = await ref
        .read(organizerEventMutationControllerProvider.notifier)
        .addOrganizerByEmail(eventId: widget.eventId, email: email);

    if (!mounted) return;
    setState(() => _isAdding = false);

    if (ok) {
      Navigator.of(context).pop(true);
      return;
    }

    showAppSnackBar(
      context,
      'Không thêm được BTC. Vui lòng kiểm tra email và quyền owner.',
    );
  }
}
