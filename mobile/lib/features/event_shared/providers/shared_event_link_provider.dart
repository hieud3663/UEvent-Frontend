import 'package:flutter_riverpod/flutter_riverpod.dart';

final sharedEventSlugProvider =
    NotifierProvider<SharedEventSlugNotifier, String?>(
      SharedEventSlugNotifier.new,
    );

class SharedEventSlugNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setSlug(String slug) {
    state = slug;
  }

  void clear() {
    state = null;
  }
}
