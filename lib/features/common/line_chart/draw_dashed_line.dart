import 'package:flutter/material.dart';

extension DashedLine on Canvas {
  static const _dashWidth = 6.0;
  static const _dashSpace = 4.0;

  void drawDashedLine(
    Offset p1,
    Offset p2,
    Paint paint, {
    double dashWidth = _dashWidth,
    double dashSpace = _dashSpace,
  }) {
    var startX = p1.dx;
    while (startX < p2.dx) {
      drawLine(Offset(startX, p1.dy), Offset(startX + _dashWidth, p2.dy), paint);
      startX += _dashWidth + _dashSpace;
    }
  }
}
