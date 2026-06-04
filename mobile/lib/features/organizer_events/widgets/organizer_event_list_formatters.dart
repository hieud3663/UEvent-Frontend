import 'package:intl/intl.dart';

String formatOrganizerEventListDate(DateTime value) {
  return DateFormat('d MMM', 'vi').format(value.toLocal());
}
