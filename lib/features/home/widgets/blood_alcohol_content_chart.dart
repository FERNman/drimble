import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BloodAlcoholContentChart extends StatelessWidget {
  final Map<DateTime, double> bloodAlcoholContent;

  const BloodAlcoholContentChart({required this.bloodAlcoholContent, super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: AspectRatio(
        aspectRatio: 2,
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
                isCurved: true,
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
                  getTitlesWidget: _constructTitles,
                  interval: 0.01,
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            gridData: FlGridData(show: false),
            lineTouchData: LineTouchData(
              getTouchLineEnd: (barData, spotIndex) => 0,
              getTouchLineStart: (barData, spotIndex) => 0,
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: _constructTooltips,
              ),
            ),
          ),
          swapAnimationDuration: const Duration(seconds: 1),
        ),
      ),
    );
  }

  Widget _constructTitles(double value, TitleMeta meta) {
    if (value == meta.max || value == meta.min) {
      return const SizedBox();
    }

    final DateTime minDate = bloodAlcoholContent.keys.reduce((value, it) => (it.isBefore(value)) ? it : value);
    final DateTime maxDate = bloodAlcoholContent.keys.reduce((value, it) => (it.isAfter(value)) ? it : value);
    final timespan = maxDate.difference(minDate);

    final currentTime = minDate.add(Duration(minutes: (timespan.inMinutes * value).round()));
    if (currentTime.minute < 1) {
      return SideTitleWidget(
        axisSide: meta.axisSide,
        space: 4,
        child: Text(DateFormat(DateFormat.HOUR).format(currentTime)),
      );
    }

    return const SizedBox();
  }

  List<LineTooltipItem> _constructTooltips(List<LineBarSpot> touchedSpots) {
    return touchedSpots
        .map((e) => LineTooltipItem('${e.y.toStringAsFixed(2)}‰', const TextStyle(color: Colors.white)))
        .toList();
  }

  List<FlSpot> _getSpots() {
    if (bloodAlcoholContent.isEmpty) {
      return [];
    }

    final DateTime minDate = bloodAlcoholContent.keys.reduce((value, it) => (it.isBefore(value)) ? it : value);
    final DateTime maxDate = bloodAlcoholContent.keys.reduce((value, it) => (it.isAfter(value)) ? it : value);
    final timespan = maxDate.difference(minDate);

    final List<FlSpot> spots = [];
    bloodAlcoholContent.forEach((key, value) {
      spots.add(FlSpot(key.difference(minDate).inMinutes / timespan.inMinutes, value));
    });

    return spots;
  }
}
