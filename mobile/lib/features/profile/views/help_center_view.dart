import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/app_snack_bar.dart';
import 'package:frontend/core/widgets/glass_container.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/features/profile/models/help_center_models.dart';
import 'package:frontend/features/profile/providers/profile_providers.dart';

class HelpCenterView extends ConsumerStatefulWidget {
  final VoidCallback? onBack;

  const HelpCenterView({super.key, this.onBack});

  @override
  ConsumerState<HelpCenterView> createState() => _HelpCenterViewState();
}

class _HelpCenterViewState extends ConsumerState<HelpCenterView> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final helpCenterAsync = ref.watch(helpCenterProvider(locale));
    final supportTicketsAsync = ref.watch(supportTicketsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(helpCenterProvider(locale));
              ref.invalidate(supportTicketsProvider);
              await ref.read(helpCenterProvider(locale).future);
              await ref.read(supportTicketsProvider.future);
            },
            child: CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        Text(
                          'Chúng tôi có thể giúp gì?',
                          style: AppTextStyles.headlineLarge,
                        ),
                        const SizedBox(height: 24),
                        _SearchField(
                          onChanged: (value) => setState(() => _query = value),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'CÂU HỎI THƯỜNG GẶP',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.onSurfaceVariant.withValues(
                              alpha: 0.6,
                            ),
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        helpCenterAsync.when(
                          loading: () => const _HelpCenterLoading(),
                          error: (error, _) => _HelpCenterError(
                            message: _errorMessage(error),
                            onRetry: () =>
                                ref.invalidate(helpCenterProvider(locale)),
                          ),
                          data: (categories) => _HelpCenterContent(
                            categories: _filterCategories(categories),
                            onArticleTap: (article) =>
                                _openArticle(context, locale, article),
                          ),
                        ),
                        const SizedBox(height: 48),
                        Text(
                          'VẪN CẦN HỖ TRỢ?',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.onSurfaceVariant.withValues(
                              alpha: 0.6,
                            ),
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => _openSupportTicketSheet(context),
                          child: GlassContainer(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.support_agent,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Liên hệ hỗ trợ',
                                        style: AppTextStyles.bodyMedium
                                            .copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      Text(
                                        'Gửi ticket hỗ trợ đến đội vận hành.',
                                        style: AppTextStyles.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right,
                                  color: AppColors.outline,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _SupportTicketList(
                          ticketsAsync: supportTicketsAsync,
                          onTicketTap: (ticket) =>
                              _openSupportTicketDetail(context, ticket),
                          onRetry: () => ref.invalidate(supportTicketsProvider),
                        ),
                        const SizedBox(height: 40),
                      ],
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
              title: 'Trung tâm hỗ trợ',
              leadingIcon: Icons.chevron_left,
              onLeadingTap: widget.onBack,
            ),
          ),
        ],
      ),
    );
  }

  List<HelpCenterCategoryModel> _filterCategories(
    List<HelpCenterCategoryModel> categories,
  ) {
    final normalizedQuery = _query.trim();
    if (normalizedQuery.isEmpty) return categories;

    return categories
        .map((category) => category.filter(normalizedQuery))
        .where((category) => category.articles.isNotEmpty)
        .toList(growable: false);
  }

  Future<void> _openArticle(
    BuildContext context,
    String locale,
    HelpCenterArticleModel article,
  ) async {
    try {
      final detail = await ref
          .read(helpCenterServiceProvider)
          .getArticle(slug: article.slug, locale: locale);
      if (!context.mounted) return;

      await showModalBottomSheet<void>(
        context: context,
        backgroundColor: AppColors.surface,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (context) => _ArticleSheet(article: detail),
      );
    } on DioException catch (error) {
      if (context.mounted) showAppSnackBar(context, _errorMessage(error));
    } catch (_) {
      if (context.mounted) {
        showAppSnackBar(
          context,
          'Không thể tải bài viết hỗ trợ. Vui lòng thử lại.',
        );
      }
    }
  }

  Future<void> _openSupportTicketSheet(BuildContext context) async {
    final ticket = await showModalBottomSheet<SupportTicketModel>(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => _SupportTicketSheet(
        onSubmit: (subject, description) => ref
            .read(helpCenterServiceProvider)
            .createSupportTicket(subject: subject, description: description),
      ),
    );

    if (!context.mounted || ticket == null) return;
    ref.invalidate(supportTicketsProvider);
    showAppSnackBar(context, 'Đã gửi yêu cầu hỗ trợ.');
  }

  Future<void> _openSupportTicketDetail(
    BuildContext context,
    SupportTicketModel ticket,
  ) async {
    try {
      final detail = await ref
          .read(helpCenterServiceProvider)
          .getSupportTicket(ticket.id);
      if (!context.mounted) return;

      await showModalBottomSheet<void>(
        context: context,
        backgroundColor: AppColors.surface,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (context) => _SupportTicketDetailSheet(
          ticket: detail,
          onReply: (content) => ref
              .read(helpCenterServiceProvider)
              .addSupportTicketMessage(ticketId: detail.id, content: content),
        ),
      );
      ref.invalidate(supportTicketsProvider);
    } on DioException catch (error) {
      if (context.mounted) showAppSnackBar(context, _errorMessage(error));
    } catch (_) {
      if (context.mounted) {
        showAppSnackBar(
          context,
          'Không thể tải yêu cầu hỗ trợ. Vui lòng thử lại.',
        );
      }
    }
  }

  String _errorMessage(Object error) {
    if (error is DioException) {
      final message = error.message?.trim();
      if (message != null && message.isNotEmpty) return message;
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return 'Không thể kết nối máy chủ. Vui lòng kiểm tra mạng và thử lại.';
      }
    }
    return 'Không thể tải Trung tâm hỗ trợ. Vui lòng thử lại.';
  }
}

