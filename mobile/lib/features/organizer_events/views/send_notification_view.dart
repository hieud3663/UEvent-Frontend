import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/app_snack_bar.dart';
import 'package:frontend/core/widgets/glass_filter_chip.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/core/widgets/primary_button.dart';
import 'package:frontend/features/notifications/providers/notification_providers.dart';
import 'package:frontend/features/organizer_events/models/organizer_notification_audience_option.dart';
import 'package:frontend/features/organizer_events/models/organizer_notification_template.dart';
import 'package:frontend/features/organizer_events/providers/organizer_event_providers.dart';
import 'package:frontend/features/organizer_events/widgets/notification_preview_card.dart';
import 'package:frontend/features/organizer_events/widgets/notification_template_card.dart';
import 'package:frontend/features/organizer_events/widgets/send_notification_section_label.dart';

class SendNotificationView extends ConsumerStatefulWidget {
  final String eventId;
  final String eventTitle;
  final VoidCallback? onBack;

  const SendNotificationView({
    super.key,
    required this.eventId,
    required this.eventTitle,
    this.onBack,
  });

  @override
  ConsumerState<SendNotificationView> createState() =>
      _SendNotificationViewState();
}

class _SendNotificationViewState extends ConsumerState<SendNotificationView> {
  String _selectedAudience = 'registered';
  String _selectedTemplateId = 'event_reminder';
  bool _sendPush = true;
  bool _isSending = false;

  OrganizerNotificationTemplate get _selectedTemplate =>
      organizerNotificationTemplates.firstWhere(
        (template) => template.id == _selectedTemplateId,
        orElse: () => organizerNotificationTemplates.first,
      );

  Future<void> _send() async {
    final template = _selectedTemplate;
    final title = template.resolveTitle(widget.eventTitle);
    final message = template.resolveMessage(widget.eventTitle);

    setState(() => _isSending = true);
    try {
      final result = await ref
          .read(organizerEventRepositoryProvider)
          .sendEventNotification(
            eventId: widget.eventId,
            title: title,
            message: message,
            audience: _selectedAudience,
            sendPush: _sendPush,
          );
      ref.invalidate(notificationsControllerProvider);
      if (!mounted) return;

      final count = (result['recipient_count'] as num?)?.toInt() ?? 0;
      showAppSnackBar(context, 'Đã gửi thông báo đến $count người nhận.');
    } on DioException catch (error) {
      if (!mounted) return;
      final responseData = error.response?.data;
      final message = responseData is Map<String, dynamic>
          ? responseData['message']?.toString()
          : null;
      showAppSnackBar(
        context,
        message?.isNotEmpty == true
            ? message!
            : 'Không thể gửi thông báo. Vui lòng thử lại.',
      );
    } catch (_) {
      if (!mounted) return;
      showAppSnackBar(context, 'Không thể gửi thông báo. Vui lòng thử lại.');
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 110)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.pagePaddingH,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Text(widget.eventTitle, style: AppTextStyles.titleMedium),
                    const SizedBox(height: 24),
                    const SendNotificationSectionLabel('NGƯỜI NHẬN'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final audience
                            in organizerNotificationAudienceOptions)
                          GlassFilterChip(
                            label: audience.label,
                            isActive: _selectedAudience == audience.value,
                            onTap: () {
                              if (_isSending) return;
                              setState(
                                () => _selectedAudience = audience.value,
                              );
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Gửi push notification',
                        style: AppTextStyles.bodyMedium,
                      ),
                      value: _sendPush,
                      onChanged: _isSending
                          ? null
                          : (value) => setState(() => _sendPush = value),
                    ),
                    const SizedBox(height: 24),
                    const SendNotificationSectionLabel('MẪU THÔNG BÁO'),
                    for (final template in organizerNotificationTemplates) ...[
                      NotificationTemplateCard(
                        template: template,
                        eventTitle: widget.eventTitle,
                        isSelected: _selectedTemplateId == template.id,
                        onTap: _isSending
                            ? null
                            : () => setState(
                                () => _selectedTemplateId = template.id,
                              ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    const SizedBox(height: 12),
                    const SendNotificationSectionLabel('XEM TRƯỚC'),
                    NotificationPreviewCard(
                      title: _selectedTemplate.resolveTitle(widget.eventTitle),
                      message: _selectedTemplate.resolveMessage(
                        widget.eventTitle,
                      ),
                    ),
                    const SizedBox(height: 32),
                    PrimaryButton(
                      label: 'Gửi thông báo',
                      icon: Icons.send,
                      isLoading: _isSending,
                      onPressed: _isSending ? null : () => unawaited(_send()),
                    ),
                    const SizedBox(height: 120),
                  ]),
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GlassTopBar(
              title: 'Gửi thông báo',
              leadingIcon: Icons.chevron_left,
              onLeadingTap: widget.onBack ?? () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
