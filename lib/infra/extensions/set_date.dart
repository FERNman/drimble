import '../../domain/date.dart';
import 'copy_date_time.dart';

extension SetDate on DateTime {
  DateTime setDate(Date toDate) => copyWith(
        year: toDate.year,
        month: toDate.month,
        day: toDate.day,
      );
}