class _SearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const _SearchField({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Icon(Icons.search, color: AppColors.outline),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  onChanged: onChanged,
                  decoration: InputDecoration(
                    hintText: 'Tìm câu trả lời...',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.outline,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HelpCenterLoading extends StatelessWidget {
  const _HelpCenterLoading();

  @override
  Widget build(BuildContext context) {
    return const GlassContainer(
      padding: EdgeInsets.all(24),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _HelpCenterError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _HelpCenterError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message, style: AppTextStyles.bodyMedium),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}

class _HelpCenterContent extends StatelessWidget {
  final List<HelpCenterCategoryModel> categories;
  final ValueChanged<HelpCenterArticleModel> onArticleTap;

  const _HelpCenterContent({
    required this.categories,
    required this.onArticleTap,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return GlassContainer(
        padding: const EdgeInsets.all(20),
        child: Text(
          'Không tìm thấy nội dung hỗ trợ phù hợp.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      );
    }

    return Column(
      children: [
        for (final category in categories) ...[
          GlassContainer(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    category.name,
                    style: AppTextStyles.titleSmall.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                for (var index = 0; index < category.articles.length; index++)
                  _ArticleTile(
                    article: category.articles[index],
                    showDivider: index != category.articles.length - 1,
                    onTap: () => onArticleTap(category.articles[index]),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _ArticleTile extends StatelessWidget {
  final HelpCenterArticleModel article;
  final bool showDivider;
  final VoidCallback onTap;

  const _ArticleTile({
    required this.article,
    required this.showDivider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          title: Text(article.title, style: AppTextStyles.bodyMedium),
          subtitle: article.summary.trim().isEmpty
              ? null
              : Text(article.summary, style: AppTextStyles.bodySmall),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppColors.outline,
          ),
        ),
        if (showDivider)
          Divider(height: 1, color: Colors.black.withValues(alpha: 0.05)),
      ],
    );
  }
}

class _SupportTicketList extends StatelessWidget {
  final AsyncValue<List<SupportTicketModel>> ticketsAsync;
  final ValueChanged<SupportTicketModel> onTicketTap;
  final VoidCallback onRetry;

  const _SupportTicketList({
    required this.ticketsAsync,
    required this.onTicketTap,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ticketsAsync.when(
      loading: () => const GlassContainer(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => GlassContainer(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chưa thể tải các yêu cầu đã gửi.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
      data: (tickets) {
        if (tickets.isEmpty) {
          return GlassContainer(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Các yêu cầu hỗ trợ đã gửi sẽ hiển thị tại đây.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'YÊU CẦU ĐÃ GỬI',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            GlassContainer(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (var index = 0; index < tickets.length; index++)
                    _SupportTicketTile(
                      ticket: tickets[index],
                      showDivider: index != tickets.length - 1,
                      onTap: () => onTicketTap(tickets[index]),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SupportTicketTile extends StatelessWidget {
  final SupportTicketModel ticket;
  final bool showDivider;
  final VoidCallback onTap;

  const _SupportTicketTile({
    required this.ticket,
    required this.showDivider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final lastMessage = ticket.messages.isEmpty ? null : ticket.messages.last;

    return Column(
      children: [
        ListTile(
          onTap: onTap,
          title: Text(ticket.subject, style: AppTextStyles.bodyMedium),
          subtitle: Text(
            lastMessage == null
                ? ticket.description
                : '${lastMessage.isStaff ? 'Admin' : 'Bạn'}: ${lastMessage.content}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmall,
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                ticket.statusLabel,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              const Icon(
                Icons.chevron_right,
                size: 18,
                color: AppColors.outline,
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(height: 1, color: Colors.black.withValues(alpha: 0.05)),
      ],
    );
  }
}

typedef _SubmitSupportTicket =
    Future<SupportTicketModel> Function(String subject, String description);
typedef _SubmitSupportTicketReply =
    Future<SupportTicketModel> Function(String content);

class _SupportTicketSheet extends StatefulWidget {
  final _SubmitSupportTicket onSubmit;

  const _SupportTicketSheet({required this.onSubmit});

  @override
  State<_SupportTicketSheet> createState() => _SupportTicketSheetState();
}

class _SupportTicketSheetState extends State<_SupportTicketSheet> {
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          8,
          24,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Liên hệ hỗ trợ', style: AppTextStyles.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Mô tả ngắn gọn vấn đề để đội vận hành có thể phản hồi.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _subjectController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Tiêu đề',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              minLines: 4,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Nội dung',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Gửi yêu cầu hỗ trợ'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final subject = _subjectController.text.trim();
    final description = _descriptionController.text.trim();

    if (subject.isEmpty || description.isEmpty) {
      showAppSnackBar(context, 'Vui lòng nhập tiêu đề và nội dung.');
      return;
    }

    setState(() => _submitting = true);
    try {
      final ticket = await widget.onSubmit(subject, description);
      if (mounted) Navigator.of(context).pop(ticket);
    } on DioException catch (error) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        error.message ?? 'Không thể gửi yêu cầu hỗ trợ. Vui lòng thử lại.',
      );
    } catch (_) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        'Không thể gửi yêu cầu hỗ trợ. Vui lòng thử lại.',
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}

class _SupportTicketDetailSheet extends StatefulWidget {
  final SupportTicketModel ticket;
  final _SubmitSupportTicketReply onReply;

  const _SupportTicketDetailSheet({
    required this.ticket,
    required this.onReply,
  });

  @override
  State<_SupportTicketDetailSheet> createState() =>
      _SupportTicketDetailSheetState();
}

class _SupportTicketDetailSheetState extends State<_SupportTicketDetailSheet> {
  final _replyController = TextEditingController();
  late SupportTicketModel _ticket = widget.ticket;
  bool _submitting = false;

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.85;

    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        height: maxHeight,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            8,
            24,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                          'Chưa có phản hồi trong yêu cầu này.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _ticket.messages.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) => _SupportMessageBubble(
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
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _submitReply,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Gửi phản hồi'),
                  ),
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
      ),
    );
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

class _SupportMessageBubble extends StatelessWidget {
  final SupportMessageModel message;

  const _SupportMessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final alignment = message.isStaff
        ? CrossAxisAlignment.start
        : CrossAxisAlignment.end;
    final color = message.isStaff
        ? AppColors.surfaceVariant.withValues(alpha: 0.8)
        : AppColors.primary.withValues(alpha: 0.12);

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          message.isStaff ? 'Admin' : 'Bạn',
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.78,
          ),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(message.content, style: AppTextStyles.bodyMedium),
        ),
      ],
    );
  }
}

class _ArticleSheet extends StatelessWidget {
  final HelpCenterArticleModel article;

  const _ArticleSheet({required this.article});

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.85;

    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        height: maxHeight,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            8,
            24,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(article.title, style: AppTextStyles.titleLarge),
                if (article.summary.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(article.summary, style: AppTextStyles.bodyMedium),
                ],
                const SizedBox(height: 20),
                Text(article.body, style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
