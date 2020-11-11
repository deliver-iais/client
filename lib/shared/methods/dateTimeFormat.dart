import 'package:date_time_format/date_time_format.dart';

extension ToText on DateTime {
  String dateTimeFormat() {
    var now = DateTime.now();
    var difference = now.difference(this);
    if (difference.inMinutes <= 2) {
      return "just now";
    } else if (difference.inDays < 1 && this.day == now.day) {
      return DateTimeFormat.format(this, format: 'H:i');
    } else if (difference.inDays <= 7)
      return DateTimeFormat.format(this, format: 'D');
    else
      return DateTimeFormat.format(this, format: 'M j');
    return '';
  }
}
