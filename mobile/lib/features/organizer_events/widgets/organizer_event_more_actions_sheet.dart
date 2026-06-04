import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/event_shared/models/event_model.dart';
import 'package:frontend/features/organizer_events/widgets/organizer_event_more_action_tile.dart';

class OrganizerEventMoreActionsSheet extends StatelessWidget {
  final EventModel event;
  final VoidCallback? onManage;
  final VoidCallback? onCheckIn;
  final VoidCallback? onNotify;
  final VoidCallback? onShare;
  final VoidCallback onRefresh;

  const OrganizerEventMoreActionsSheet({
    super.key,
    required this.event,
    required this.onManage,
    required this.onCheckIn,
    required this.onNotify,
    required this.onShare,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 12),
            OrganizerEventMoreActionTile(
              icon: Icons.tune,
              title: 'Mở trung tâm quản lý',
              subtitle: 'Chỉnh thông tin, danh sách khách và hỏi đáp',
              onTap: onManage == null
                  ? null
                  : () {
                      Navigator.of(context).pop();
                      onManage?.call();
                    },
            ),
            OrganizerEventMoreActionTile(
              icon: Icons.qr_code_scanner,
              title: 'Check-in người tham gia',
              subtitle: 'Quét vé QR cho sự kiện này',
              onTap: onCheckIn == null
                  ? null
                  : () {
                      Navigator.of(context).pop();
                      onCheckIn?.call();
                    },
            ),
            OrganizerEventMoreActionTile(
              icon: Icons.notifications_active_outlined,
              title: 'Gửi thông báo',
              subtitle: 'Thông báo nhanh đến người tham dự',
              onTap: onNotify == null
                  ? null
                  : () {
                      Navigator.of(context).pop();
                      onNotify?.call();
                    },
            ),
            OrganizerEventMoreActionTile(
              icon: Icons.share_outlined,
              title: 'Chia sẻ sự kiện',
              subtitle: event.visibility == EventVisibility.public
                  ? 'Tạo liên kết công khai cho người tham dự'
                  : 'Sự kiện riêng tư không hỗ trợ chia sẻ công khai',
              onTap: onShare == null
                  ? null
                  : () {
                      Navigator.of(context).pop();
                      onShare?.call();
                    },
            ),
            OrganizerEventMoreActionTile(
              icon: Icons.refresh,
              title: 'Làm mới dữ liệu',
              subtitle: 'Cập nhật thông tin và câu hỏi mới nhất',
              onTap: () {
                Navigator.of(context).pop();
                onRefresh();
              },
            ),
          ],
        ),
      ),
    );
  }
}
