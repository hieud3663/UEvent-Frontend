import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/text_action_button.dart';

class DiscoveryPagingFooter extends StatelessWidget {
  final bool hasMore;
  final bool isLoadingMore;
  final bool hasError;
  final VoidCallback onRetry;

  const DiscoveryPagingFooter({
    super.key,
    required this.hasMore,
    required this.isLoadingMore,
    required this.hasError,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (hasError) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: TextActionButton(label: 'Thử lại', onPressed: onRetry),
        ),
      );
    }

    if (!hasMore) {
      return const SizedBox(height: 8);
    }

    return const SizedBox(height: 24);
  }
}
