import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _formatter = DateFormat('yyyy.MM.dd');

  static String format(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return _formatter.format(date);
    } catch (e) {
      return dateString;
    }
  }
} 