import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/bac_calulation_results.dart';

class BACChartTitle extends StatelessWidget {
  final double currentBAC;
  final BACEntry maxBAC;
  final DateTime soberAt;

  const BACChartTitle({required this.currentBAC, required this.maxBAC, required this.soberAt, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        children: [
          Text(
            '${currentBAC.toStringAsFixed(2)}‰',
            style: theme.textTheme.displaySmall?.copyWith(color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(_subtitle(), style: theme.textTheme.bodyMedium)
        ],
      ),
    );
  }

  String _subtitle() {
    final dateFormat = DateFormat(DateFormat.HOUR_MINUTE);

    final now = DateTime.now();
    if (maxBAC.time.isAfter(now)) {
      return 'reaches ${maxBAC.value.toStringAsFixed(2)}‰ at ${dateFormat.format(maxBAC.time)}';
    } else if (soberAt.isAfter(now)) {
      return 'sober at ${dateFormat.format(soberAt)}';
    } else {
      return 'you\'re sober! 🎉';
    }
  }
}
