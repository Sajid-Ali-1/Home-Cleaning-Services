import 'package:intl/intl.dart';

class BookingSlot {
  BookingSlot({required this.start});

  final DateTime start;

  String get dayLabel => DateFormat('EEEE, MMM d').format(start);

  String get timeLabel => DateFormat('h:mm a').format(start);
}
