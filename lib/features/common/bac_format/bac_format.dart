import 'package:intl/intl.dart';
// ignore: implementation_imports
import 'package:intl/src/intl_helpers.dart' as helpers;

import '../../../domain/alcohol/percentage.dart';
import 'bac_format_symbols.dart';

class BacFormat {
  final BacFormatSymbols _symbol;
  final NumberFormat _formatter;

  factory BacFormat([String? locale]) {
    locale = helpers.verifiedLocale(locale, localeExists, null);
    final symbol = bacFormatSymbols[locale] as BacFormatSymbols;
    final formatter = NumberFormat(symbol.pattern, locale);
    return BacFormat._(symbol, formatter);
  }

  BacFormat._(this._symbol, this._formatter);

  String format(Percentage bac, {bool withSymbol = true}) {
    final formatted = _formatter.format(bac * _symbol.multiplier);
    if (withSymbol) {
      return formatted;
    } else {
      // Remove last character, which is the symbol
      return formatted.substring(0, formatted.length - 1);
    }
  }

  static bool localeExists(localeName) {
    if (localeName == null) return false;
    return bacFormatSymbols.containsKey(localeName);
  }
}
