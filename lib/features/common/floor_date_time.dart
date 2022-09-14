import 'copy_date_time.dart';

extension FloorDateTime on DateTime {
  DateTime floorToMinute() => copyWith(second: 0, millisecond: 0, microsecond: 0);
}