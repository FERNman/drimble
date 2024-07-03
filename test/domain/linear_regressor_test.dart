import 'dart:math';

import 'package:collection/collection.dart';
import 'package:drimble/domain/linear_regressor.dart';
import 'package:flutter_test/flutter_test.dart';

import '../generate_entities.dart';

void main() {
  group(LinearRegressor, () {
    test('should be able to predict a constant function', () {
      final model = LinearRegressor([1], 0, [0], [1]);
      expect(model.predict([1]), 1);
    });

    test('should be able to predict a linear function', () {
      final model = LinearRegressor([2], 0, [0], [1]);
      expect(model.predict([1]), 2);
    });

    test('should be able to predict a linear function with intercept', () {
      final model = LinearRegressor([2], 1, [0], [1]);
      expect(model.predict([1]), 3);
    });

    test('should be able to predict a linear function with multiple features', () {
      final model = LinearRegressor([2, 3], 0, [0, 0], [1, 1]);
      expect(model.predict([1, 1]), 5);
    });

    test('should correctly scale features', () {
      final model = LinearRegressor([1], 0, [4], [2]);
      expect(model.predict([2]), -1); // (2 - 4) / 2
    });

    test('should be able to update the model', () {
      final model = LinearRegressor([1], 0, [0], [1], learningRate: 0.5);
      model.update([1], 2);

      expect(model.predict([1]), 2);
    });

    test('should be able to learn a 3d function', () {
      final model = LinearRegressor([0, 0], 0, [0, 0], [1, 1], learningRate: 0.01);

      final X = List.generate(100, (_) => [faker.randomGenerator.decimal(), faker.randomGenerator.decimal()]);

      // y = 2 * x1 + 5 * x2 + 1
      final y = X.map((x) => 2 * x[0] + 5 * x[1] + 1).toList();

      for (int iteration = 0; iteration < 200; iteration++) {
        for (int i = 0; i < X.length; i++) {
          final randomIndex = faker.randomGenerator.integer(X.length);
          model.update(X[randomIndex], y[randomIndex]);
        }
      }

      // 2 * 4 + 5 * 5 + 1 = 34
      expect(model.predict([4, 5]), closeTo(34, 0.1));
    });

    test('should be able to learn a 4d function with scaled coefficients', () {
      final X = List.generate(
        500,
        (_) => [
          faker.randomGenerator.decimal(),
          50 * faker.randomGenerator.decimal(),
          1000 * faker.randomGenerator.decimal(),
        ],
      );

      // y = 2 * x1 + 5 * x2 + x3 + 10
      final y = X.map((x) => 2 * x[0] + 5 * x[1] + x[2] + 10).toList();

      final x1 = X.map((x) => x[0]).toList();
      final x2 = X.map((x) => x[1]).toList();
      final x3 = X.map((x) => x[2]).toList();

      final mean = [
        x1.sum / x1.length,
        x2.sum / x2.length,
        x3.sum / x3.length,
      ];

      final stdDev = [
        sqrt(x1.map((e) => pow(e - mean[0], 2)).sum / x1.length),
        sqrt(x2.map((e) => pow(e - mean[1], 2)).sum / x2.length),
        sqrt(x3.map((e) => pow(e - mean[2], 2)).sum / x3.length),
      ];

      final model = LinearRegressor([0, 0, 0], 0, mean, stdDev, learningRate: 0.01);

      for (int iteration = 0; iteration < 200; iteration++) {
        for (int i = 0; i < X.length; i++) {
          final randomIndex = faker.randomGenerator.integer(X.length);
          model.update(X[randomIndex], y[randomIndex]);
        }
      }

      // 2 * 4 + 5 * 5 + 1 + 10 = 44
      expect(model.predict([4, 5, 1]), closeTo(44, 0.1));
    });
  });
}
