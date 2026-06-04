import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/features/event_shared/models/event_question_model.dart';
import 'package:frontend/features/organizer_events/controller/organizer_event_controller.dart';

class OrganizerQuestionThread extends ConsumerStatefulWidget {
  final String eventId;
  final EventQuestionModel question;
  final bool showTimestamp;
  final bool compact;

  const OrganizerQuestionThread({
    super.key,
    required this.eventId,
    required this.question,
    this.showTimestamp = true,
    this.compact = false,
  });

  @override
  ConsumerState<OrganizerQuestionThread> createState() =>
      _OrganizerQuestionThreadState();
}

class _OrganizerQuestionThreadState
    extends ConsumerState<OrganizerQuestionThread> {
  late final TextEditingController _replyController;
  bool _isEditing = false;
  bool _isSubmitting = false;
  bool _showAllReplies = false;
  String? _errorMessage;

  void _startEditing() {
    if (_isSubmitting) return;
    setState(() {
      _isEditing = true;
      _errorMessage = null;
    });
  }

  @override
  void initState() {
    super.initState();
    _replyController = TextEditingController();
  }

  @override
  void didUpdateWidget(covariant OrganizerQuestionThread oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      _replyController.clear();
      _isEditing = false;
      _showAllReplies = false;
      _errorMessage = null;
    }
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.question;
    final askedAt = question.askedAt;
    final replyWidgets = _buildReplyWidgets(question);
    final avatarSize = widget.compact ? 34.0 : 38.0;
    final bubblePadding = widget.compact
        ? const EdgeInsets.symmetric(horizontal: 14, vertical: 11)
        : const EdgeInsets.symmetric(horizontal: 16, vertical: 13);

    return Padding(
      padding: EdgeInsets.only(bottom: widget.compact ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AvatarIcon(
                icon: question.isPinned ? Icons.push_pin : Icons.person,
                backgroundColor: AppColors.surfaceVariant,
                iconColor: AppColors.primary,
                size: avatarSize,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Bubble(
                      onTap: _startEditing,
                      backgroundColor: Colors.white.withValues(alpha: 0.68),
                      borderColor: question.isAnswered
                          ? AppColors.primary.withValues(alpha: 0.18)
                          : AppColors.outlineVariant,
                      padding: bubblePadding,
                      radius: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                question.isAnonymous
                                    ? 'Người tham gia ẩn danh'
                                    : 'Người tham gia',
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              _StatusPill(
                                label: question.isAnswered
                                    ? 'Đã trả lời'
                                    : 'Chờ trả lời',
                                color: question.isAnswered
                                    ? const Color(0xFF059669)
                                    : const Color(0xFFD97706),
                              ),
                              if (question.isPinned)
                                const _StatusPill(
                                  label: 'Đã ghim',
                                  color: AppColors.primary,
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            question.question,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: widget.compact ? 15 : 16,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 10,
                      children: [
                        _InlineAction(
                          label: 'Trả lời',
                          onTap: _isSubmitting ? null : _startEditing,
                        ),
                        if (widget.showTimestamp && askedAt != null)
                          Text(
                            DateFormat(
                              'dd/MM/yyyy HH:mm',
                            ).format(askedAt.toLocal()),
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.navInactive,
                            ),
                          ),
                        if (!question.isAnswered)
                          Text(
                            question.moderationStatus,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.navInactive,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (replyWidgets.isNotEmpty) ...[
            const SizedBox(height: 10),
            _ReplyPreviewList(
              replies: replyWidgets,
              showAll: _showAllReplies,
              onToggle: () =>
                  setState(() => _showAllReplies = !_showAllReplies),
            ),
          ],
          if (_isEditing) ...[
            const SizedBox(height: 12),
            Padding(
              padding: EdgeInsets.only(left: widget.compact ? 20 : 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AvatarIcon(
                    icon: Icons.admin_panel_settings_outlined,
                    backgroundColor: AppColors.primary,
                    iconColor: Colors.white,
                    size: avatarSize - 2,
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: _buildReplyEditor()),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildReplyWidgets(EventQuestionModel question) {
    return [
      if (question.answer?.isNotEmpty == true)
        _ReplyRow(
          author: question.answeredBy ?? 'BTC',
          content: question.answer!,
          isOrganizer: true,
          compact: widget.compact,
          onTap: _startEditing,
        ),
      ...question.replies.map(
        (reply) => _ReplyRow(
          author: reply.authorName,
          content: reply.content,
          isOrganizer: reply.isOrganizerReply,
          timeAgo: reply.timeAgo,
          compact: widget.compact,
          onTap: _startEditing,
        ),
      ),
    ];
  }

  Widget _buildReplyEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _replyController,
          minLines: 1,
          maxLines: 5,
          enabled: !_isSubmitting,
          textInputAction: TextInputAction.newline,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.onSurface,
            height: 1.45,
          ),
          decoration: InputDecoration(
            hintText: 'Viết câu trả lời...',
            filled: true,
            fillColor: AppColors.surfaceVariant,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 13,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: AppColors.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: AppColors.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 6),
          Text(
            _errorMessage!,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
          ),
        ],
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: _isSubmitting
                  ? null
                  : () => setState(() {
                      _isEditing = false;
                      _replyController.clear();
                      _errorMessage = null;
                    }),
              child: const Text('Hủy'),
            ),
            const SizedBox(width: 4),
            FilledButton.icon(
              onPressed: _isSubmitting ? null : _submitReply,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send_outlined, size: 16),
              label: Text(_isSubmitting ? 'Đang gửi' : 'Gửi'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _submitReply() async {
    final content = _replyController.text.trim();
    if (content.isEmpty) {
      setState(() => _errorMessage = 'Vui lòng nhập câu trả lời.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final ok = await ref
        .read(organizerEventQuestionControllerProvider.notifier)
        .replyToQuestion(
          eventId: widget.eventId,
          questionId: widget.question.id,
          content: content,
        );

    if (!mounted) return;

    if (!ok) {
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'Không gửi được câu trả lời. Vui lòng thử lại.';
      });
      return;
    }

    setState(() {
      _isSubmitting = false;
      _isEditing = false;
      _replyController.clear();
    });
  }
}

class _ReplyPreviewList extends StatelessWidget {
  static const int _collapsedCount = 2;

  final List<Widget> replies;
  final bool showAll;
  final VoidCallback onToggle;

  const _ReplyPreviewList({
    required this.replies,
    required this.showAll,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final hasHiddenReplies = replies.length > _collapsedCount;
    final visibleReplies = !hasHiddenReplies || showAll
        ? replies
        : replies.sublist(replies.length - _collapsedCount);
    final hiddenCount = replies.length - _collapsedCount;
    final list = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _withSpacing(visibleReplies),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasHiddenReplies)
          Padding(
            padding: const EdgeInsets.only(left: 28, bottom: 10),
            child: _InlineAction(
              label: showAll
                  ? 'Thu gọn phản hồi'
                  : 'Xem $hiddenCount phản hồi trước',
              onTap: onToggle,
            ),
          ),
        list,
      ],
    );
  }

  List<Widget> _withSpacing(List<Widget> items) {
    return [
      for (var i = 0; i < items.length; i++) ...[
        if (i > 0) const SizedBox(height: 8),
        items[i],
      ],
    ];
  }
}

class _ReplyRow extends StatelessWidget {
  final String author;
  final String content;
  final bool isOrganizer;
  final String? timeAgo;
  final bool compact;
  final VoidCallback? onTap;

  const _ReplyRow({
    required this.author,
    required this.content,
    required this.isOrganizer,
    this.timeAgo,
    this.compact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = isOrganizer ? AppColors.primary : AppColors.onSurfaceVariant;
    final avatarSize = compact ? 30.0 : 32.0;

    return Padding(
      padding: EdgeInsets.only(left: compact ? 18 : 22),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: avatarSize,
              child: Column(
                children: [
                  _AvatarIcon(
                    icon: isOrganizer
                        ? Icons.admin_panel_settings_outlined
                        : Icons.person_outline,
                    backgroundColor: isOrganizer
                        ? AppColors.primary
                        : AppColors.surfaceVariant,
                    iconColor: isOrganizer ? Colors.white : AppColors.primary,
                    size: avatarSize,
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Container(
                      width: 2,
                      decoration: BoxDecoration(
                        color: AppColors.outlineVariant.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Bubble(
                    onTap: onTap,
                    backgroundColor: isOrganizer
                        ? AppColors.primary.withValues(alpha: 0.08)
                        : Colors.white.withValues(alpha: 0.72),
                    borderColor: isOrganizer
                        ? AppColors.primary.withValues(alpha: 0.18)
                        : AppColors.outlineVariant,
                    padding: EdgeInsets.symmetric(
                      horizontal: compact ? 13 : 15,
                      vertical: compact ? 10 : 12,
                    ),
                    radius: 19,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              author,
                              style: AppTextStyles.labelMedium.copyWith(
                                color: accent,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (timeAgo?.isNotEmpty == true)
                              Text(
                                timeAgo!,
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: AppColors.navInactive,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          content,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.onSurface,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  _InlineAction(label: 'Trả lời', onTap: onTap),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarIcon extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final double size;

  const _AvatarIcon({
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      child: Icon(icon, color: iconColor, size: size * 0.52),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelMedium.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final Color? borderColor;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;

  const _Bubble({
    required this.child,
    this.backgroundColor,
    this.borderColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    this.radius = 18,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
    final bubble = DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surfaceVariant,
        borderRadius: borderRadius,
        border: Border.all(color: borderColor ?? AppColors.outlineVariant),
      ),
      child: Padding(padding: padding, child: child),
    );

    if (onTap == null) return bubble;

    return Semantics(
      button: true,
      label: 'Mở ô trả lời câu hỏi',
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        child: InkWell(onTap: onTap, borderRadius: borderRadius, child: bubble),
      ),
    );
  }
}

class _InlineAction extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _InlineAction({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: onTap == null ? AppColors.navInactive : AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
