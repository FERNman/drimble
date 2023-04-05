import 'package:drimble/domain/alcohol/drink_category.dart';
import 'package:drimble/domain/diary/diary_entry.dart';
import 'package:drimble/domain/diary/drink.dart';
import 'package:drimble/domain/diary/stomach_fullness.dart';
import 'package:drimble/domain/user/body_composition.dart';
import 'package:drimble/domain/user/gender.dart';
import 'package:drimble/domain/user/goals.dart';
import 'package:drimble/domain/user/user.dart';
import 'package:drimble/infra/extensions/floor_date_time.dart';
import 'package:faker/faker.dart';

final faker = Faker();

User generateUser({
  String? name,
  Gender? gender,
  int? age,
  int? height,
  int? weight,
  BodyComposition? bodyComposition,
  Goals? goals,
}) =>
    User(
      name: name ?? faker.person.name(),
      gender: gender ?? faker.randomGenerator.element(Gender.values),
      age: age ?? faker.randomGenerator.integer(60, min: 20),
      height: height ?? faker.randomGenerator.integer(200, min: 160),
      weight: weight ?? faker.randomGenerator.integer(100, min: 60),
      bodyComposition: bodyComposition ?? faker.randomGenerator.element(BodyComposition.values),
      goals: goals ?? generateGoals(),
    );

/// Generates a drink with a random start time between 6am on the given date and 6am on the next day.
Drink generateDrinkOnDate({
  required DateTime date,
  String? id,
  String? name,
  DrinkCategory? category,
  int? volume,
  double? alcoholByVolume,
  Duration? duration,
  StomachFullness? stomachFullness,
}) =>
    generateDrink(
      id: id,
      name: name,
      category: category,
      volume: volume,
      alcoholByVolume: alcoholByVolume,
      startTime: faker.date.dateTimeBetween(
        date.floorToDay(hour: 6),
        date.add(const Duration(days: 1)).floorToDay(hour: 6),
      ),
      duration: duration,
      stomachFullness: stomachFullness,
    );

Drink generateDrink({
  String? id,
  String? name,
  DrinkCategory? category,
  int? volume,
  double? alcoholByVolume,
  DateTime? startTime,
  Duration? duration,
  StomachFullness? stomachFullness,
}) =>
    Drink(
      id: id,
      name: name ?? faker.lorem.word(),
      icon: '',
      category: category ?? faker.randomGenerator.element(DrinkCategory.values),
      volume: volume ?? faker.randomGenerator.integer(500),
      alcoholByVolume: alcoholByVolume ?? faker.randomGenerator.decimal(),
      startTime: startTime ?? faker.date.dateTime(),
      duration: duration ?? Duration(minutes: faker.randomGenerator.integer(60, min: 1)),
      stomachFullness: stomachFullness ?? faker.randomGenerator.element(StomachFullness.values),
    );

DiaryEntry generateDiaryEntry({
  String? id,
  DateTime? date,
  bool? isDrinkFreeDay,
}) =>
    DiaryEntry(
      id: id,
      date: date ?? faker.date.dateTime(),
      isDrinkFreeDay: isDrinkFreeDay ?? faker.randomGenerator.boolean(),
    );

Goals generateGoals({
  int? weeklyGramsOfAlcohol,
  int? weeklyDrinkFreeDays,
}) =>
    Goals(
      weeklyGramsOfAlcohol: weeklyGramsOfAlcohol ?? faker.randomGenerator.integer(200),
      weeklyDrinkFreeDays: weeklyDrinkFreeDays ?? faker.randomGenerator.integer(7),
    );
