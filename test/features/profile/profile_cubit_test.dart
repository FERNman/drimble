import 'package:drimble/data/user_repository.dart';
import 'package:drimble/features/profile/profile_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../generate_entities.dart';
import 'profile_cubit_test.mocks.dart';

@GenerateNiceMocks([MockSpec<UserRepository>()])
void main() {
  group(ProfileCubit, () {
    test('initial state is ProfileCubitStateLoading', () {
      final userRepository = MockUserRepository();
      final cubit = ProfileCubit(userRepository);

      expect(cubit.state, isA<ProfileCubitStateLoading>());
    });

    test('emits ProfileCubitState when user is loaded', () async {
      final mockUserRepository = MockUserRepository();

      final user = generateUser();
      when(mockUserRepository.observeUser()).thenAnswer((_) => Stream.value(user));

      final cubit = ProfileCubit(mockUserRepository);

      await expectLater(
        cubit.stream,
        emits(isA<ProfileCubitState>()),
      );
    });
  });
}
