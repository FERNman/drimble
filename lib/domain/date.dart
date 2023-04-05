/// Represents a date without time information.
class Date {
  final int year;
  final int month;
  final int day;

  int get weekday => toLocalDateTime().weekday;

  const Date(this.year, this.month, this.day);

  Date.today() : this.fromDateTime(DateTime.now());

  Date.fromDateTime(DateTime dateTime)
      : year = dateTime.year,
        month = dateTime.month,
        day = dateTime.day;

  Date add({required int days}) {
    final dateTime = toLocalDateTime().add(Duration(days: days));
    return Date.fromDateTime(dateTime);
  }

  Date subtract({required int days}) {
    final dateTime = toLocalDateTime().subtract(Duration(days: days));
    return Date.fromDateTime(dateTime);
  }

  bool isAfter(Date other) => toLocalDateTime().isAfter(other.toLocalDateTime());

  @override
  operator ==(Object other) => other is Date && other.year == year && other.month == month && other.day == day;

  @override
  int get hashCode => year.hashCode ^ month.hashCode ^ day.hashCode;
}

extension DateTimeExtensions on Date {
  DateTime toShiftedDateTime() => DateTime(year, month, day, 6);
  DateTime toLocalDateTime() => DateTime(year, month, day);
  DateTime toUtcDateTime() => DateTime.utc(year, month, day);
}

extension DateExtensions on DateTime {
  /// shifts the date to the previous day if it is before 6am
  Date toDate() => (hour < 6) ? subtract(const Duration(days: 1))._toDate() : _toDate();

  Date _toDate() => Date.fromDateTime(this);
}
