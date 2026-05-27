import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/glass_container.dart';
import 'package:frontend/core/widgets/primary_button.dart';
import 'package:frontend/features/profile/models/help_center_models.dart';

class HelpCenterLoading extends StatelessWidget {
  const HelpCenterLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const GlassContainer(
      padding: EdgeInsets.all(24),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class HelpCenterError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const HelpCenterError({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message, style: AppTextStyles.bodyMedium),
          const SizedBox(height: 12),
          SecondaryButton(
            label: 'Thử lại',
            onPressed: onRetry,
            isFullWidth: false,
          ),
        ],
      ),
    );
  }
}

class HelpCenterContent extends StatelessWidget {
  final List<HelpCenterCategoryModel> categories;
  final ValueChanged<HelpCenterArticleModel> onArticleTap;

  const HelpCenterContent({
    super.key,
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
                  HelpCenterArticleTile(
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

class HelpCenterArticleTile extends StatelessWidget {
  final HelpCenterArticleModel article;
  final bool showDivider;
  final VoidCallback onTap;

  const HelpCenterArticleTile({
    super.key,
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

class SupportContactTile extends StatelessWidget {
  final VoidCallback onTap;

  const SupportContactTile({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Liên hệ hỗ trợ',
                      style: AppTextStyles.bodyMedium.copyWith(
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
              const Icon(Icons.chevron_right, color: AppColors.outline),
            ],
          ),
        ),
      ),
    );
  }
}

class SupportTicketList extends StatelessWidget {
  final AsyncValue<List<SupportTicketModel>> ticketsAsync;
  final ValueChanged<SupportTicketModel> onTicketTap;
  final VoidCallback onRetry;

  const SupportTicketList({
    super.key,
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
            SecondaryButton(
              label: 'Thử lại',
              onPressed: onRetry,
              isFullWidth: false,
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
                    SupportTicketTile(
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

class SupportTicketTile extends StatelessWidget {
  final SupportTicketModel ticket;
  final bool showDivider;
  final VoidCallback onTap;

  const SupportTicketTile({
    super.key,
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

class SupportMessageBubble extends StatelessWidget {
  final SupportMessageModel message;

  const SupportMessageBubble({super.key, required this.message});

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
