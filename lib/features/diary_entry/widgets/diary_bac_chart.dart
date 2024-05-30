import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/bac/bac_calculation_results.dart';
import '../../../domain/date.dart';
import '../../../infra/extensions/copy_date_time.dart';
import '../../common/build_context_extensions.dart';
import '../../common/line_chart/horizontal_line_chart_labels.dart';
import '../../common/line_chart/line_chart.dart';

class DiaryBACChart extends StatefulWidget {
  static const timestep = Duration(minutes: 5);
  static const timeOffset = Duration(minutes: 45);
  static const displayRange = Duration(hours: 5);

  final BACCalculationResults results;
  final Date date;

  bool get isShowingToday => date == Date.today();

  const DiaryBACChart({
    required this.results,
    required this.date,
    super.key,
  });

  @override
  State<DiaryBACChart> createState() => _DiaryBACChartState();
}

class _DiaryBACChartState extends State<DiaryBACChart> {
  DateTime __displayStart = DateTime.now();
  DateTime get _displayStart => __displayStart;

  set _displayStart(DateTime value) {
    final startTime = widget.date.toDateTime();
    final endTime = startTime.add(const Duration(days: 1)).subtract(DiaryBACChart.displayRange);
    if (value.isBefore(startTime)) {
      value = startTime;
    } else if (value.isAfter(endTime)) {
      value = endTime;
    }

    setState(() {
      __displayStart = value;
    });
  }

  Timer? refreshTimer;

  int get _currentBacIndex =>
      (DateTime.now().difference(_displayStart).inMinutes / DiaryBACChart.timestep.inMinutes).floor();

  @override
  void initState() {
    super.initState();

    _initializeDisplayStart();
  }

  @override
  void didUpdateWidget(DiaryBACChart oldWidget) {
    super.didUpdateWidget(oldWidget);

    _initializeDisplayStart();
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    refreshTimer = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onHorizontalDragUpdate: (details) => _updateAfterScrolling(details.delta.dx),
          child: LineChart(
            _getChartData(),
            height: 140,
            labels: _buildLabels(context),
            indexForSpotIndicator: _currentBacIndex,
            maxValue: widget.results.maxBAC.value,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            context.l10n.diary_bacChartDisclaimer,
            style: context.textTheme.bodySmall?.copyWith(fontSize: 10, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  List<double> _getChartData() {
    final List<double> spots = [];

    final displayEnd = _displayStart.add(DiaryBACChart.displayRange);
    for (var time = _displayStart; time.isBefore(displayEnd); time = time.add(DiaryBACChart.timestep)) {
      final currentEntry = widget.results.getEntryAt(time);
      spots.add(currentEntry.value);
    }

    return spots;
  }

  List<ChartLabelData> _buildLabels(BuildContext context) {
    final List<ChartLabelData> data = [];

    final firstFullHour = _displayStart.copyWith(hour: _displayStart.hour + 1, minute: 0);
    final displayEnd = _displayStart.add(DiaryBACChart.displayRange);
    for (var hour = firstFullHour; hour.isBefore(displayEnd); hour = hour.add(const Duration(hours: 1))) {
      final percentageOfChart = hour.difference(_displayStart).inMinutes / DiaryBACChart.displayRange.inMinutes;

      data.add(ChartLabelData(
        offset: percentageOfChart,
        child: Text(
          DateFormat(DateFormat.HOUR).format(hour),
          style: context.textTheme.labelSmall?.copyWith(color: Colors.black54),
        ),
      ));
    }

    return data;
  }

  void _initializeDisplayStart() {
    if (widget.isShowingToday) {
      _displayStart = DateTime.now().subtract(DiaryBACChart.timeOffset);

      _startRedrawTimer();
    } else {
      _displayStart = widget.results.startTime.subtract(DiaryBACChart.timeOffset);
    }
  }

  void _startRedrawTimer() {
    const refreshRate = Duration(minutes: 1);
    refreshTimer?.cancel();
    refreshTimer = Timer.periodic(refreshRate, (t) => _displayStart = _displayStart.add(refreshRate));
  }

  void _updateAfterScrolling(double delta) {
    refreshTimer?.cancel();

    final updatedTime = _displayStart.subtract(Duration(minutes: delta.round()));
    _displayStart = updatedTime;
  }
}
