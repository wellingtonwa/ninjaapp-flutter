import 'package:intl/intl.dart';

class TimeUtil {
  static DateFormat br = DateFormat('dd/MM/y');
  static DateFormat us = DateFormat('y-MM-dd');
  static DateFormat brTime = DateFormat('dd/MM/yyyy HH:mm:ss');
  static DateFormat onlyTime = DateFormat('HH:mm');
  static DateFormat brSmallDate = DateFormat('HH:mm dd/MM');

  static int toMinutes(String time) {
    final timeSplit = time.split(':');
    return (int.parse(timeSplit[0]) * 60) + int.parse(timeSplit[1]);
  }

  static String fromMinutes(int minutes) {
    int m = minutes % 60;
    int h = (minutes - m) ~/ 60;

    String padM = "$m".padLeft(2, '0');
    String padH = "$h".padLeft(2, '0');

    return "$padH:$padM";
  }

  static String dbDateToString(String dbDate, {DateFormat? format}) {
    return (format ?? br).format(DateTime.parse(dbDate));
  }

  static DateTime atStartOfDay([DateTime? date]) {
    return (date ?? DateTime.now()).copyWith(
      hour: 0,
      minute: 0,
      second: 0,
      millisecond: 0,
      microsecond: 0,
    );
  }

  static DateTime atEndOfDay([DateTime? date]) {
    return (date ?? DateTime.now()).copyWith(
      hour: 23,
      minute: 59,
      second: 59,
      millisecond: 999,
      microsecond: 999,
    );
  }
}
