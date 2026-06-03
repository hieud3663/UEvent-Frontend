// File: lib/features/event_shared/widgets/event_qa_section.dart

import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/widgets/text_action_button.dart';
import 'package:frontend/features/event_shared/models/event_question_model.dart';

typedef EventQuestionReplyCallback =
    Future<bool> Function(EventQuestionModel question, String content);

/// Q&A section: header with "Ask Question" button + list of questions.
class EventQaSection extends StatelessWidget {
  final List<EventQuestionModel> questions;
  final int totalCount;
  final VoidCallback? onAskQuestion;
  final VoidCallback? onViewAll;
  final EventQuestionReplyCallback? onReplyQuestion;

  const EventQaSection({
    super.key,
    required this.questions,
    this.totalCount = 0,
    this.onAskQuestion,
    this.onViewAll,
    this.onReplyQuestion,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Hỏi đáp', style: AppTextStyles.headlineMedium),
            TextActionButton(
              label: 'Đặt câu hỏi',
              onPressed: onAskQuestion,
              foregroundColor: AppColors.primary,
              textStyle: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Question tiles
        if (questions.isEmpty)
          Text(
            'Chưa có câu hỏi public nào.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          )
        else
          ...questions.map(
            (q) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _QuestionTile(
                question: q,
                onReplyQuestion: onReplyQuestion,
              ),
            ),
          ),
        // View All button
        if (totalCount > questions.length)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.outlineVariant)),
            ),
            child: Center(
              child: TextActionButton(
                label: 'Xem tất cả $totalCount câu hỏi',
                onPressed: onViewAll,
                foregroundColor: AppColors.onSurfaceVariant,
                textStyle: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _QuestionTile extends StatefulWidget {
  final EventQuestionModel question;
  final EventQuestionReplyCallback? onReplyQuestion;

  const _QuestionTile({required this.question, this.onReplyQuestion});

  @override
  State<_QuestionTile> createState() => _QuestionTileState();
}

class _QuestionTileState extends State<_QuestionTile> {
  late final TextEditingController _replyController;
  bool _isReplying = false;
  bool _isSubmitting = false;
  bool _showAllReplies = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _replyController = TextEditingController();
  }

  @override
  void didUpdateWidget(covariant _QuestionTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      _replyController.clear();
      _isReplying = false;
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
    final canReply = widget.onReplyQuestion != null;
    final replyWidgets = _buildReplyWidgets(question, canReply: canReply);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: canReply ? _startReply : null,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.help_outline, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      question.question,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (canReply)
                _InlineAction(
                  label: 'Trả lời',
                  onTap: _isSubmitting ? null : _startReply,
                ),
              if (question.timeAgo?.isNotEmpty == true)
                Text(
                  question.timeAgo!,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.65),
                  ),
                ),
            ],
          ),
          if (replyWidgets.isNotEmpty)
            _ReplyPreviewList(
              replies: replyWidgets,
              showAll: _showAllReplies,
              onToggle: () =>
                  setState(() => _showAllReplies = !_showAllReplies),
            ),
          if (!question.isAnswered && !_isReplying) ...[
            const SizedBox(height: 8),
            Text(
              'Chưa có trả lời.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
          if (_isReplying) ...[const SizedBox(height: 10), _buildReplyEditor()],
        ],
      ),
    );
  }

  List<Widget> _buildReplyWidgets(
    EventQuestionModel question, {
    required bool canReply,
  }) {
    return [
      if (question.answer?.isNotEmpty == true)
        _ReplyBlock(
          author: question.answeredBy ?? 'BTC',
          content: question.answer!,
          isOrganizer: true,
          timeAgo: question.timeAgo,
          onTap: canReply ? _startReply : null,
        ),
      ...question.replies.map(
        (reply) => _ReplyBlock(
          author: reply.authorName,
          content: reply.content,
          isOrganizer: reply.isOrganizerReply,
          timeAgo: reply.timeAgo,
          onTap: canReply ? _startReply : null,
        ),
      ),
    ];
  }

  void _startReply() {
    if (_isSubmitting) return;
    setState(() {
      _isReplying = true;
      _errorMessage = null;
    });
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
            hintText: 'Viết phản hồi...',
            filled: true,
            fillColor: Colors.white,
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
                      _isReplying = false;
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
      setState(() => _errorMessage = 'Vui lòng nhập phản hồi.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final ok = await widget.onReplyQuestion?.call(widget.question, content);
    if (!mounted) return;

    if (ok != true) {
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'Không gửi được phản hồi. Vui lòng thử lại.';
      });
      return;
    }

    setState(() {
      _isSubmitting = false;
      _isReplying = false;
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

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasHiddenReplies)
            _InlineAction(
              label: showAll
                  ? 'Thu gọn phản hồi'
                  : 'Xem $hiddenCount phản hồi trước',
              onTap: onToggle,
            ),
          if (hasHiddenReplies && showAll) ...[
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 180),
              child: SingleChildScrollView(child: list),
            ),
          ] else
            list,
        ],
      ),
    );
  }

  List<Widget> _withSpacing(List<Widget> items) {
    return [
      for (var i = 0; i < items.length; i++) ...[
        if (i > 0) const SizedBox(height: 10),
        items[i],
      ],
    ];
  }
}

class _ReplyBlock extends StatelessWidget {
  final String author;
  final String content;
  final bool isOrganizer;
  final String? timeAgo;
  final VoidCallback? onTap;

  const _ReplyBlock({
    required this.author,
    required this.content,
    required this.isOrganizer,
    this.timeAgo,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = isOrganizer ? AppColors.primary : AppColors.onSurfaceVariant;

    final contentBlock = Container(
      padding: const EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: isOrganizer ? AppColors.primary : AppColors.outline,
            width: 2,
          ),
        ),
      ),
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
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 24),
        Expanded(
          child: onTap == null
              ? contentBlock
              : Semantics(
                  button: true,
                  label: 'Mở ô trả lời phản hồi',
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onTap,
                      borderRadius: BorderRadius.circular(8),
                      child: contentBlock,
                    ),
                  ),
                ),
        ),
      ],
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
            color: onTap == null
                ? AppColors.onSurfaceVariant
                : AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
