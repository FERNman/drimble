import 'floor_date_time.dart';

extension ShiftDateTime on DateTime {
  /// shifts the date to the previous day if it is before 6am
  DateTime shift() => (hour < 6) ? subtract(const Duration(days: 1)).floorToDay() : floorToDay();
}
