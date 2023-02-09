import 'package:flutter/material.dart';

import '../../common/build_context_extensions.dart';

class HighestBACCard extends StatelessWidget {
  final double maxBAC;

  const HighestBACCard({required this.maxBAC, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${maxBAC.toStringAsFixed(2)}%',
              style: context.textTheme.headlineSmall?.copyWith(color: context.colorScheme.primary),
            ),
            Text(context.l18n.analytics_highestBloodAlcoholLevel, style: context.textTheme.bodyLarge),
            const SizedBox(height: 8),
            Text(
              context.l18n.analytics_maxBACInfo,
              style: context.textTheme.bodyMedium?.copyWith(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
