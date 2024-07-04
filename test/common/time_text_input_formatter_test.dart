import 'package:drimble/features/common/time_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final inputFormatter = TimeTextInputFormatter();

  test('should not allow typing an invalid digit', () {
    final oldValue = _createValueFromString('');
    final newValue = _createValueFromString('z');

    final result = inputFormatter.formatEditUpdate(oldValue, newValue);

    expect(result, oldValue);
  });

  test('should not allow typing "am" before entering a valid time', () {
    final oldValue = _createValueFromString('');
    final newValue = _createValueFromString('am');

    final result = inputFormatter.formatEditUpdate(oldValue, newValue);

    expect(result, oldValue);
  });

  test('should not remove everything if typing an invalid digit', () {
    final oldValue = _createValueFromString('11:2');
    final newValue = _createValueFromString('11:2z');

    final result = inputFormatter.formatEditUpdate(oldValue, newValue);

    expect(result, oldValue);
  });

  test('should remove invalid colons', () {
    final oldValue = _createValueFromString('');
    final newValue = _createValueFromString(':');

    final result = inputFormatter.formatEditUpdate(oldValue, newValue);

    expect(result, oldValue);
  });

  test('should not add a colon when typing a single digit', () {
    final oldValue = _createValueFromString('');
    final newValue = _createValueFromString('1');

    final result = inputFormatter.formatEditUpdate(oldValue, newValue);

    expect(result.text, newValue.text);
    expect(result.selection, newValue.selection);
  });

  test('should add a colon after the second digit', () {
    final oldValue = _createValueFromString('1');
    final newValue = _createValueFromString('12');

    final result = inputFormatter.formatEditUpdate(oldValue, newValue);

    final expectedText = '${newValue.text}:';
    expect(result.text, expectedText);
    expect(result.selection, TextSelection.collapsed(offset: expectedText.length));
  });

  test('should not add a colon after the third digit', () {
    final oldValue = _createValueFromString('12:');
    final newValue = _createValueFromString('12:3');

    final result = inputFormatter.formatEditUpdate(oldValue, newValue);

    expect(result.text, newValue.text);
    expect(result.selection, newValue.selection);
  });

  test('should not allow typing a fifth digit', () {
    final oldValue = _createValueFromString('12:34');
    final newValue = _createValueFromString('12:345');

    final result = inputFormatter.formatEditUpdate(oldValue, newValue);

    expect(result, oldValue);
  });

  test('should remove the second digit if deleting the colon', () {
    final oldValue = _createValueFromString('12:');
    final newValue = _createValueFromString('12');

    final result = inputFormatter.formatEditUpdate(oldValue, newValue);

    expect(result.text, '1');
    expect(result.selection, const TextSelection.collapsed(offset: 1));
  });

  test('should not do anything if deleting any digit except for the colon', () {
    final oldValue = _createValueFromString('11:2');
    final newValue = _createValueFromString('11:');

    final result = inputFormatter.formatEditUpdate(oldValue, newValue);

    expect(result.text, newValue.text);
    expect(result.selection, newValue.selection);
  });

  test('should not do anything if deleting a selection', () {
    final oldValue = _createValueFromString('11:2');
    final newValue = _createValueFromString('1');

    final result = inputFormatter.formatEditUpdate(oldValue, newValue);

    expect(result.text, newValue.text);
    expect(result.selection, TextSelection.collapsed(offset: newValue.text.length));
  });

  test('should move the selection correctly if inserting a digit', () {
    final oldValue = _createValueFromString('11:');
    final newValue = _createValueFromString('12:1', carretPosition: 2);

    final result = inputFormatter.formatEditUpdate(oldValue, newValue);

    expect(result.text, newValue.text);
    expect(result.selection, const TextSelection.collapsed(offset: 3));
  });

  test('should allow typing am after entering a valid time', () {
    final oldValue = _createValueFromString('12:34');

    for (final input in ['12:34a', '12:34am']) {
      final newValue = _createValueFromString(input);

      final result = inputFormatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, newValue.text);
      expect(result.selection, newValue.selection);
    }
  });

  test('should allow typing pm after entering a valid time', () {
    final oldValue = _createValueFromString('12:34');

    for (final input in ['12:34p', '12:34pm']) {
      final newValue = _createValueFromString(input);

      final result = inputFormatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, newValue.text);
      expect(result.selection, newValue.selection);
    }
  });

  test('should allow spaces after entering a valid time', () {
    final oldValue = _createValueFromString('12:34');
    final newValue = _createValueFromString('12:34 ');

    final result = inputFormatter.formatEditUpdate(oldValue, newValue);

    expect(result.text, newValue.text);
    expect(result.selection, newValue.selection);
  });

  test('should not allow typing after entering am', () {
    final oldValue = _createValueFromString('12:34 am');
    final newValue = _createValueFromString('12:34 amm');

    final result = inputFormatter.formatEditUpdate(oldValue, newValue);

    expect(result, oldValue);
  });

  test('should not allow typing after entering pm', () {
    final oldValue = _createValueFromString('12:34 pm');
    final newValue = _createValueFromString('12:34 pmm');

    final result = inputFormatter.formatEditUpdate(oldValue, newValue);

    expect(result, oldValue);
  });

  test('should not allow typing invalid 12-hour time formats', () {
    final oldValue = _createValueFromString('12:34 a');
    final newValue = _createValueFromString('12:34 aa');

    final result = inputFormatter.formatEditUpdate(oldValue, newValue);

    expect(result, oldValue);
  });
}

TextEditingValue _createValueFromString(String value, {int? carretPosition}) {
  return TextEditingValue(
    text: value,
    selection: TextSelection.collapsed(offset: carretPosition ?? value.length),
  );
}
