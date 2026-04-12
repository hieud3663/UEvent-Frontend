import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/widgets/empty_state_view.dart';

class AppLoadingState extends StatelessWidget {
  final double height;
  final EdgeInsetsGeometry padding;
  final Widget? indicator;

  const AppLoadingState({
    super.key,
    this.height = 120,
    this.padding = const EdgeInsets.symmetric(horizontal: AppConstants.pagePaddingH),
    this.indicator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: SizedBox(
        height: height,
        child: Center(child: indicator ?? const CircularProgressIndicator()),
      ),
    );
  }
}

class AppErrorState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback? onRetry;
  final String retryText;
  final EdgeInsetsGeometry padding;

  const AppErrorState({
    super.key,
    this.icon = Icons.error_outline,
    required this.title,
    required this.description,
    this.onRetry,
    this.retryText = 'Thu lai',
    this.padding = const EdgeInsets.symmetric(horizontal: AppConstants.pagePaddingH),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: EmptyStateView(
        icon: icon,
        title: title,
        description: description,
        primaryAction: onRetry == null
            ? null
            : TextButton(
                onPressed: onRetry,
                child: Text(retryText),
              ),
      ),
    );
  }
}

class AppSuccessState extends StatelessWidget {
  final bool isEmpty;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptyDescription;
  final Widget child;
  final EdgeInsetsGeometry emptyPadding;

  const AppSuccessState({
    super.key,
    required this.isEmpty,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptyDescription,
    required this.child,
    this.emptyPadding = const EdgeInsets.symmetric(horizontal: AppConstants.pagePaddingH),
  });

  @override
  Widget build(BuildContext context) {
    if (isEmpty) {
      return Padding(
        padding: emptyPadding,
        child: EmptyStateView(
          icon: emptyIcon,
          title: emptyTitle,
          description: emptyDescription,
        ),
      );
    }

    return child;
  }
}