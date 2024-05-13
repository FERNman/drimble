import 'package:flutter/material.dart';

import '../../../domain/diary/consumed_drink.dart';
import '../../common/build_context_extensions.dart';

class DiaryQuickAddDrink extends StatelessWidget {
  final List<ConsumedDrink> recentDrinks;
  final ValueChanged<ConsumedDrink> onAddDrink;

  const DiaryQuickAddDrink({super.key, required this.recentDrinks, required this.onAddDrink});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.diary_quickAdd),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildQuickAddButton(context, recentDrinks.first),
            if (recentDrinks.length > 1) const SizedBox(width: 8),
            if (recentDrinks.length > 1) _buildQuickAddButton(context, recentDrinks[1]),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAddButton(BuildContext context, ConsumedDrink drink) {
    return Expanded(
      child: OutlinedButton.icon(
        style: ButtonStyle(
          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.all(8)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          foregroundColor: MaterialStateProperty.all<Color>(context.theme.colorScheme.onSurface),
        ),
        onPressed: () => onAddDrink(drink),
        icon: Image.asset(drink.iconPath, width: 32, height: 32),
        label: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(drink.name, style: context.theme.textTheme.labelLarge),
                Text(context.l10n.common_volume(drink.volume), style: context.theme.textTheme.labelSmall),
              ],
            ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.plus_one),
            ),
          ],
        ),
      ),
    );
  }
}
