import 'dart:math';
import 'dart:math' as math;

import 'package:flutter/services.dart';

class TimeTextInputFormatter extends TextInputFormatter {
  final _exp = RegExp(r'^[0-9:]{0,5}$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (_exp.hasMatch(newValue.text)) {
      final wasDeletion = newValue.text.length < oldValue.text.length;
      if (wasDeletion) {
        return _handleDeletion(oldValue, newValue);
      } else {
        return _handleInsertion(newValue);
      }
    }

    return oldValue;
  }

  TextEditingValue _handleDeletion(TextEditingValue oldValue, TextEditingValue newValue) {
    final hasDeletedColon = oldValue.text.replaceAll(':', '') == newValue.text;
    if (hasDeletedColon) {
      final updatedSelection = newValue.selection.copyWith(
        baseOffset: newValue.selection.baseOffset - 1,
        extentOffset: newValue.selection.extentOffset - 1,
      );

      return newValue.copyWith(
        text: newValue.text.substring(0, newValue.text.length - 1),
        selection: updatedSelection,
      );
    } else {
      return newValue;
    }
  }

  TextEditingValue _handleInsertion(TextEditingValue newValue) {
    var formattedText = newValue.text.replaceAll(':', '');
    if (formattedText.length >= 2) {
      final hours = formattedText.substring(0, 2);
      final minutes = formattedText.substring(2, min(formattedText.length, 4));
      formattedText = '$hours:$minutes';
    }

    final formattedSelection = newValue.selection.copyWith(
      baseOffset: math.min(newValue.selection.baseOffset + 1, formattedText.length),
      extentOffset: math.min(newValue.selection.extentOffset + 1, formattedText.length),
    );

    return TextEditingValue(
      text: formattedText,
      selection: formattedSelection,
      composing: TextRange.empty,
    );
  }
}
