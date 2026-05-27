import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/app_snack_bar.dart';
import 'package:frontend/core/widgets/glass_container.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/core/widgets/primary_button.dart';
import 'package:frontend/features/profile/models/help_center_models.dart';
import 'package:frontend/features/profile/widgets/help_center_widgets.dart';

typedef LoadSupportTicket = Future<SupportTicketModel> Function();
typedef SubmitSupportTicketReply =
    Future<SupportTicketModel> Function(String content);

class SupportTicketDetailView extends StatefulWidget {
  final SupportTicketModel initialTicket;
  final LoadSupportTicket loadTicket;
  final SubmitSupportTicketReply onReply;

  const SupportTicketDetailView({
    super.key,
    required this.initialTicket,
    required this.loadTicket,
    required this.onReply,
  });

  @override
  State<SupportTicketDetailView> createState() =>
      _SupportTicketDetailViewState();
}

class _SupportTicketDetailViewState extends State<SupportTicketDetailView> {
  final _replyController = TextEditingController();
  late SupportTicketModel _ticket = widget.initialTicket;
  bool _loading = true;
  bool _submitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTicket();
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 112, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_loading) ...[
                  const LinearProgressIndicator(minHeight: 2),
                  const SizedBox(height: 12),
                ],
                if (_errorMessage != null) ...[
                  _TicketLoadError(
                    message: _errorMessage!,
                    onRetry: _loadTicket,
                  ),
                  const SizedBox(height: 12),
                ],
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _ticket.subject,
                        style: AppTextStyles.titleLarge,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _ticket.statusLabel,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _ticket.description,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: _ticket.messages.isEmpty
                      ? Center(
                          child: Text(
                            _loading
                                ? 'Đang tải phản hồi...'
                                : 'Chưa có phản hồi trong yêu cầu này.',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: _ticket.messages.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) => SupportMessageBubble(
                            message: _ticket.messages[index],
                          ),
                        ),
                ),
                const SizedBox(height: 16),
                if (_ticket.canReply) ...[
                  TextField(
                    controller: _replyController,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Phản hồi thêm',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    label: 'Gửi phản hồi',
                    isLoading: _submitting,
                    onPressed: _submitting ? null : _submitReply,
                  ),
                ] else
                  GlassContainer(
                    padding: const EdgeInsets.all(14),
                    child: Text(
                      'Yêu cầu này đã được xử lý nên không thể phản hồi thêm.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GlassTopBar(
              title: 'Yêu cầu hỗ trợ',
              leadingIcon: Icons.chevron_left,
              onLeadingTap: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadTicket() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final ticket = await widget.loadTicket();
      if (!mounted) return;
      setState(() {
        _ticket = ticket;
        _loading = false;
      });
    } on DioException catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage =
            error.message ?? 'Không thể tải yêu cầu hỗ trợ. Vui lòng thử lại.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = 'Không thể tải yêu cầu hỗ trợ. Vui lòng thử lại.';
      });
    }
  }

  Future<void> _submitReply() async {
    final content = _replyController.text.trim();
    if (content.isEmpty) {
      showAppSnackBar(context, 'Vui lòng nhập nội dung phản hồi.');
      return;
    }

    setState(() => _submitting = true);
    try {
      final ticket = await widget.onReply(content);
      if (!mounted) return;
      setState(() {
        _ticket = ticket;
        _replyController.clear();
      });
    } on DioException catch (error) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        error.message ?? 'Không thể gửi phản hồi. Vui lòng thử lại.',
      );
    } catch (_) {
      if (!mounted) return;
      showAppSnackBar(context, 'Không thể gửi phản hồi. Vui lòng thử lại.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}

class _TicketLoadError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _TicketLoadError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          SecondaryButton(
            label: 'Thử lại',
            isFullWidth: false,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
