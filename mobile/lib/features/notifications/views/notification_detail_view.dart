import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/glass_container.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/features/notifications/models/notification_model.dart';

class NotificationDetailView extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onBack;

  const NotificationDetailView({
    super.key,
    required this.notification,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.pagePaddingH,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _NotificationHero(notification: notification),
                      const SizedBox(height: 16),
                      _NotificationMeta(notification: notification),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GlassTopBar(
              title: 'Chi tiết thông báo',
              leadingIcon: Icons.arrow_back,
              onLeadingTap: onBack ?? () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationHero extends StatelessWidget {
  final NotificationModel notification;

  const _NotificationHero({required this.notification});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: AppConstants.radiusCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NotificationIcon(type: notification.type),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _typeLabel(notification.type),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(notification.title, style: AppTextStyles.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      _formatTimestamp(notification.timestamp),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.navInactive,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(notification.message, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }

  String _typeLabel(NotificationType type) {
    switch (type) {
      case NotificationType.eventInvite:
        return 'Lời mời sự kiện';
      case NotificationType.eventUpdate:
        return 'Cập nhật sự kiện';
      case NotificationType.announcement:
      case NotificationType.organizerAnnouncement:
        return 'Thông báo chung';
      case NotificationType.reminder:
        return 'Nhắc nhở';
      case NotificationType.ticketConfirm:
      case NotificationType.registrationConfirmed:
        return 'Xác nhận đăng ký';
      case NotificationType.registrationWaitlisted:
        return 'Danh sách chờ';
      case NotificationType.newRegistration:
        return 'Đăng ký mới';
      case NotificationType.questionAnswered:
        return 'Trả lời câu hỏi';
      case NotificationType.organizerRequestApproved:
        return 'Yêu cầu được duyệt';
      case NotificationType.organizerRequestRejected:
        return 'Yêu cầu bị từ chối';
      case NotificationType.alert:
        return 'Cảnh báo';
      case NotificationType.promotion:
        return 'Khuyến mãi';
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    return DateFormat('HH:mm, dd/MM/yyyy').format(timestamp.toLocal());
  }
}

class _NotificationMeta extends StatelessWidget {
  final NotificationModel notification;

  const _NotificationMeta({required this.notification});

  @override
  Widget build(BuildContext context) {
    final rows = <_MetaRow>[
      _MetaRow(
        label: 'Trạng thái',
        value: notification.isRead ? 'Đã đọc' : 'Chưa đọc',
      ),
      if (notification.relatedEventId?.isNotEmpty == true)
        _MetaRow(
          label: 'Sự kiện liên quan',
          value: notification.relatedEventId!,
        ),
    ];

    if (rows.isEmpty) return const SizedBox.shrink();

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: AppConstants.radiusCard,
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            _MetaRowTile(row: rows[i]),
            if (i != rows.length - 1) const Divider(height: 20),
          ],
        ],
      ),
    );
  }
}

class _NotificationIcon extends StatelessWidget {
  final NotificationType type;

  const _NotificationIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    final icon = switch (type) {
      NotificationType.eventInvite => Icons.event,
      NotificationType.eventUpdate => Icons.update,
      NotificationType.announcement => Icons.campaign,
      NotificationType.organizerAnnouncement => Icons.campaign,
      NotificationType.reminder => Icons.alarm,
      NotificationType.ticketConfirm => Icons.confirmation_number,
      NotificationType.registrationConfirmed => Icons.confirmation_number,
      NotificationType.registrationWaitlisted => Icons.hourglass_top,
      NotificationType.newRegistration => Icons.person_add,
      NotificationType.questionAnswered => Icons.question_answer,
      NotificationType.organizerRequestApproved => Icons.verified_user,
      NotificationType.organizerRequestRejected => Icons.gpp_bad,
      NotificationType.alert => Icons.warning_amber_rounded,
      NotificationType.promotion => Icons.local_offer,
    };

    return Container(
      width: 52,
      height: 52,
      decoration: const BoxDecoration(
        color: AppColors.primaryFixed,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AppColors.primary),
    );
  }
}

class _MetaRow {
  final String label;
  final String value;

  const _MetaRow({required this.label, required this.value});
}

class _MetaRowTile extends StatelessWidget {
  final _MetaRow row;

  const _MetaRowTile({required this.row});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            row.label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.navInactive,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(row.value, style: AppTextStyles.bodyMedium)),
      ],
    );
  }
}
