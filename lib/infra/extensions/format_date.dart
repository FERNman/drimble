import 'package:intl/intl.dart';

import '../../domain/date.dart';

extension DateFormatting on DateFormat {
  String formatDate(Date date) => format(date.toLocalDateTime());
}
