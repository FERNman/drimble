import 'copy_date_time.dart';

extension FloorDateTime on DateTime {
  DateTime floorToDay({int hour = 0}) => copyWith(hour: hour, minute: 0).floorToMinute();
  DateTime floorToMinute() => copyWith(second: 0, millisecond: 0, microsecond: 0);
}
