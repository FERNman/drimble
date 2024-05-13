import 'package:drimble/domain/alcohol/alcohol.dart';
import 'package:drimble/domain/alcohol/cocktail.dart';
import 'package:drimble/domain/alcohol/drink.dart';
import 'package:drimble/domain/alcohol/drink_category.dart';
import 'package:drimble/domain/alcohol/ingredient.dart';
import 'package:drimble/domain/date.dart';
import 'package:drimble/domain/diary/consumed_cocktail.dart';
import 'package:drimble/domain/diary/consumed_drink.dart';
import 'package:drimble/domain/diary/diary_entry.dart';
import 'package:drimble/domain/diary/stomach_fullness.dart';
import 'package:drimble/domain/user/body_composition.dart';
import 'package:drimble/domain/user/gender.dart';
import 'package:drimble/domain/user/user.dart';
import 'package:drimble/domain/user/user_goals.dart';
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
  UserGoals? goals,
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

Drink generateDrink({
  String? name,
  String? iconPath,
  DrinkCategory? category,
  double? alcoholByVolume,
  List<int>? defaultServings,
  Duration? defaultDuration,
}) =>
    Drink(
      name: name ?? faker.lorem.word(),
      iconPath: iconPath ?? '',
      category: category ?? faker.randomGenerator.element(DrinkCategory.values),
      alcoholByVolume: alcoholByVolume ?? faker.randomGenerator.decimal(),
      defaultServings: defaultServings ??
          [
            faker.randomGenerator.integer(200, min: 100),
            faker.randomGenerator.integer(500, min: 200),
          ],
      defaultDuration: defaultDuration ?? Duration(minutes: faker.randomGenerator.integer(60, min: 1)),
    );

Cocktail generateCocktail({
  String? name,
  String? iconPath,
  List<int>? defaultServings,
  Duration? defaultDuration,
  List<Ingredient>? ingredients,
}) {
  defaultServings = defaultServings ?? _generateServings();
  return Cocktail(
    name: name ?? faker.lorem.word(),
    iconPath: iconPath ?? '',
    defaultServings: defaultServings,
    defaultDuration: defaultDuration ?? Duration(minutes: faker.randomGenerator.integer(60, min: 1)),
    ingredients: ingredients ?? _generateIngredients(),
  );
}

List<Milliliter> _generateServings() {
  return [
    faker.randomGenerator.integer(200, min: 100),
    faker.randomGenerator.integer(500, min: 200),
  ];
}

/// Generates a drink with a random start time between 6am on the given date and 6am on the next day.
ConsumedDrink generateConsumedDrinkOnDate({
  required Date date,
  String? id,
  String? name,
  DrinkCategory? category,
  int? volume,
  double? alcoholByVolume,
  Duration? duration,
  StomachFullness? stomachFullness,
}) =>
    generateConsumedDrink(
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
    );

ConsumedDrink generateConsumedDrink({
  String? id,
  String? name,
  String? iconPath,
  DrinkCategory? category,
  int? volume,
  double? alcoholByVolume,
  DateTime? startTime,
  Duration? duration,
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
    );

ConsumedCocktail generateConsumedCocktailOnDate({
  required Date date,
  String? id,
  String? name,
  String? iconPath,
  int? volume,
  Duration? duration,
  StomachFullness? stomachFullness,
  List<Ingredient>? ingredients,
}) =>
    generateConsumedCocktail(
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

ConsumedCocktail generateConsumedCocktailFromCocktail(
  Cocktail cocktail, {
  Milliliter? volume,
  DateTime? startTime,
  Duration? duration,
  StomachFullness? stomachFullness,
}) {
  volume = volume ?? cocktail.defaultServings.first;

  return generateConsumedCocktail(
    name: cocktail.name,
    iconPath: cocktail.iconPath,
    volume: volume,
    startTime: startTime,
    duration: duration ?? cocktail.defaultDuration,
    stomachFullness: stomachFullness,
    ingredients: cocktail.ingredients,
  );
}

ConsumedCocktail generateConsumedCocktail({
  String? id,
  String? name,
  String? iconPath,
  Milliliter? volume,
  DateTime? startTime,
  Duration? duration,
  StomachFullness? stomachFullness,
  List<Ingredient>? ingredients,
}) {
  volume = volume ?? faker.randomGenerator.integer(500, min: 1);

  return ConsumedCocktail(
    id: id,
    name: name ?? faker.lorem.word(),
    iconPath: iconPath ?? '',
    volume: volume,
    startTime: startTime ?? faker.date.dateTime(),
    duration: duration ?? Duration(minutes: faker.randomGenerator.integer(60, min: 1)),
    ingredients: ingredients ?? _generateIngredients(),
  );
}

List<Ingredient> _generateIngredients() {
  final numberOfIngredients = faker.randomGenerator.integer(5, min: 1);

  return List.generate(
    numberOfIngredients,
    (_) => generateIngredient(
      percentOfCocktailVolume: faker.randomGenerator.decimal(scale: 1 / numberOfIngredients),
    ),
  );
}

Ingredient generateIngredient({
  String? name,
  String? iconPath,
  Percentage? percentOfCocktailVolume,
  double? alcoholByVolume,
}) =>
    Ingredient(
      name: name ?? faker.lorem.word(),
      iconPath: iconPath ?? '',
      percentOfCocktailVolume: percentOfCocktailVolume ?? faker.randomGenerator.decimal(),
      alcoholByVolume: alcoholByVolume ?? faker.randomGenerator.decimal(min: 0.01),
    );

DiaryEntry generateDiaryEntry({
  String? id,
  Date? date,
  StomachFullness? stomachFullness,
  int? glassesOfWater,
  List<ConsumedDrink>? drinks,
}) =>
    // This is to be able to generate a diary entry with drinks, which we don't allow anywhere except here
    DiaryEntry(
      id: id,
      date: date ?? faker.date.date(),
      stomachFullness: stomachFullness ??
          ((drinks == null || drinks.isEmpty) ? null : faker.randomGenerator.element(StomachFullness.values)),
      glassesOfWater: glassesOfWater ?? faker.randomGenerator.integer(10),
      drinks: drinks ?? [],
    );

UserGoals generateGoals({
  int? weeklyGramsOfAlcohol,
  int? weeklyDrinkFreeDays,
}) =>
    UserGoals(
      weeklyGramsOfAlcohol: weeklyGramsOfAlcohol ?? faker.randomGenerator.integer(200),
      weeklyDrinkFreeDays: weeklyDrinkFreeDays ?? faker.randomGenerator.integer(7),
    );
