import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../build_context_extensions.dart';
import 'horizontal_line_chart_labels.dart';
import 'nice_double.dart';
import 'normalize_list.dart';
import 'vertical_line_chart_labels.dart';

class LineChart extends StatelessWidget {
  final List<double> data;
  final List<ChartLabelData> labels;
  final double height;
  final Color? color;
  final int indexForSpotIndicator;

  final double _valueRange;

  LineChart(
    this.data, {
    required this.labels,
    required this.indexForSpotIndicator,
    this.color,
    this.height = 110,
    super.key,
  })  : assert(data.isNotEmpty),
        _valueRange = _notNull(data.reduce(max).ceilToNiceDouble());

  static double _notNull(double number) => number == 0.0 ? 1.0 : number;

  @override
  Widget build(BuildContext context) {
    final color = this.color ?? context.colorScheme.primary;

    return Column(
      children: [
        Stack(
          children: [
            VerticalLineChartLabels(
              height: height,
              range: _valueRange,
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 8, // TODO: Remove hard-coded offsets, they are basecd on the labels' size
              bottom: 8,
              child: CustomPaint(
                size: Size(double.infinity, height),
                painter: _ChartPainter(
                  data: data.normalize(_valueRange),
                  color: color,
                  gradient: [color.withOpacity(0.1), color.withOpacity(0.0)],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 8,
              bottom: 8,
              child: CustomPaint(
                size: Size(double.infinity, height),
                painter: _ChartDotPainter(
                  center: Offset(indexForSpotIndicator / data.length, data[indexForSpotIndicator] / _valueRange),
                  fillColor: context.colorScheme.primary,
                  borderColor: Colors.white,
                  shadowColor: context.colorScheme.shadow,
                ),
              ),
            ),
          ],
        ),
        HorizontalLineChartLabels(items: labels),
      ],
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<double> data;

  final Color color;
  final List<Color> gradient;

  const _ChartPainter({
    required this.data,
    required this.color,
    required this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawPath(_drawPath(size, false), linePaint);

    final gradientPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = ui.Gradient.linear(Offset.zero, Offset(0, size.height), gradient);

    canvas.drawPath(_drawPath(size, true), gradientPaint);
  }

  @override
  bool shouldRepaint(_ChartPainter oldDelegate) => oldDelegate.data != data;

  Path _drawPath(Size size, bool closePath) {
    final segmentWidth = size.width / data.length;

    final path = Path()..moveTo(0, size.height - data[0] * size.height);

    for (var i = 1; i < data.length; i++) {
      final x = i * segmentWidth;
      final y = size.height - (data[i] * size.height);
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height - data[data.length - 1] * size.height);

    // for the gradient fill, we want to close the path
    if (closePath) {
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    }

    return path;
  }
}

class _ChartDotPainter extends CustomPainter {
  final double radius = 4.0;
  final Color fillColor;
  final double borderRadius = 2.0;
  final Color borderColor;
  final double shadowRadius = 2.0;
  final Color shadowColor;

  // This is normalized, has to be adapted for size
  final Offset center;

  _ChartDotPainter({
    required this.center,
    required this.fillColor,
    required this.borderColor,
    this.shadowColor = Colors.black45,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final actualCenter = Offset(center.dx * size.width, size.height - center.dy * size.height);

    // Shadow
    final path = Path()
      ..addOval(Rect.fromCircle(
        center: actualCenter,
        radius: radius + borderRadius + shadowRadius,
      ));

    canvas.drawShadow(path, shadowColor, 2.0, false);

    // Border
    canvas.drawCircle(
      actualCenter,
      radius + borderRadius,
      Paint()
        ..color = borderColor
        ..strokeWidth = borderRadius * 2.0
        ..style = PaintingStyle.stroke,
    );

    // Fill
    canvas.drawCircle(
      actualCenter,
      radius,
      Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_ChartDotPainter old) => old.center != center;
}
