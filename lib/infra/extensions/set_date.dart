import 'copy_date_time.dart';

extension SetDate on DateTime {
  DateTime setDate(DateTime toDate) => copyWith(
        year: toDate.year,
        month: toDate.month,
        day: toDate.day,
      );
}
