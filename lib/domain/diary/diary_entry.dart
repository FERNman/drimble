import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';

import '../date.dart';
import 'consumed_drink.dart';

class DiaryEntry {
  String? id;

  final Date date;

  // TODO: This could be of type Iterable to make sure it cannot be modified (by type).
  // Right now, trying to modify would throw an exception
  final List<ConsumedDrink> drinks;

  bool get isDrinkFreeDay => drinks.isEmpty;

  double get gramsOfAlcohol => drinks.map((drink) => drink.gramsOfAlcohol).sum;

  int get calories => drinks.map((drink) => drink.calories).sum;

  DiaryEntry({
    this.id,
    required this.date,
  }) : drinks = [];

  factory DiaryEntry.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) =>
      DiaryEntry(
        id: snapshot.id,
        date: (snapshot['date'] as Timestamp).toDate().toDate(),
      );

  DiaryEntry.withDrinks(DiaryEntry diaryEntry, {required List<ConsumedDrink> drinks})
      : id = diaryEntry.id,
        date = diaryEntry.date,
        drinks = List.unmodifiable(drinks);

  Map<String, dynamic> toFirestore(String userId) => {
        'userId': userId,
        'date': date.toDateTime(),
      };
}
