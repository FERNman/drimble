import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/bac_calulation_results.dart';
import '../../../infra/extensions/copy_date_time.dart';
import '../../../infra/extensions/floor_date_time.dart';
import '../../common/build_context_extensions.dart';
import '../../common/line_chart/horizontal_line_chart_labels.dart';
import '../../common/line_chart/line_chart.dart';

class BACChart extends StatefulWidget {
  static const timestep = Duration(minutes: 5);
  static const timeOffset = Duration(minutes: 45);
  static const displayRange = Duration(hours: 5);

  final BACCalculationResults results;
  final DateTime currentDate;

  bool get isShowingToday => DateUtils.isSameDay(currentDate, DateTime.now());

  const BACChart({
    required this.results,
    required this.currentDate,
    super.key,
  });

  @override
  State<BACChart> createState() => _BACChartState();
}

class _BACChartState extends State<BACChart> {
  DateTime __displayStart = DateTime.now();
  DateTime get _displayStart => __displayStart;

  set _displayStart(DateTime value) {
    final startTime = widget.currentDate.floorToDay(hour: 6);
    final endTime = widget.currentDate.floorToDay(hour: 6).add(const Duration(days: 1)).subtract(BACChart.displayRange);
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
      (DateTime.now().difference(_displayStart).inMinutes / BACChart.timestep.inMinutes).floor();

  @override
  void initState() {
    super.initState();

    _initializeDisplayStart();
  }

  @override
  void didUpdateWidget(BACChart oldWidget) {
    super.didUpdateWidget(oldWidget);

    _initializeDisplayStart();
  }

  @override
  void dispose() {
    refreshTimer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) => _updateAfterScrolling(details.delta.dx),
      child: LineChart(
        _getChartData(),
        height: 140,
        labels: _buildLabels(context),
        indexForSpotIndicator: _currentBacIndex,
        maxValue: widget.results.maxBAC.value,
      ),
    );
  }

  List<double> _getChartData() {
    final List<double> spots = [];

    final displayEnd = _displayStart.add(BACChart.displayRange);
    for (var time = _displayStart; time.isBefore(displayEnd); time = time.add(BACChart.timestep)) {
      final currentEntry = widget.results.getEntryAt(time);
      spots.add(currentEntry.value);
    }

    return spots;
  }

  List<ChartLabelData> _buildLabels(BuildContext context) {
    final List<ChartLabelData> data = [];

    final firstFullHour = _displayStart.copyWith(hour: _displayStart.hour + 1, minute: 0);
    final displayEnd = _displayStart.add(BACChart.displayRange);
    for (var hour = firstFullHour; hour.isBefore(displayEnd); hour = hour.add(const Duration(hours: 1))) {
      final percentageOfChart = hour.difference(_displayStart).inMinutes / BACChart.displayRange.inMinutes;

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
      _displayStart = DateTime.now().subtract(BACChart.timeOffset).floorToMinute();

      _startRedrawTimer();
    } else {
      _displayStart =
          widget.results.timeOfFirstDrink?.subtract(BACChart.timeOffset).floorToMinute() ?? widget.currentDate;
    }
  }

  void _startRedrawTimer() {
    const refreshRate = Duration(minutes: 1);
    refreshTimer = Timer.periodic(
      refreshRate,
      (t) {
        _displayStart = _displayStart.add(const Duration(minutes: 1));
      },
    );
  }

  void _updateAfterScrolling(double delta) {
    refreshTimer?.cancel();

    final updatedTime = _displayStart.subtract(Duration(minutes: delta.round()));
    _displayStart = updatedTime;
  }
}
