import 'package:drimble/domain/bac/user_bac_extensions.dart';
import 'package:drimble/domain/user/gender.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../generate_entities.dart';

void main() {
  group('UserBACExtensions', () {
    group('total body water', () {
      test('should return ~46.5L for an average man', () {
        final user = generateUser(gender: Gender.male, age: 45, height: 184, weight: 85);
        expect(user.totalBodyWater, closeTo(46.5, 0.1));
      });
    });

    group('rho factor', () {
      test('should return ~0.66L/kg for a man', () {
        final user = generateUser(gender: Gender.male, age: 45, height: 184, weight: 85);
        expect(user.rhoFactor(), closeTo(0.66, 0.01));
      });

      test('should return ~0.7 L/kgfor a relatively lightweight man', () {
        // Taken from Jones (2007): Body Mass Index and Blood-Alcohol Calculations, Letter to the Editor
        final user = generateUser(gender: Gender.male, age: 45, height: 183, weight: 64);
        expect(user.rhoFactor(), closeTo(0.7, 0.025));
      }, skip: 'Not yet implemented.');

      test('should return ~0.55L/kg for a healthy woman', () {
        final user = generateUser(gender: Gender.female, age: 45, height: 165, weight: 65);
        expect(user.rhoFactor(), closeTo(0.55, 0.05));
      });

      test('should return ~0.45L/kg for an obese woman', () {
        // Taken from Jones (2007): Body Mass Index and Blood-Alcohol Calculations, Letter to the Editor
        final user = generateUser(gender: Gender.female, age: 45, height: 160, weight: 81);
        expect(user.rhoFactor(), closeTo(0.45, 0.025));
      }, skip: 'Not yet implemented.');
    });
  });
}
