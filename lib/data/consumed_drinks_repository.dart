import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';

import '../domain/drink/beverage.dart';
import '../domain/drink/consumed_drink.dart';
import '../domain/drink/stomach_fullness.dart';

class ConsumedDrinksRepository {
  final _drinks = BehaviorSubject.seeded([
    ConsumedDrink(
      beverage: Beverage.beer,
      volume: 500,
      alcoholByVolume: 0.05,
      startTime: DateTime.now(),
      duration: const Duration(minutes: 30),
      stomachFullness: StomachFullness.full,
    ),
  ]);

  Stream<List<ConsumedDrink>> observeDrinksOnDate(DateTime date) {
    return _drinks.map((drinks) => drinks.where((el) => DateUtils.isSameDay(el.startTime, date)).toList(growable: false)
      ..sort((lhs, rhs) => lhs.startTime.compareTo(rhs.startTime)));
  }

  Future<List<ConsumedDrink>> getDrinksOnDate(DateTime date) async {
    return _drinks.value.where((el) => DateUtils.isSameDay(el.startTime, date)).toList(growable: false)
      ..sort((a, b) => a.startTime.compareTo(b.startTime))
      ..take(3);
  }

  void save(ConsumedDrink drink) async {
    final drinks = _drinks.value;

    // Upsert
    drinks.remove(drink);
    drinks.add(drink);

    _drinks.add(drinks);
  }

  void removeDrink(ConsumedDrink drink) async {
    final drinks = _drinks.value;

    drinks.remove(drink);

    _drinks.add(drinks);
  }
}
