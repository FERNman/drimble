import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';

import '../date.dart';
import 'consumed_drink.dart';

class DiaryEntry {
  final String? id;

  final Date date;

  // TODO: This could be of type Iterable to make sure it cannot be modified (by type).
  // Right now, trying to modify would throw an exception
  final List<ConsumedDrink> drinks;

  final int glassesOfWater;

  bool get isDrinkFreeDay => drinks.isEmpty;

  double get gramsOfAlcohol => drinks.map((drink) => drink.gramsOfAlcohol).sum;

  int get calories => drinks.map((drink) => drink.calories).sum;

  const DiaryEntry({
    this.id,
    required this.date,
    this.glassesOfWater = 0,
  }) : drinks = const [];

  const DiaryEntry._({
    this.id,
    required this.date,
    required this.drinks,
    required this.glassesOfWater,
  });

  DiaryEntry copyWith({
    int? glassesOfWater,
  }) =>
      DiaryEntry._(
        id: id,
        date: date,
        drinks: drinks,
        glassesOfWater: glassesOfWater ?? this.glassesOfWater,
      );

  factory DiaryEntry.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) =>
      DiaryEntry(
        id: snapshot.id,
        date: (snapshot['date'] as Timestamp).toDate().toDate(),
        glassesOfWater: snapshot['glassesOfWater'] as int,
      );

  DiaryEntry.withDrinks(DiaryEntry diaryEntry, {required List<ConsumedDrink> drinks})
      : id = diaryEntry.id,
        date = diaryEntry.date,
        glassesOfWater = diaryEntry.glassesOfWater,
        drinks = List.unmodifiable(drinks);

  Map<String, dynamic> toFirestore(String userId) => {
        'userId': userId,
        'date': date.toDateTime(),
        'glassesOfWater': glassesOfWater,
      };
}
