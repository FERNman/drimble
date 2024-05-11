import 'package:flutter/material.dart';

import '../../common/build_context_extensions.dart';

class DiaryWaterTracking extends StatelessWidget {
  final int amount;
  final GestureTapCallback onRemove;
  final GestureTapCallback onAdd;

  const DiaryWaterTracking({
    super.key,
    required this.amount,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.diary_water),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.l10n.diary_glassesOfWaterDescription),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 4.0,
                  runSpacing: 4.0,
                  children: [
                    ...List.generate(
                      amount,
                      (index) => IconButton(
                        icon: Image.asset('assets/icons/water_glass.png', width: 32),
                        onPressed: onAdd,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.plus_one),
                      onPressed: onRemove,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
