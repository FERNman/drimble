import 'package:drimble/domain/diary/stomach_fullness.dart';
import 'package:drimble/features/select_stomach_fullness/select_stomach_fullness_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(SelectStomachFullnessCubit, () {
    test('should update the state with the selected stomach fullness', () async {
      final cubit = SelectStomachFullnessCubit();

      const stomachFullness = StomachFullness.full;
      cubit.selectStomachFullness(stomachFullness);

      expect(cubit.state.stomachFullness, stomachFullness);
    });
  });
}
