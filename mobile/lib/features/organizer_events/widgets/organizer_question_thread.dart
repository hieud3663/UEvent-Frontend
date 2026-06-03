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

    return Padding(
      padding: EdgeInsets.only(bottom: widget.compact ? 10 : 12),
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
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Bubble(
                      onTap: _startEditing,
                      child: Text(
                        question.question,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
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
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.navInactive,
                            ),
                          ),
                        if (!question.isAnswered)
                          Text(
                            question.moderationStatus,
                            style: AppTextStyles.labelSmall.copyWith(
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
            const SizedBox(height: 8),
            _ReplyPreviewList(
              replies: replyWidgets,
              showAll: _showAllReplies,
              onToggle: () =>
                  setState(() => _showAllReplies = !_showAllReplies),
            ),
          ],
          if (_isEditing) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 42),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _AvatarIcon(
                    icon: Icons.admin_panel_settings_outlined,
                    backgroundColor: AppColors.primary,
                    iconColor: Colors.white,
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
          onTap: _startEditing,
        ),
      ...question.replies.map(
        (reply) => _ReplyRow(
          author: reply.authorName,
          content: reply.content,
          isOrganizer: reply.isOrganizerReply,
          timeAgo: reply.timeAgo,
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
          maxLines: 4,
          enabled: !_isSubmitting,
          textInputAction: TextInputAction.newline,
          decoration: InputDecoration(
            hintText: 'Viết câu trả lời...',
            filled: true,
            fillColor: AppColors.surfaceVariant,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: AppColors.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: AppColors.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
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
            padding: const EdgeInsets.only(left: 42, bottom: 8),
            child: _InlineAction(
              label: showAll
                  ? 'Thu gọn phản hồi'
                  : 'Xem $hiddenCount phản hồi trước',
              onTap: onToggle,
            ),
          ),
        if (hasHiddenReplies && showAll)
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 180),
            child: SingleChildScrollView(child: list),
          )
        else
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
  final VoidCallback? onTap;

  const _ReplyRow({
    required this.author,
    required this.content,
    required this.isOrganizer,
    this.timeAgo,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = isOrganizer ? AppColors.primary : AppColors.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.only(left: 42),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AvatarIcon(
            icon: isOrganizer
                ? Icons.admin_panel_settings_outlined
                : Icons.person_outline,
            backgroundColor: isOrganizer
                ? AppColors.primary
                : AppColors.surfaceVariant,
            iconColor: isOrganizer ? Colors.white : AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _Bubble(
              onTap: onTap,
              backgroundColor: isOrganizer
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : AppColors.surfaceVariant,
              borderColor: isOrganizer
                  ? AppColors.primary.withValues(alpha: 0.18)
                  : AppColors.outlineVariant,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        author,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (timeAgo?.isNotEmpty == true)
                        Text(
                          timeAgo!,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.navInactive,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarIcon extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  const _AvatarIcon({
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      child: Icon(icon, color: iconColor, size: 17),
    );
  }
}

class _Bubble extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final Color? borderColor;
  final VoidCallback? onTap;

  const _Bubble({
    required this.child,
    this.backgroundColor,
    this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(18);
    final bubble = DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surfaceVariant,
        borderRadius: radius,
        border: Border.all(color: borderColor ?? AppColors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: child,
      ),
    );

    if (onTap == null) return bubble;

    return Semantics(
      button: true,
      label: 'Mở ô trả lời câu hỏi',
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(onTap: onTap, borderRadius: radius, child: bubble),
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
          style: AppTextStyles.labelSmall.copyWith(
            color: onTap == null ? AppColors.navInactive : AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
