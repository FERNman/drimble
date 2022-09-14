import 'copy_date_time.dart';

extension FloorDateTime on DateTime {
  DateTime floorToDay() => copyWith(hour: 0, minute: 0).floorToMinute();
  DateTime floorToMinute() => copyWith(second: 0, millisecond: 0, microsecond: 0);
}
