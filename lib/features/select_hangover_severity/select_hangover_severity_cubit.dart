import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/diary/hangover_severity.dart';

class SelectHangoverSeverityCubit extends Cubit<SelectHangoverSeverityState> {
  SelectHangoverSeverityCubit() : super(SelectHangoverSeverityState());

  void setHangoverSeverity(HangoverSeverity hangoverSeverity) {
    emit(state.copyWith(hangoverSeverity: hangoverSeverity));
  }
}

class SelectHangoverSeverityState {
  final HangoverSeverity hangoverSeverity;

  SelectHangoverSeverityState({this.hangoverSeverity = HangoverSeverity.none});

  SelectHangoverSeverityState copyWith({required HangoverSeverity hangoverSeverity}) => SelectHangoverSeverityState(
        hangoverSeverity: hangoverSeverity,
      );
}
