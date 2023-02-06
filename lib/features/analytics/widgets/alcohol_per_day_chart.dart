import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../../infra/extensions/to_string_as_float.dart';
import '../../common/build_context_extensions.dart';
import '../../common/line_chart/draw_dashed_line.dart';

class AlcoholPerDayChart extends StatelessWidget {
  final List<double?> data;
  final List<TextSpan> labels;
  final double height;

  const AlcoholPerDayChart({required this.data, required this.labels, required this.height, super.key});

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme.primary;

    return CustomPaint(
      size: Size(double.infinity, height),
      painter: _ChartPainter(
        data: data,
        labels: labels,
        valueLabelStyle: context.textTheme.labelMedium!,
        color: color,
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  static const _labelPadding = 8.0;
  static const _barWidth = 12.0;

  final List<double?> data;
  final Color color;

  // Keep painters because layouting is expensive apparently
  // (see first comment https://stackoverflow.com/q/41371449/4471085)
  final List<TextPainter> _labelPainters;
  final List<TextPainter?> _valueLabelPainters;

  // The spacing at the bottom below the actual chart where the labels for the days are displayed
  late final double _labelSpacing;

  _ChartPainter({
    required this.data,
    required List<TextSpan> labels,
    required TextStyle valueLabelStyle,
    required this.color,
  })  : _labelPainters = labels
            .map((l) => TextPainter(
                  text: l,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.ltr,
                ))
            .toList(),
        _valueLabelPainters = data
            .map((v) => v == null
                ? null
                : TextPainter(
                    text: TextSpan(text: v.toStringAsFloat(1), style: valueLabelStyle),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.ltr,
                  ))
            .toList() {
    for (final element in _labelPainters) {
      element.layout();
    }

    for (final element in _valueLabelPainters) {
      element?.layout();
    }

    _labelSpacing = _labelPainters.fold(_labelPadding, (height, el) => max(height, el.height + _labelPadding));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final spacing = size.width / data.length;
    final maxValue = data.whereNotNull().fold(0.0, max);

    final barPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    for (var i = 0; i < data.length; i++) {
      final value = data[i];
      final centerX = spacing * i + spacing * 0.5;

      final labelPainter = _labelPainters[i];
      labelPainter.paint(
        canvas,
        Offset(centerX - labelPainter.width * 0.5, size.height - labelPainter.height),
      );

      // If the current day has no value yet, don't draw a bar in the chart
      if (value == null) {
        continue;
      }

      final chartHeight = size.height - _labelSpacing;

      var barHeight = (value / maxValue) * chartHeight;
      if (barHeight == 0.0) {
        barHeight = 2.0;
      }

      final barCenter = Offset(centerX, chartHeight - barHeight * 0.5);

      canvas.drawRect(
        Rect.fromCenter(center: barCenter, width: _barWidth, height: barHeight),
        barPaint,
      );

      final valueLabelPainter = _valueLabelPainters[i];
      valueLabelPainter?.paint(
        canvas,
        Offset(centerX - valueLabelPainter.width * 0.5, chartHeight - barHeight - valueLabelPainter.height),
      );
    }

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = color;

    canvas.drawDashedLine(
      Offset(0.0, size.height - _labelSpacing),
      Offset(size.width, size.height - _labelSpacing),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) => data != oldDelegate.data;
}
