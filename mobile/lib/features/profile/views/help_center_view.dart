import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/app_snack_bar.dart';
import 'package:frontend/core/widgets/glass_search_bar.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/features/profile/models/help_center_models.dart';
import 'package:frontend/features/profile/providers/profile_providers.dart';
import 'package:frontend/features/profile/views/help_center_article_detail_view.dart';
import 'package:frontend/features/profile/views/support_ticket_create_view.dart';
import 'package:frontend/features/profile/views/support_ticket_detail_view.dart';
import 'package:frontend/features/profile/widgets/help_center_widgets.dart';

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
                        GlassSearchBar(
                          placeholder: 'Tìm câu trả lời...',
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
                          loading: () => const HelpCenterLoading(),
                          error: (error, _) => HelpCenterError(
                            message: _errorMessage(error),
                            onRetry: () =>
                                ref.invalidate(helpCenterProvider(locale)),
                          ),
                          data: (categories) => HelpCenterContent(
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
                        SupportContactTile(
                          onTap: () => _openSupportTicketCreateView(context),
                        ),
                        const SizedBox(height: 24),
                        SupportTicketList(
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
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (context) => HelpCenterArticleDetailView(
          initialArticle: article,
          loadArticle: () => ref
              .read(helpCenterServiceProvider)
              .getArticle(slug: article.slug, locale: locale),
        ),
      ),
    );
  }

  Future<void> _openSupportTicketCreateView(BuildContext context) async {
    final ticket = await Navigator.of(context).push<SupportTicketModel>(
      MaterialPageRoute(
        builder: (context) => SupportTicketCreateView(
          onSubmit: (subject, description) => ref
              .read(helpCenterServiceProvider)
              .createSupportTicket(subject: subject, description: description),
        ),
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
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (context) => SupportTicketDetailView(
          initialTicket: ticket,
          loadTicket: () =>
              ref.read(helpCenterServiceProvider).getSupportTicket(ticket.id),
          onReply: (content) => ref
              .read(helpCenterServiceProvider)
              .addSupportTicketMessage(ticketId: ticket.id, content: content),
        ),
      ),
    );
    ref.invalidate(supportTicketsProvider);
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
