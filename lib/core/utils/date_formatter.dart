import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _indonesianFull = DateFormat('dd MMMM yyyy, HH:mm:ss', 'id_ID');
  static final DateFormat _indonesianDateOnly = DateFormat('dd MMMM yyyy', 'id_ID');
  static final DateFormat _timeOnly = DateFormat('HH:mm:ss');
  static final DateFormat _shortTime = DateFormat('HH:mm');
  static final DateFormat _chartTime = DateFormat('HH:mm');
  static final DateFormat _chartDate = DateFormat('dd/MM');

  static String formatFull(DateTime dateTime) {
    try {
      return '${_indonesianFull.format(dateTime)} WIB';
    } catch (_) {
      return DateFormat('dd MMM yyyy, HH:mm:ss').format(dateTime);
    }
  }

  static String formatDateOnly(DateTime dateTime) {
    try {
      return _indonesianDateOnly.format(dateTime);
    } catch (_) {
      return DateFormat('dd MMM yyyy').format(dateTime);
    }
  }

  static String formatTime(DateTime dateTime) {
    return _timeOnly.format(dateTime);
  }

  static String formatShortTime(DateTime dateTime) {
    return _shortTime.format(dateTime);
  }

  static String formatChartTime(DateTime dateTime) {
    return _chartTime.format(dateTime);
  }

  static String formatChartDate(DateTime dateTime) {
    return _chartDate.format(dateTime);
  }

  static String timeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inSeconds < 5) {
      return 'Baru saja';
    } else if (difference.inSeconds < 60) {
      return '${difference.inSeconds} detik lalu';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else {
      return formatDateOnly(dateTime);
    }
  }
}
