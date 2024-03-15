import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/diary_repository.dart';
import '../../domain/date.dart';
import '../../domain/diary/consumed_drink.dart';
import '../../domain/diary/diary_entry.dart';
import '../../infra/disposable.dart';

class TodaysDrinksCubit extends Cubit<TodaysDrinksCubitState> with Disposable {
  final DiaryRepository _repository;

  TodaysDrinksCubit(this._repository, {required Date date})
      : super(TodaysDrinksCubitState(date: date, diaryEntry: null)) {
    _subscribeToRepository();
  }

  Future<void> removeDrink(ConsumedDrink drink) async {
    assert(state.diaryEntry != null);
    await _repository.removeDrinkFromDiaryEntry(state.diaryEntry!, drink);
  }

  void _subscribeToRepository() {
    addSubscription(
        _repository.observeEntryOnDate(state.date).listen((value) => emit(state.copyWith(diaryEntry: value))));
  }
}

class TodaysDrinksCubitState {
  final Date date;
  final DiaryEntry? diaryEntry;
  List<ConsumedDrink> get drinks => diaryEntry?.drinks ?? const [];

  const TodaysDrinksCubitState({required this.diaryEntry, required this.date});

  TodaysDrinksCubitState copyWith({DiaryEntry? diaryEntry}) => TodaysDrinksCubitState(
        date: date,
        diaryEntry: diaryEntry,
      );
}
