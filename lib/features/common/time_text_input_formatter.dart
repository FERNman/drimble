import 'dart:math' as math;
import 'dart:math';

import 'package:flutter/services.dart';

class TimeTextInputFormatter extends TextInputFormatter {
  static final _allowedInputs = RegExp(r'^[0-9:apm\s]*$', caseSensitive: false);
  static final _validTime = RegExp(r'^\d{2}:\d{2}\s?(?:[ap]|[ap]m)?$', caseSensitive: false);
  static final _timeRegex = RegExp(r'^[0-9:]{0,5}$', caseSensitive: false);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (!_allowedInputs.hasMatch(newValue.text)) {
      // The user is trying to type an invalid character
      return oldValue;
    }

    if (_validTime.hasMatch(newValue.text)) {
      // The time is already correct, the user might be adding "am" or "pm"
      // No need to format anything
      return newValue;
    }

    if (_timeRegex.hasMatch(newValue.text)) {
      return _formatTimeInput(newValue, oldValue);
    }

    return oldValue;
  }

  TextEditingValue _formatTimeInput(TextEditingValue newValue, TextEditingValue oldValue) {
    final wasDeletion = newValue.text.length < oldValue.text.length;
    if (wasDeletion) {
      return _handleDeletion(oldValue, newValue);
    } else {
      return _handleInsertion(newValue);
    }
  }

  TextEditingValue _handleDeletion(TextEditingValue oldValue, TextEditingValue newValue) {
    final hasDeletedColon = oldValue.text.replaceAll(':', '') == newValue.text;
    if (hasDeletedColon) {
      // The user has deleted the untyped colon so we should actually remove the last digit
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
