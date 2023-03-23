import 'package:flutter/widgets.dart';

extension NumberTextStyle on TextStyle {
  static const TextStyle style = TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins');

  TextStyle forNumbers() => merge(style);
}
