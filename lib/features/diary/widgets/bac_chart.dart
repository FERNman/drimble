import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/bac_calulation_results.dart';
import '../../../infra/extensions/floor_date_time.dart';
import 'bac_chart_title.dart';

class BACChart extends StatefulWidget {
  static const timestep = Duration(minutes: 5);
  static const timeOffset = Duration(minutes: 30);
  static const displayRange = Duration(hours: 5);

  final BACCalculationResults results;

  const BACChart({required this.results, super.key});

  @override
  State<BACChart> createState() => _BACChartState();
}

class _BACChartState extends State<BACChart> {
  final int currentBacIndex = (BACChart.timeOffset.inMinutes / BACChart.timestep.inMinutes).floor();
  DateTime displayStart = DateTime.now().subtract(BACChart.timeOffset).floorToMinute();

  List<LineBarSpot> touchedSpots = [];

  late final Timer refreshTimer;

  @override
  void initState() {
    super.initState();

    refreshTimer = Timer.periodic(
      const Duration(minutes: 1),
      (t) => setState(() {
        displayStart = DateTime.now().subtract(BACChart.timeOffset).floorToMinute();
      }),
    );
  }

  @override
  void dispose() {
    super.dispose();

    refreshTimer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        BACChartTitle(
          currentBAC: widget.results.getBACAt(DateTime.now()).value,
          maxBAC: widget.results.maxBAC,
          soberAt: widget.results.soberAt,
        ),
        const SizedBox(height: 18),
        AspectRatio(
          aspectRatio: 2.5,
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: _getSpots(),
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary.withOpacity(0.1),
                        colorScheme.primary.withOpacity(0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  color: colorScheme.primary,
                  showingIndicators: [currentBacIndex, ...touchedSpots.map((e) => e.spotIndex)],
                  isCurved: false,
                )
              ],
              titlesData: FlTitlesData(
                show: true,
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: _constructTitle,
                    reservedSize: 28,
                    interval: 1.0 / BACChart.displayRange.inMinutes,
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(show: false),
              showingTooltipIndicators: [ShowingTooltipIndicators(touchedSpots)],
              lineTouchData: LineTouchData(
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: _constructTooltips,
                  tooltipBgColor: Colors.black54,
                ),
                getTouchedSpotIndicator: (barData, indicators) => _constructTouchIndicator(
                  colorScheme,
                  barData,
                  indicators,
                ),
                handleBuiltInTouches: false,
                touchCallback: _touchCallback,
              ),
            ),
            swapAnimationDuration: const Duration(milliseconds: 500),
          ),
        ),
      ],
    );
  }

  List<FlSpot> _getSpots() {
    final List<FlSpot> spots = [];

    final displayEnd = displayStart.add(BACChart.displayRange);
    for (var time = displayStart; time.isBefore(displayEnd); time = time.add(BACChart.timestep)) {
      final currentEntry = widget.results.getBACAt(time);
      final percentageOfChart = time.difference(displayStart).inMinutes / BACChart.displayRange.inMinutes;

      spots.add(FlSpot(percentageOfChart, currentEntry.value));
    }

    return spots;
  }

  Widget _constructTitle(double value, TitleMeta meta) {
    final minutesFromValue = Duration(minutes: (BACChart.displayRange.inMinutes * value).round());
    final currentTime = displayStart.add(minutesFromValue);

    if (currentTime.minute == 0) {
      // If this is a full hour, display the title
      return SideTitleWidget(
        axisSide: meta.axisSide,
        space: 10,
        child: Text(DateFormat(DateFormat.HOUR).format(currentTime), style: const TextStyle(color: Colors.black54)),
      );
    } else {
      return const SizedBox();
    }
  }

  List<LineTooltipItem> _constructTooltips(List<LineBarSpot> touchedSpots) {
    return touchedSpots
        .map((e) => LineTooltipItem('${e.y.toStringAsFixed(2)}‰', const TextStyle(color: Colors.white)))
        .toList();
  }

  List<TouchedSpotIndicatorData> _constructTouchIndicator(
    ColorScheme scheme,
    LineChartBarData barData,
    List<int> indicators,
  ) {
    return indicators
        .map((index) => TouchedSpotIndicatorData(
              FlLine(color: Colors.transparent, strokeWidth: 0),
              FlDotData(
                getDotPainter: (spot, percent, bar, index) => _TouchIndicatorPainter(
                  fillColor: scheme.primary,
                  borderColor: Colors.white,
                  shadowColor: scheme.shadow,
                ),
              ),
            ))
        .toList();
  }

  void _touchCallback(FlTouchEvent event, LineTouchResponse? response) {
    if (event is FlPanDownEvent || event is FlPanStartEvent || event is FlPanUpdateEvent) {
      if (response?.lineBarSpots != null) {
        setState(() {
          touchedSpots = response!.lineBarSpots!;
        });
      }
    } else if (event is FlPanEndEvent || event is FlPanCancelEvent) {
      setState(() {
        touchedSpots = [];
      });
    }
  }
}

class _TouchIndicatorPainter extends FlDotPainter {
  final double radius = 4.0;
  final Color fillColor;
  final double borderRadius = 2.0;
  final Color borderColor;
  final double shadowRadius = 2.0;
  final Color shadowColor;

  _TouchIndicatorPainter({
    this.fillColor = Colors.black,
    this.borderColor = Colors.grey,
    this.shadowColor = Colors.black45,
  });

  /// Implementation of the parent class to draw the circle
  @override
  void draw(Canvas canvas, FlSpot spot, Offset offsetInCanvas) {
    final path = Path()
      ..addOval(Rect.fromCircle(
        center: offsetInCanvas,
        radius: radius + borderRadius + shadowRadius,
      ));

    canvas.drawShadow(path, shadowColor, 3.0, false);

    // Border
    canvas.drawCircle(
      offsetInCanvas,
      radius + borderRadius,
      Paint()
        ..color = borderColor
        ..strokeWidth = borderRadius * 2.0
        ..style = PaintingStyle.stroke,
    );

    // Fill
    canvas.drawCircle(
      offsetInCanvas,
      radius,
      Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill,
    );
  }

  @override
  Size getSize(FlSpot spot) {
    return Size((radius + borderRadius) * 2, (radius + borderRadius) * 2);
  }

  @override
  List<Object?> get props => [];
}
