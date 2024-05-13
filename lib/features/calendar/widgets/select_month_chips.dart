import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/date.dart';
import '../../../infra/extensions/format_date.dart';

class SelectMonthChips extends StatelessWidget {
  final Date _currentMonth = Date.today().floorToMonth();

  final Date selectedMonth;
  final ValueChanged<Date> onMonthSelected;

  SelectMonthChips({
    required this.selectedMonth,
    required this.onMonthSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('${DateFormat.ABBR_STANDALONE_MONTH} yyyy');

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        reverse: true,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final month = _currentMonth.subtract(months: index);
          final isSelected = selectedMonth == month;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InputChip(
              label: Text(dateFormat.formatDate(month)),
              side: isSelected ? BorderSide.none : null,
              selected: selectedMonth == month,
              onSelected: (selected) {
                if (selected) {
                  onMonthSelected(month);
                }
              },
            ),
          );
        },
      ),
    );
  }
}
