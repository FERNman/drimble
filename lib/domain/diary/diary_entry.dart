import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';

import '../date.dart';
import 'consumed_drink.dart';
import 'hangover_severity.dart';
import 'stomach_fullness.dart';

class DiaryEntry {
  final String? id;
  final Date date;
  final int glassesOfWater;
  final StomachFullness? stomachFullness;
  final UnmodifiableListView<ConsumedDrink> drinks;
  final HangoverSeverity? hangoverSeverity;

  bool get isDrinkFreeDay => drinks.isEmpty;

  double get gramsOfAlcohol => drinks.map((drink) => drink.gramsOfAlcohol).sum;

  int get calories => drinks.map((drink) => drink.calories).sum;

  DiaryEntry({
    this.id,
    required this.date,
    this.stomachFullness,
    this.glassesOfWater = 0,
    this.hangoverSeverity,
    List<ConsumedDrink> drinks = const [],
  })  : assert(stomachFullness != null || drinks.isEmpty),
        assert(hangoverSeverity == null || drinks.isNotEmpty),
        drinks = UnmodifiableListView(drinks);

  DiaryEntry addDrink(ConsumedDrink drink) {
    assert(drinks.every((d) => d.id != drink.id));
    return _copyWith(drinks: [...drinks, drink]);
  }

  DiaryEntry upsertDrink(String id, ConsumedDrink drink) {
    if (drinks.any((d) => d.id == id)) {
      return _copyWith(drinks: drinks.map((d) => d.id == id ? drink : d).toList());
    } else {
      return _copyWith(drinks: [...drinks, drink]);
    }
  }

  DiaryEntry removeDrink(String id) {
    final updatedDrinks = drinks.where((drink) => drink.id != id).toList();
    if (updatedDrinks.isEmpty) {
      return DiaryEntry(id: this.id, date: date);
    } else {
      return _copyWith(drinks: updatedDrinks);
    }
  }

  DiaryEntry addGlassOfWater() => _copyWith(glassesOfWater: glassesOfWater + 1);

  DiaryEntry removeGlassOfWater() => glassesOfWater > 0 ? _copyWith(glassesOfWater: glassesOfWater - 1) : this;

  DiaryEntry setStomachFullness(StomachFullness stomachFullness) => _copyWith(stomachFullness: stomachFullness);

  DiaryEntry setHangoverSeverity(HangoverSeverity hangoverSeverity) => _copyWith(hangoverSeverity: hangoverSeverity);

  DiaryEntry _copyWith({
    int? glassesOfWater,
    List<ConsumedDrink>? drinks,
    StomachFullness? stomachFullness,
    HangoverSeverity? hangoverSeverity,
  }) =>
      DiaryEntry(
        id: id,
        date: date,
        stomachFullness: stomachFullness ?? this.stomachFullness,
        drinks: drinks ?? this.drinks,
        glassesOfWater: glassesOfWater ?? this.glassesOfWater,
        hangoverSeverity: hangoverSeverity ?? this.hangoverSeverity,
      );

  factory DiaryEntry.withDrinks(DiaryEntry diaryEntry, {required List<ConsumedDrink> drinks}) => DiaryEntry(
        id: diaryEntry.id,
        date: diaryEntry.date,
        stomachFullness: diaryEntry.stomachFullness,
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
        stomachFullness:
            snapshot['stomachFullness'] == null ? null : StomachFullness.values[snapshot['stomachFullness'] as int],
        glassesOfWater: snapshot['glassesOfWater'] as int,
        drinks: (snapshot['drinks'] as List).map((drink) => ConsumedDrink.fromJSON(drink)).toList(),
        hangoverSeverity:
            snapshot['hangoverSeverity'] == null ? null : HangoverSeverity.values[snapshot['hangoverSeverity'] as int],
      );

  Map<String, dynamic> toFirestore(String userId) => {
        'userId': userId,
        'date': date.toDateTime(),
        'stomachFullness': stomachFullness?.index,
        'glassesOfWater': glassesOfWater,
        'drinks': drinks.map((drink) => drink.toJSON()).toList(),
        'hangoverSeverity': hangoverSeverity?.index,
      };
}
