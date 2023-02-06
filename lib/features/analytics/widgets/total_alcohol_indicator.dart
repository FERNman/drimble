import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../common/build_context_extensions.dart';

class TotalAlcoholIndicator extends StatelessWidget {
  final double totalGramsOfAlcohol;
  final double changeToLastWeek;

  const TotalAlcoholIndicator({required this.totalGramsOfAlcohol, required this.changeToLastWeek, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('${totalGramsOfAlcohol.toStringAsFixed(0)}g', style: context.textTheme.displaySmall),
        const SizedBox(height: 4),
        Text(context.l18n.analytics_totalAlcoholConsumed, style: context.textTheme.bodyLarge),
        RichText(
          text: TextSpan(
            style: context.textTheme.bodySmall,
            children: [
              _buildChangeIndicator(context),
              TextSpan(text: context.l18n.analytics_changeFromLastWeek),
            ],
          ),
        )
      ],
    );
  }

  TextSpan _buildChangeIndicator(BuildContext context) {
    final formatter = NumberFormat.percentPattern();
    if (changeToLastWeek > 1) {
      final formatted = formatter.format(changeToLastWeek - 1);
      return TextSpan(
          text: '▲ $formatted ', style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.error));
    } else {
      final formatted = formatter.format(changeToLastWeek);
      return TextSpan(text: '▼ $formatted ', style: context.textTheme.bodySmall?.copyWith(color: Colors.green));
    }
  }
}
