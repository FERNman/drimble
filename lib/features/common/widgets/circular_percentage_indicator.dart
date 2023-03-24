import 'dart:math';

import 'package:flutter/material.dart';

/// A stateless widget that uses the _CircularPainter to draw a circular percentage indicator
class CircularPercentageIndicator extends StatelessWidget {
  final double percentage;
  final Color backgroundColor;
  final Color foregroundColor;
  final double strokeWidth;
  final bool reverse;
  final double cutout;

  final double width;
  final double _height;

  CircularPercentageIndicator({
    required this.width,
    required this.percentage,
    required this.backgroundColor,
    required this.foregroundColor,
    this.strokeWidth = 8,
    this.reverse = false,
    this.cutout = 1 / 3,
    super.key,
  }) : _height = calculateHeightFromCutout(width, cutout, strokeWidth);

  static double calculateHeightFromCutout(double width, double cutout, double strokeWidth) {
    final radius = (width - strokeWidth) * 0.5;
    final arcLengthInRadians = pi * cutout;
    return width - radius * (1 - cos(arcLengthInRadians));
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, _height),
      painter: _CircularPainter(
        percentage: percentage,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        strokeWidth: strokeWidth,
        reverse: reverse,
        cutout: cutout,
      ),
    );
  }
}

/// A painter that draws a circular percentage indicator.
/// Draws a circle as background and an arc above it to indicate the percentage.
class _CircularPainter extends CustomPainter {
  final double percentage;
  final Color backgroundColor;
  final Color foregroundColor;
  final double strokeWidth;
  final bool reverse;
  final double cutout;

  const _CircularPainter({
    required this.percentage,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.strokeWidth,
    required this.reverse,
    required this.cutout,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // final theoreticalHeight = size.height / (1 - cutout);
    final center = Offset(size.width / 2, size.width / 2);
    final radius = size.width / 2 - strokeWidth / 2;
    final container = Rect.fromCircle(center: center, radius: radius);

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final startAngle = pi * (0.5 + cutout); // 0.5 * pi = start at bottom center
    final sweepAngle = 2 * pi * (1 - cutout);
    canvas.drawArc(container, startAngle, sweepAngle, false, backgroundPaint);

    final arcPaint = Paint()
      ..color = foregroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final percentageSweepAngle = sweepAngle * percentage * (reverse ? -1 : 1);
    canvas.drawArc(container, reverse ? (0.5 * pi - cutout * pi) : startAngle, percentageSweepAngle, false, arcPaint);
  }

  @override
  bool shouldRepaint(_CircularPainter oldDelegate) => oldDelegate.percentage != percentage;
}
