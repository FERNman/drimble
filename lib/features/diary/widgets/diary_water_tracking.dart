import 'package:flutter/material.dart';

import '../../common/build_context_extensions.dart';

class DiaryWaterTracking extends StatelessWidget {
  final int value;
  final ValueChanged<int> onValueChange;

  const DiaryWaterTracking({
    super.key,
    required this.value,
    required this.onValueChange,
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
                      value,
                      (index) => IconButton(
                        icon: Image.asset('assets/icons/water_glass.png', width: 32),
                        onPressed: () => onValueChange(value - 1),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.plus_one),
                      onPressed: () => onValueChange(value + 1),
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
