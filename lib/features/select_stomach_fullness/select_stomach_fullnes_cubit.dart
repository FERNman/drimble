import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/diary_repository.dart';
import '../../domain/diary/diary_entry.dart';
import '../../domain/diary/stomach_fullness.dart';

class SelectStomachFullnessCubit extends Cubit<SelectStomachFullnessState> {
  final DiaryRepository _diaryRepository;

  SelectStomachFullnessCubit(this._diaryRepository, DiaryEntry diaryEntry)
      : super(SelectStomachFullnessState(diaryEntry: diaryEntry));

  void selectStomachFullness(StomachFullness stomachFullness) {
    emit(state.copyWith(diaryEntry: state.diaryEntry.setStomachFullness(stomachFullness)));
  }

  Future<void> save() async {
    assert(state.diaryEntry.stomachFullness != null);
    await _diaryRepository.saveDiaryEntry(state.diaryEntry);
  }
}

class SelectStomachFullnessState {
  final DiaryEntry diaryEntry;

  SelectStomachFullnessState({required this.diaryEntry});

  SelectStomachFullnessState copyWith({required DiaryEntry diaryEntry}) => SelectStomachFullnessState(
        diaryEntry: diaryEntry,
      );
}
