import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/diary_repository.dart';
import '../../domain/date.dart';
import '../../domain/diary/diary_entry.dart';
import '../../infra/disposable.dart';

class DiaryCalendarCubit extends Cubit<DiaryCalendarCubitState> with Disposable {
  final DiaryRepository _diaryRepository;

  DiaryCalendarCubit(this._diaryRepository) : super(DiaryCalendarCubitState()) {
    _load();
  }

  void _load() async {
    addSubscription(_diaryRepository
        .observeEntriesAfter(state.startDate)
        .map((items) => items.groupFoldBy((el) => el.date, (_, el) => el))
        .listen((items) => emit(DiaryCalendarCubitState(diaryEntries: items))));
  }
}

class DiaryCalendarCubitState {
  static const thirtyDays = 30;

  final today = Date.today();
  final startDate = Date.today().subtract(days: thirtyDays);

  final Map<Date, DiaryEntry> _diaryEntries;

  DiaryCalendarCubitState({Map<Date, DiaryEntry> diaryEntries = const {}}) : _diaryEntries = diaryEntries;

  bool? isDrinkFreeDay(Date date) {
    return _diaryEntries[date]?.isDrinkFreeDay;
  }
}
