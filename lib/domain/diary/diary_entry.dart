import '../../infra/extensions/floor_date_time.dart';

class DiaryEntry {
  int? id;
  final DateTime date;
  final bool isDrinkFreeDay;

  DiaryEntry({
    this.id,
    required DateTime date,
    required this.isDrinkFreeDay,
  }) : date = date.floorToDay();

  DiaryEntry copyWith({DateTime? date, bool? isDrinkFreeDay}) => DiaryEntry(
        id: id,
        date: date ?? this.date,
        isDrinkFreeDay: isDrinkFreeDay ?? this.isDrinkFreeDay,
      );
}
