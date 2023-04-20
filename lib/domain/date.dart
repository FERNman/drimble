/// Represents a date without time information.
class Date {
  final int year;
  final int month;
  final int day;

  int get weekday => toDateTime().weekday;

  const Date(this.year, this.month, this.day);

  /// Shifts the date to the previous day if it is before 6am
  Date.today() : this.fromDateTime(DateTime.now());

  /// Shifts the date to the previous day if it is before 6am
  Date.fromDateTime(DateTime dateTime) : this._internal(dateTime.shift());

  Date._internal(DateTime dateTime)
      : year = dateTime.year,
        month = dateTime.month,
        day = dateTime.day;

  /// Returns the date with the hour set to 6am
  DateTime toDateTime() => DateTime(year, month, day, 6);

  Date add({int? years, int? months, int? days}) {
    final dateTime = toDateTime().add(Duration(days: days ?? 0));
    return Date.fromDateTime(DateTime(dateTime.year + (years ?? 0), dateTime.month + (months ?? 0), dateTime.day, 6));
  }

  Date subtract({int? years, int? months, int? days}) {
    final dateTime = toDateTime().subtract(Duration(days: days ?? 0));
    // "Hack" to subtract years and months, compare to https://stackoverflow.com/a/54792544/4471085
    return Date.fromDateTime(DateTime(dateTime.year - (years ?? 0), dateTime.month - (months ?? 0), dateTime.day, 6));
  }

  Duration difference(Date other) => toDateTime().difference(other.toDateTime());

  bool isAfter(Date other) => toDateTime().isAfter(other.toDateTime());

  @override
  operator ==(Object other) => other is Date && other.year == year && other.month == month && other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);
}

extension DateExtensions on DateTime {
  /// shifts the date to the previous day if it is before 6am
  Date toDate() => Date.fromDateTime(this);
}

extension _ShiftedDateTime on DateTime {
  DateTime shift() => (hour < 6) ? subtract(const Duration(days: 1)) : this;
}

extension Week on Date {
  Date floorToWeek() => subtract(days: weekday - 1);
  Date floorToMonth() => Date(year, month, 1);
}
