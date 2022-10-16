import 'package:drimble/features/common/time_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final inputFormatter = TimeTextInputFormatter();

  test('Should not allow typing an invalid digit', () {
    final oldValue = _createValueFromString('');
    final newValue = _createValueFromString('a');

    final result = inputFormatter.formatEditUpdate(oldValue, newValue);

    expect(result, oldValue);
  });

  test('Should remove invalid colons', () {
    final oldValue = _createValueFromString('');
    final newValue = _createValueFromString(':');

    final result = inputFormatter.formatEditUpdate(oldValue, newValue);

    expect(result, oldValue);
  });

  test('Should not add a colon when typing a single digit', () {
    final oldValue = _createValueFromString('');
    final newValue = _createValueFromString('1');

    final result = inputFormatter.formatEditUpdate(oldValue, newValue);

    expect(result.text, newValue.text);
    expect(result.selection, newValue.selection);
  });

  test('Should add a colon after the second digit', () {
    final oldValue = _createValueFromString('1');
    final newValue = _createValueFromString('12');

    final result = inputFormatter.formatEditUpdate(oldValue, newValue);

    final expectedText = '${newValue.text}:';
    expect(result.text, expectedText);
    expect(result.selection, TextSelection.collapsed(offset: expectedText.length));
  });

  test('Should not add a colon after the third digit', () {
    final oldValue = _createValueFromString('12:');
    final newValue = _createValueFromString('12:3');

    final result = inputFormatter.formatEditUpdate(oldValue, newValue);

    expect(result.text, newValue.text);
    expect(result.selection, newValue.selection);
  });

  test('Should not allow typing a fifth digit', () {
    final oldValue = _createValueFromString('12:34');
    final newValue = _createValueFromString('12:345');

    final result = inputFormatter.formatEditUpdate(oldValue, newValue);

    expect(result, oldValue);
  });

  test('Should remove the second digit if deleting the colon', () {
    final oldValue = _createValueFromString('12:');
    final newValue = _createValueFromString('12');

    final result = inputFormatter.formatEditUpdate(oldValue, newValue);

    expect(result.text, '1');
    expect(result.selection, const TextSelection.collapsed(offset: 1));
  });

  test('Should not do anything if deleting any digit except for the colon', () {
    final oldValue = _createValueFromString('11:2');
    final newValue = _createValueFromString('11:');

    final result = inputFormatter.formatEditUpdate(oldValue, newValue);

    expect(result.text, newValue.text);
    expect(result.selection, newValue.selection);
  });

  test('Should not do anything if deleting a selection', () {
    final oldValue = _createValueFromString('11:2');
    final newValue = _createValueFromString('1');

    final result = inputFormatter.formatEditUpdate(oldValue, newValue);

    expect(result.text, newValue.text);
    expect(result.selection, TextSelection.collapsed(offset: newValue.text.length));
  });

  test('Should move the selection correctly if inserting a digit', () {
    final oldValue = _createValueFromString('11:');
    final newValue = _createValueFromString('12:1', carretPosition: 2);

    final result = inputFormatter.formatEditUpdate(oldValue, newValue);

    expect(result.text, newValue.text);
    expect(result.selection, const TextSelection.collapsed(offset: 3));
  });
}

TextEditingValue _createValueFromString(String value, {int? carretPosition}) {
  return TextEditingValue(
    text: value,
    selection: TextSelection.collapsed(offset: carretPosition ?? value.length),
  );
}
