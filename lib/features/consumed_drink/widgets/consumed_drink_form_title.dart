import 'package:flutter/material.dart';

class ConsumedDrinkFormTitle extends StatelessWidget {
  final String text;

  const ConsumedDrinkFormTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(children: [
      const SizedBox(height: 16),
      Text(text, style: textTheme.titleMedium),
      const SizedBox(height: 4),
    ]);
  }
}
