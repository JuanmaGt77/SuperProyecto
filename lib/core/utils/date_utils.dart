import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class AppDateUtils {
  AppDateUtils._();

  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _timeFormat = DateFormat('hh:mm a');
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy hh:mm a');
  static final DateFormat _dayMonth = DateFormat('d MMM', 'es');
  static final DateFormat _fullDate = DateFormat('EEEE d MMMM yyyy', 'es');

  static String formatDate(DateTime date) => _dateFormat.format(date);
  static String formatTime(DateTime date) => _timeFormat.format(date);
  static String formatDateTime(DateTime date) => _dateTimeFormat.format(date);
  static String formatDayMonth(DateTime date) => _dayMonth.format(date);
  static String formatFull(DateTime date) => _fullDate.format(date);

  static String timeAgo(DateTime date) {
    timeago.setLocaleMessages('es', timeago.EsMessages());
    return timeago.format(date, locale: 'es');
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  static String smartFormat(DateTime date) {
    if (isToday(date)) return formatTime(date);
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    if (diff < 7) return timeAgo(date);
    return formatDate(date);
  }
}
