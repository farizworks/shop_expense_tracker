import 'package:intl/intl.dart';
import 'constants.dart';

class DateFormatter {
  static String formatForDisplay(DateTime date) {
    return DateFormat(AppConstants.dateFormatDisplay).format(date);
  }

  static String formatForDatabase(DateTime date) {
    return DateFormat(AppConstants.dateFormatDatabase).format(date);
  }

  static String formatDateTimeForDisplay(DateTime dateTime) {
    return DateFormat(AppConstants.dateTimeFormatDisplay).format(dateTime);
  }

  static DateTime parseFromDatabase(String dateString) {
    return DateFormat(AppConstants.dateFormatDatabase).parse(dateString);
  }

  static String getCurrentDateForDatabase() {
    return formatForDatabase(DateTime.now());
  }

  static DateTime getToday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  static String getRelativeDateString(DateTime date) {
    final today = getToday();
    final yesterday = today.subtract(const Duration(days: 1));

    if (isSameDay(date, today)) {
      return 'Today';
    } else if (isSameDay(date, yesterday)) {
      return 'Yesterday';
    } else {
      return formatForDisplay(date);
    }
  }
}
