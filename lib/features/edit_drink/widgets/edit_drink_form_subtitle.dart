import 'package:flutter/material.dart';

class EditDrinkFormSubtitle extends StatelessWidget {
  final String text;

  const EditDrinkFormSubtitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(children: [
      Text(text, style: textTheme.bodySmall),
      const SizedBox(height: 4),
    ]);
  }
}
