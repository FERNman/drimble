import 'package:drimble/data/diary_repository.dart';
import 'package:drimble/data/user_repository.dart';
import 'package:drimble/features/diary/diary_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../generate_entities.dart';
import 'diary_cubit_test.mocks.dart';

@GenerateNiceMocks([MockSpec<UserRepository>(), MockSpec<DiaryRepository>()])
void main() {
  group(DiaryCubit, () {
    test('should not throw an exception for a state with no drinks but a user', () async {
      final user = generateUser();
      final userRepository = MockUserRepository();
      final diaryRepository = MockDiaryRepository();

      when(userRepository.loadUser()).thenAnswer((_) => Future.value(user));
      when(diaryRepository.observeDrinksBetweenDays(any, any)).thenAnswer((_) => Stream.value([]));

      // TOOD: This potentially throws an exception, 
      // but since the exception is thrown on a different isolate, the test doesn't catch it
      final cubit = DiaryCubit(userRepository, diaryRepository);
      await cubit.stream.first;

      expect(cubit.state.drinks, isEmpty);
    }, timeout: const Timeout(Duration(milliseconds: 500)));
  });
}
