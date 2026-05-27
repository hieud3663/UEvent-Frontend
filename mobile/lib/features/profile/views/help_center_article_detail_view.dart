import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/glass_container.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/core/widgets/primary_button.dart';
import 'package:frontend/features/profile/models/help_center_models.dart';

typedef LoadHelpCenterArticle = Future<HelpCenterArticleModel> Function();

class HelpCenterArticleDetailView extends StatefulWidget {
  final HelpCenterArticleModel initialArticle;
  final LoadHelpCenterArticle loadArticle;

  const HelpCenterArticleDetailView({
    super.key,
    required this.initialArticle,
    required this.loadArticle,
  });

  @override
  State<HelpCenterArticleDetailView> createState() =>
      _HelpCenterArticleDetailViewState();
}

class _HelpCenterArticleDetailViewState
    extends State<HelpCenterArticleDetailView> {
  late HelpCenterArticleModel _article = widget.initialArticle;
  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadArticle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 112)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_loading) ...[
                        const LinearProgressIndicator(minHeight: 2),
                        const SizedBox(height: 12),
                      ],
                      if (_errorMessage != null) ...[
                        _ArticleLoadError(
                          message: _errorMessage!,
                          onRetry: _loadArticle,
                        ),
                        const SizedBox(height: 12),
                      ],
                      _ArticleContent(article: _article),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GlassTopBar(
              title: 'Câu hỏi thường gặp',
              leadingIcon: Icons.chevron_left,
              onLeadingTap: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadArticle() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final article = await widget.loadArticle();
      if (!mounted) return;
      setState(() {
        _article = article;
        _loading = false;
      });
    } on DioException catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage =
            error.message ?? 'Không thể tải bài viết. Vui lòng thử lại.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = 'Không thể tải bài viết. Vui lòng thử lại.';
      });
    }
  }
}

class _ArticleContent extends StatelessWidget {
  final HelpCenterArticleModel article;

  const _ArticleContent({required this.article});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(article.title, style: AppTextStyles.titleLarge),
          if (article.summary.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              article.summary,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 20),
          Text(
            article.body,
            style: AppTextStyles.bodyMedium.copyWith(height: 1.55),
          ),
        ],
      ),
    );
  }
}

class _ArticleLoadError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ArticleLoadError({required this.message, required this.onRetry});

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
