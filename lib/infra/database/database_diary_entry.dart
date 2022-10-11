import 'package:isar/isar.dart';

import '../../domain/diary/diary_entry.dart';

part 'database_diary_entry.g.dart';

@Collection(accessor: 'diary')
class DatabaseDiaryEntry extends DiaryEntry {
  DatabaseDiaryEntry({super.id, required super.date, required super.isDrinkFreeDay});
}

extension DiaryEntryDatabaseConversion on DiaryEntry {
  DatabaseDiaryEntry toEntity() => DatabaseDiaryEntry(id: id, date: date, isDrinkFreeDay: isDrinkFreeDay);
}
