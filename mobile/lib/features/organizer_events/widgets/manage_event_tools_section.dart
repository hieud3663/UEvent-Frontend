import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/glass_action_tile.dart';

class ManageEventToolsSection extends StatelessWidget {
  final VoidCallback? onEditDetailsTap;
  final VoidCallback? onAttendeeListTap;
  final VoidCallback? onParticipantCheckInTap;
  final VoidCallback? onQuestionsTap;

  const ManageEventToolsSection({
    super.key,
    this.onEditDetailsTap,
    this.onAttendeeListTap,
    this.onParticipantCheckInTap,
    this.onQuestionsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            'CÔNG CỤ QUẢN LÝ',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.navInactive.withValues(alpha: 0.8),
              letterSpacing: 1.5,
            ),
          ),
        ),
        GlassActionTile(
          icon: Icons.edit_note,
          title: 'Chỉnh sửa sự kiện',
          subtitle: 'Sửa lịch, địa điểm và thông tin',
          onTap: onEditDetailsTap ?? () {},
        ),
        GlassActionTile(
          icon: Icons.group_outlined,
          title: 'Danh sách người đăng ký',
          subtitle: 'Tìm theo email và phân quyền đồng tổ chức',
          onTap: onAttendeeListTap ?? () {},
        ),
        GlassActionTile(
          icon: Icons.qr_code_scanner,
          title: 'Check-in',
          subtitle: 'Quét vé và cho người tham gia vào sự kiện',
          onTap: onParticipantCheckInTap ?? () {},
        ),
        GlassActionTile(
          icon: Icons.forum_outlined,
          title: 'Danh sách câu hỏi',
          subtitle: 'Xem và trả lời câu hỏi từ người tham gia',
          onTap: onQuestionsTap ?? () {},
        ),
      ],
    );
  }
}
