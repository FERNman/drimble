import 'package:drimble/data/user_repository.dart';
import 'package:drimble/features/edit_weekly_goal/edit_weekly_goal_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../generate_entities.dart';
import '../analytics/analytics_cubit_test.mocks.dart';

@GenerateNiceMocks([MockSpec<UserRepository>()])
void main() {
  group(EditWeeklyGoalCubit, () {
    final mockUserRepository = MockUserRepository();

    final user = generateUser();
    setUp(() {
      when(mockUserRepository.observeUser()).thenAnswer((_) => Stream.value(user));
    });

    tearDown(() {
      resetMockitoState();
    });

    test('should load the users goals initially', () async {
      final cubit = EditWeeklyGoalCubit(mockUserRepository);
      await cubit.stream.first;

      expect(cubit.state.goals, user.goals);
      expect(cubit.state.newGoals, user.goals);
    });

    test('should allow updating the weekly grams of alcohol', () async {
      final cubit = EditWeeklyGoalCubit(mockUserRepository);
      await cubit.stream.first; // Load the user

      final gramsOfAlcohol = faker.randomGenerator.integer(200);
      cubit.updateGramsOfAlcohol(gramsOfAlcohol);

      expect(cubit.state.newGoals.weeklyGramsOfAlcohol, gramsOfAlcohol);
      expect(cubit.state.newGoals.weeklyDrinkFreeDays, user.goals.weeklyDrinkFreeDays);
    });

    test('should allow updating the drink-free days', () async {
      final cubit = EditWeeklyGoalCubit(mockUserRepository);
      await cubit.stream.first; // Load the user

      final drinkFreeDays = faker.randomGenerator.integer(7);
      cubit.updateDrinkFreeDays(drinkFreeDays);

      expect(cubit.state.newGoals.weeklyDrinkFreeDays, drinkFreeDays);
      expect(cubit.state.newGoals.weeklyGramsOfAlcohol, user.goals.weeklyGramsOfAlcohol);
    });

    test('should save the new goals', () async {
      final cubit = EditWeeklyGoalCubit(mockUserRepository);
      await cubit.stream.first; // Load the user

      final drinkFreeDays = faker.randomGenerator.integer(7);
      cubit.updateDrinkFreeDays(drinkFreeDays);

      final gramsOfAlcohol = faker.randomGenerator.integer(200);
      cubit.updateGramsOfAlcohol(gramsOfAlcohol);

      await cubit.saveGoals();

      expect(cubit.state.newGoals.weeklyGramsOfAlcohol, gramsOfAlcohol);
      expect(cubit.state.newGoals.weeklyDrinkFreeDays, drinkFreeDays);
      verify(mockUserRepository.setGoals(cubit.state.newGoals));
    });
  });
}
