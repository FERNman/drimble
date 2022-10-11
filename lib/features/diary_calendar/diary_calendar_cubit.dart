import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/diary_repository.dart';
import '../../domain/diary/diary_entry.dart';
import '../../infra/extensions/floor_date_time.dart';
import '../common/disposable.dart';

class DiaryCalendarCubit extends Cubit<DiaryCalendarCubitState> with Disposable {
  final DiaryRepository _diaryRepository;

  DiaryCalendarCubit(this._diaryRepository) : super(DiaryCalendarCubitState()) {
    _load();
  }

  void _load() async {
    addSubscription(_diaryRepository
        .observeEntriesAfter(state.startDate)
        .map((items) => _toDateMap(state.startDate, items))
        .listen((items) => emit(DiaryCalendarCubitState(diaryEntries: items))));
  }

  Map<DateTime, DiaryEntry> _toDateMap(DateTime date, List<DiaryEntry> items) {
    return {for (final el in items) el.date: el};
  }
}

class DiaryCalendarCubitState {
  static const thirtyDays = Duration(days: 30);

  final today = DateTime.now();
  final startDate = DateTime.now().subtract(thirtyDays);

  final Map<DateTime, DiaryEntry> _diaryEntries;

  get dayCount => thirtyDays.inDays;

  DiaryCalendarCubitState({Map<DateTime, DiaryEntry> diaryEntries = const {}}) : _diaryEntries = diaryEntries;

  bool? isDrinkFreeDay(DateTime date) {
    return _diaryEntries[date.floorToDay()]?.isDrinkFreeDay;
  }
}
