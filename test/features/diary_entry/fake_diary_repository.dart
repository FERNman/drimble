import 'package:drimble/data/diary_repository.dart';
import 'package:drimble/domain/diary/diary_entry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rxdart/rxdart.dart';

import '../../generate_entities.dart';

class FakeDiaryRepository extends Fake implements DiaryRepository {
  final BehaviorSubject<Map<String, DiaryEntry>> _entries;

  FakeDiaryRepository(DiaryEntry initial) : _entries = BehaviorSubject.seeded({initial.id!: initial});

  @override
  Future<void> saveDiaryEntry(DiaryEntry diaryEntry) async {
    // Firebase adds an ID for documents that don't have one
    final diaryEntryWithId = _addId(diaryEntry);
    _entries.add(_entries.value..addEntries([MapEntry(diaryEntryWithId.id!, diaryEntryWithId)]));
  }

  @override
  Stream<DiaryEntry> observeEntryById(String id) {
    return _entries.stream.map((entries) => entries[id]!);
  }

  DiaryEntry _addId(DiaryEntry diaryEntry) => DiaryEntry(
        id: diaryEntry.id ?? faker.guid.guid(),
        date: diaryEntry.date,
        stomachFullness: diaryEntry.stomachFullness,
        glassesOfWater: diaryEntry.glassesOfWater,
        drinks: List.unmodifiable(diaryEntry.drinks),
        hangoverSeverity: diaryEntry.hangoverSeverity,
      );
}
