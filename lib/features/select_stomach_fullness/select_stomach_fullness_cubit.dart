import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/diary/stomach_fullness.dart';

class SelectStomachFullnessCubit extends Cubit<SelectStomachFullnessState> {
  SelectStomachFullnessCubit() : super(SelectStomachFullnessState());

  void selectStomachFullness(StomachFullness stomachFullness) {
    emit(state.copyWith(stomachFullness: stomachFullness));
  }
}

class SelectStomachFullnessState {
  final StomachFullness? stomachFullness;

  SelectStomachFullnessState({this.stomachFullness});

  SelectStomachFullnessState copyWith({required StomachFullness stomachFullness}) => SelectStomachFullnessState(
        stomachFullness: stomachFullness,
      );
}
