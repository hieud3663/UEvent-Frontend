import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/widgets/async_state_widgets.dart';

class AppLoadingSliver extends StatelessWidget {
  final double height;
  final EdgeInsetsGeometry padding;
  final Widget? indicator;

  const AppLoadingSliver({
    super.key,
    this.height = 120,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppConstants.pagePaddingH,
    ),
    this.indicator,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: AppLoadingState(
        height: height,
        padding: padding,
        indicator: indicator,
      ),
    );
  }
}

class AppErrorSliver extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback? onRetry;
  final String retryText;
  final EdgeInsetsGeometry padding;
  final bool fillRemaining;

  const AppErrorSliver({
    super.key,
    this.icon = Icons.error_outline,
    required this.title,
    required this.description,
    this.onRetry,
    this.retryText = 'Thử lại',
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppConstants.pagePaddingH,
    ),
    this.fillRemaining = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = AppErrorState(
      icon: icon,
      title: title,
      description: description,
      onRetry: onRetry,
      retryText: retryText,
      padding: padding,
    );

    if (fillRemaining) {
      return SliverFillRemaining(child: Center(child: content));
    }

    return SliverToBoxAdapter(child: content);
  }
}

class AppSuccessSliver extends StatelessWidget {
  final bool isEmpty;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptyDescription;
  final List<Widget> contentSlivers;
  final EdgeInsetsGeometry emptyPadding;
  final bool emptyFillRemaining;

  const AppSuccessSliver({
    super.key,
    required this.isEmpty,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptyDescription,
    required this.contentSlivers,
    this.emptyPadding = const EdgeInsets.symmetric(
      horizontal: AppConstants.pagePaddingH,
    ),
    this.emptyFillRemaining = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isEmpty && emptyFillRemaining) {
      return SliverFillRemaining(
        child: Center(
          child: AppSuccessState(
            isEmpty: true,
            emptyIcon: emptyIcon,
            emptyTitle: emptyTitle,
            emptyDescription: emptyDescription,
            emptyPadding: emptyPadding,
            child: const SizedBox.shrink(),
          ),
        ),
      );
    }

    if (isEmpty) {
      return SliverToBoxAdapter(
        child: AppSuccessState(
          isEmpty: true,
          emptyIcon: emptyIcon,
          emptyTitle: emptyTitle,
          emptyDescription: emptyDescription,
          emptyPadding: emptyPadding,
          child: const SizedBox.shrink(),
        ),
      );
    }

    // `SliverMainAxisGroup` requires Flutter 3.16+.
    // If supporting older Flutter versions, replace this with a compatible sliver composition.
    return SliverMainAxisGroup(slivers: contentSlivers);
  }
}
