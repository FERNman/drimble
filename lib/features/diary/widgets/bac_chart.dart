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
  static final _currentBacIndex = (BACChart.timeOffset.inMinutes / BACChart.timestep.inMinutes).floor();

  late DateTime _displayStart;
  Timer? refreshTimer;

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
    super.dispose();

    refreshTimer?.cancel();
  }

  void _initializeDisplayStart() {
    if (widget.isShowingToday) {
      setState(() {
        _displayStart = DateTime.now().subtract(BACChart.timeOffset).floorToMinute();
      });

      _startRedrawTimer();
    } else {
      setState(() {
        _displayStart =
            widget.results.timeOfFirstDrink?.subtract(BACChart.timeOffset).floorToMinute() ?? widget.currentDate;
      });
    }
  }

  void _startRedrawTimer() {
    const refreshRate = Duration(minutes: 1);
    refreshTimer = Timer.periodic(
      refreshRate,
      (t) => setState(() {
        _displayStart = _displayStart.add(const Duration(minutes: 1));
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LineChart(
      _getChartData(),
      height: 140,
      labels: _buildLabels(context),
      indexForSpotIndicator: _currentBacIndex,
      showSpotIndicator: widget.isShowingToday,
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
}
