import '../date.dart';

class DiaryEntry {
  String? id;
  final Date date;
  final bool isDrinkFreeDay;

  DiaryEntry({
    this.id,
    required this.date,
    required this.isDrinkFreeDay,
  });

  DiaryEntry copyWith({Date? date, bool? isDrinkFreeDay}) => DiaryEntry(
        id: id,
        date: date ?? this.date,
        isDrinkFreeDay: isDrinkFreeDay ?? this.isDrinkFreeDay,
      );
}
