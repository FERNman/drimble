import 'package:drimble/domain/alcohol/drink_category.dart';
import 'package:drimble/domain/alcohol/ingredient.dart';
import 'package:drimble/domain/date.dart';
import 'package:drimble/domain/diary/consumed_cocktail.dart';
import 'package:drimble/domain/diary/consumed_drink.dart';
import 'package:drimble/domain/diary/diary_entry.dart';
import 'package:drimble/domain/diary/stomach_fullness.dart';
import 'package:drimble/domain/user/body_composition.dart';
import 'package:drimble/domain/user/gender.dart';
import 'package:drimble/domain/user/goals.dart';
import 'package:drimble/domain/user/user.dart';
import 'package:faker/faker.dart';
import 'package:faker/src/date.dart' as faker_date;

final faker = Faker();

extension DateGenerator on faker_date.Date {
  Date date() => dateTime().toDate();
}

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
ConsumedDrink generateDrinkOnDate({
  required Date date,
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
        date.toDateTime(),
        date.add(days: 1).toDateTime(),
      ),
      duration: duration,
      stomachFullness: stomachFullness,
    );

ConsumedDrink generateDrink({
  String? id,
  String? name,
  String? iconPath,
  DrinkCategory? category,
  int? volume,
  double? alcoholByVolume,
  DateTime? startTime,
  Duration? duration,
  StomachFullness? stomachFullness,
}) =>
    ConsumedDrink(
      id: id,
      name: name ?? faker.lorem.word(),
      iconPath: iconPath ?? '',
      category: category ?? faker.randomGenerator.element(DrinkCategory.values),
      volume: volume ?? faker.randomGenerator.integer(500, min: 1),
      alcoholByVolume: alcoholByVolume ?? faker.randomGenerator.decimal(),
      startTime: startTime ?? faker.date.dateTime(),
      duration: duration ?? Duration(minutes: faker.randomGenerator.integer(60, min: 1)),
      stomachFullness: stomachFullness ?? faker.randomGenerator.element(StomachFullness.values),
    );

ConsumedCocktail generateCocktailOnDate({
  required Date date,
  String? id,
  String? name,
  String? iconPath,
  int? volume,
  Duration? duration,
  StomachFullness? stomachFullness,
  List<Ingredient>? ingredients,
}) =>
    generateCocktail(
      id: id,
      name: name,
      volume: volume,
      startTime: faker.date.dateTimeBetween(
        date.toDateTime(),
        date.add(days: 1).toDateTime(),
      ),
      duration: duration,
      stomachFullness: stomachFullness,
      ingredients: ingredients,
    );

ConsumedCocktail generateCocktail({
  String? id,
  String? name,
  String? iconPath,
  int? volume,
  DateTime? startTime,
  Duration? duration,
  StomachFullness? stomachFullness,
  List<Ingredient>? ingredients,
}) {
  volume = volume ?? faker.randomGenerator.integer(500, min: 1);

  ingredients = ingredients ??
      List.generate(
        faker.randomGenerator.integer(5, min: 1),
        (_) => generateIngredient(volume: faker.randomGenerator.integer((volume! / 5.0).floor(), min: 1)),
      );

  return ConsumedCocktail(
    id: id,
    name: name ?? faker.lorem.word(),
    iconPath: iconPath ?? '',
    volume: volume,
    startTime: startTime ?? faker.date.dateTime(),
    duration: duration ?? Duration(minutes: faker.randomGenerator.integer(60, min: 1)),
    stomachFullness: stomachFullness ?? faker.randomGenerator.element(StomachFullness.values),
    ingredients: ingredients,
  );
}

Ingredient generateIngredient({
  String? name,
  String? iconPath,
  DrinkCategory? category,
  int? volume,
  double? alcoholByVolume,
}) =>
    Ingredient(
      name: name ?? faker.lorem.word(),
      iconPath: iconPath ?? '',
      category: category ?? faker.randomGenerator.element(DrinkCategory.values),
      volume: volume ?? faker.randomGenerator.integer(500, min: 1),
      alcoholByVolume: alcoholByVolume ?? faker.randomGenerator.decimal(min: 0.01),
    );

DiaryEntry generateDiaryEntry({
  String? id,
  Date? date,
  bool? isDrinkFreeDay,
}) =>
    DiaryEntry(
      id: id,
      date: date ?? faker.date.date(),
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
