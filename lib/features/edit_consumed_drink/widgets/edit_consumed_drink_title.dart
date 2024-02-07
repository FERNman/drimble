import 'package:flutter/material.dart';

import '../../common/build_context_extensions.dart';

class EditConsumedDrinkTitle extends StatelessWidget {
  final String name;
  final String iconPath;
  final double gramsOfAlcohol;

  const EditConsumedDrinkTitle({
    required this.name,
    required this.iconPath,
    required this.gramsOfAlcohol,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: context.textTheme.headlineMedium),
              const SizedBox(height: 4),
              RichText(
                text: TextSpan(
                  style: context.textTheme.bodyMedium,
                  children: [
                    TextSpan(text: context.l18n.edit_drink_youreAboutToConsume),
                    const TextSpan(text: ' '),
                    TextSpan(
                      text: context.l18n.edit_drink_youreAboutToConsumeGrams(gramsOfAlcohol.round()),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: ' '),
                    TextSpan(text: context.l18n.edit_drink_youreAboutToConsumeOfAlcohol),
                  ],
                ),
              ),
            ],
          ),
        ),
        Image.asset(iconPath, width: 96, height: 96, fit: BoxFit.fill)
      ],
    );
  }
}
