import 'package:drimble/data/diary_repository.dart';
import 'package:drimble/domain/diary/diary_entry.dart';
import 'package:drimble/domain/diary/stomach_fullness.dart';
import 'package:drimble/features/select_stomach_fullness/select_stomach_fullnes_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../generate_entities.dart';
import 'select_stomach_fullness_cubit_test.mocks.dart';

@GenerateNiceMocks([MockSpec<DiaryRepository>()])
void main() {
  group(SelectStomachFullnessCubit, () {
    test('should update the diary entry with the selected stomach fullness', () async {
      final repository = MockDiaryRepository();

      final diaryEntry = generateDiaryEntry(stomachFullness: StomachFullness.empty);
      final cubit = SelectStomachFullnessCubit(repository, diaryEntry);

      const stomachFullness = StomachFullness.full;
      cubit.selectStomachFullness(stomachFullness);

      await cubit.save();

      final updatedDiaryEntry = verify(repository.saveDiaryEntry(captureAny)).captured.first as DiaryEntry;
      expect(updatedDiaryEntry.stomachFullness, stomachFullness);
    });
  });
}
