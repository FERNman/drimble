import 'package:flutter/material.dart';

import '../../common/build_context_extensions.dart';

class EditDrinkFormTitle extends StatelessWidget {
  final String text;

  const EditDrinkFormTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const SizedBox(height: 16),
      Text(text, style: context.textTheme.titleMedium),
      const SizedBox(height: 4),
    ]);
  }
}
