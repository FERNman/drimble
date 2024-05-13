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

  DiaryEntry upsertDrink(String id, ConsumedDrink drink) {
    if (drinks.any((d) => d.id == id)) {
      return _copyWith(drinks: drinks.map((d) => d.id == id ? drink : d).toList());
    } else {
      return _copyWith(drinks: [...drinks, drink]);
    }
  }

  DiaryEntry removeDrink(String id) {
    final updatedDrinks = drinks.where((drink) => drink.id != id).toList();
    return _copyWith(drinks: updatedDrinks);
  }

  DiaryEntry addGlassOfWater() => _copyWith(glassesOfWater: glassesOfWater + 1);

  DiaryEntry removeGlassOfWater() => glassesOfWater > 0 ? _copyWith(glassesOfWater: glassesOfWater - 1) : this;

  DiaryEntry _copyWith({
    int? glassesOfWater,
    List<ConsumedDrink>? drinks,
  }) =>
      DiaryEntry(
        id: id,
        date: date,
        drinks: drinks ?? this.drinks,
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
        drinks: (snapshot['drinks'] as List).map((drink) => ConsumedDrink.fromJSON(drink)).toList(),
      );

  Map<String, dynamic> toFirestore(String userId) => {
        'userId': userId,
        'date': date.toDateTime(),
        'glassesOfWater': glassesOfWater,
        'drinks': drinks.map((drink) => drink.toJSON()).toList(),
      };
}
