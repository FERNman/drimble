import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat, NumberFormat;

import '../../../infra/extensions/to_string_as_float.dart';
import '../../common/build_context_extensions.dart';
import '../../common/line_chart/draw_dashed_line.dart';
import '../../common/number_text_style.dart';

class WeeklyAlcoholPerDayChart extends StatelessWidget {
  final Map<DateTime, double?> alcoholPerDayThisWeek;
  final double averageThisWeek;
  final double changeToLastWeek;

  final double height;

  const WeeklyAlcoholPerDayChart({
    required this.alcoholPerDayThisWeek,
    required this.averageThisWeek,
    required this.changeToLastWeek,
    required this.height,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat.E();
    final labels = alcoholPerDayThisWeek.keys
        .map(
          (date) => TextSpan(
            text: dateFormatter.format(date),
            style: context.textTheme.labelMedium?.copyWith(color: Colors.black54),
          ),
        )
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle(context),
            const SizedBox(height: 4),
            Text.rich(
              TextSpan(
                children: [
                  _buildChangeIndicator(context),
                  TextSpan(text: context.l18n.analytics_changeFromLastWeek),
                ],
              ),
              style: context.textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            CustomPaint(
              size: Size(double.infinity, height),
              painter: _BarChartPainter(
                data: alcoholPerDayThisWeek.values.toList(),
                labels: labels,
                valueLabelStyle: context.textTheme.labelMedium!.copyWith(color: Colors.black87),
                color: context.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: context.textTheme.bodyLarge,
        children: [
          TextSpan(text: '${averageThisWeek.round()}g ', style: NumberTextStyle.style),
          TextSpan(text: context.l18n.analytics_averageAlcoholPerSession),
        ],
      ),
    );
  }

  TextSpan _buildChangeIndicator(BuildContext context) {
    final formatter = NumberFormat.percentPattern();

    if (changeToLastWeek > 0) {
      final formatted = formatter.format(changeToLastWeek);
      return TextSpan(
          text: '▲ $formatted ', style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.error));
    } else if (changeToLastWeek == 0) {
      return TextSpan(text: '± 0% ', style: context.textTheme.bodySmall?.copyWith(color: Colors.black54));
    } else {
      final formatted = formatter.format(changeToLastWeek.abs());
      return TextSpan(text: '▼ $formatted ', style: context.textTheme.bodySmall?.copyWith(color: Colors.green));
    }
  }
}

class _BarChartPainter extends CustomPainter {
  static const _labelPadding = 8.0;
  static const _barWidth = 12.0;

  final List<double?> data;
  final Color color;

  /// Keep painters because layouting is expensive apparently
  /// (see first comment https://stackoverflow.com/q/41371449/4471085)
  final List<TextPainter> _labelPainters;
  final List<TextPainter?> _valueLabelPainters;

  /// The spacing at the bottom below the actual chart where the labels for the days are displayed
  late final double _labelSpacing;

  _BarChartPainter({
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
    // At least 1 to avoid division by 0
    final maxValue = data.whereNotNull().fold(1.0, max);

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

      final valueLabelPainter = _valueLabelPainters[i];
      final valueLabelSpacing = valueLabelPainter?.height ?? 0;

      final chartHeight = size.height - _labelSpacing - valueLabelSpacing;
      var barHeight = (value / maxValue) * chartHeight;
      if (barHeight == 0.0) {
        barHeight = 2.0;
      }

      final barCenter = Offset(centerX, chartHeight - barHeight * 0.5 + valueLabelSpacing);

      canvas.drawRect(
        Rect.fromCenter(center: barCenter, width: _barWidth, height: barHeight),
        barPaint,
      );

      valueLabelPainter?.paint(
        canvas,
        Offset(centerX - valueLabelPainter.width * 0.5, chartHeight - barHeight),
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
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) => data != oldDelegate.data;
}
