import 'package:intl/intl.dart';

import 'package:fastotv_dart/commands_info/programme_info.dart';

class TimeParser {
  static const FORMAT_HOUR_MINUTE = 'HH:mm';
  static const FORMAT_HOUR_MINUTE_SEC = 'HH:mm:ss';
  static const FORMAT_DAY_MONTH = 'dd.MM';

  static String formatProgram(ProgrammeInfo program) {
    return date(program.start) + ' / ' + hm(program.start) + ' - ' + hm(program.stop) + ' / ' + program.getDuration();
  }

  static String date(int time) {
    final ts = DateTime.fromMillisecondsSinceEpoch(time);
    return DateFormat(FORMAT_DAY_MONTH).format(ts);
  }

  static String hm(int time) {
    final ts = DateTime.fromMillisecondsSinceEpoch(time);
    return DateFormat(FORMAT_HOUR_MINUTE).format(ts);
  }

  static String hms(int time) {
    final ts = DateTime.fromMillisecondsSinceEpoch(time);
    return DateFormat(FORMAT_HOUR_MINUTE_SEC).format(ts);
  }
}
