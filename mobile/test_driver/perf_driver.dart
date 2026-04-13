import 'package:flutter_driver/flutter_driver.dart' as driver;
import 'package:integration_test/integration_test_driver.dart';

Future<void> main() {
  return integrationDriver(
    responseDataCallback: (data) async {
      if (data != null) {
        final rawTimeline =
            data['scrolling_timeline'] ??
            (data['data'] as Object?)?.let((value) {
              if (value is Map) {
                return value['scrolling_timeline'];
              }
              return null;
            }) ??
            (data['message'] as Object?)?.let((value) {
              if (value is Map) {
                final nestedData = value['data'];
                if (nestedData is Map) {
                  return nestedData['scrolling_timeline'];
                }
              }
              return null;
            });

        if (rawTimeline is! Map) {
          return;
        }

        final timeline = driver.Timeline.fromJson(
          Map<String, dynamic>.from(rawTimeline),
        );
        final summary = driver.TimelineSummary.summarize(timeline);
        await summary.writeTimelineToFile(
          'scrolling_timeline',
          pretty: true,
          includeSummary: true,
        );
      }
    },
  );
}

extension on Object? {
  T? let<T>(T? Function(Object?) mapper) => mapper(this);
}
