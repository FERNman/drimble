import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';

import '../date.dart';
import 'consumed_drink.dart';

class DiaryEntry {
  final String? id;

  final Date date;

  final UnmodifiableListView<ConsumedDrink> drinks;

  final int glassesOfWater;

  bool get isDrinkFreeDay => drinks.isEmpty;

  double get gramsOfAlcohol => drinks.map((drink) => drink.gramsOfAlcohol).sum;

  int get calories => drinks.map((drink) => drink.calories).sum;

  DiaryEntry({
    this.id,
    required this.date,
    List<ConsumedDrink> drinks = const [],
    this.glassesOfWater = 0,
  }) : drinks = UnmodifiableListView(drinks);

  DiaryEntry copyWith({
    int? glassesOfWater,
  }) =>
      DiaryEntry(
        id: id,
        date: date,
        drinks: drinks,
        glassesOfWater: glassesOfWater ?? this.glassesOfWater,
      );

  factory DiaryEntry.withDrinks(DiaryEntry diaryEntry, {required List<ConsumedDrink> drinks}) => DiaryEntry(
        id: diaryEntry.id,
        date: diaryEntry.date,
        glassesOfWater: diaryEntry.glassesOfWater,
        drinks: drinks,
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

  Map<String, dynamic> toFirestore(String userId) => {
        'userId': userId,
        'date': date.toDateTime(),
        'glassesOfWater': glassesOfWater,
      };
}
