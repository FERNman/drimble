import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../common/build_context_extensions.dart';

class DiaryCalendarDay extends StatelessWidget {
  static const double width = 72;
  static const double height = 92;

  final DateTime date;
  final bool isSelected;
  final bool? isDrinkFreeDay;
  final GestureTapCallback? onTap;

  const DiaryCalendarDay({
    required this.date,
    required this.isSelected,
    required this.isDrinkFreeDay,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final dayOfWeek = DateFormat(DateFormat.ABBR_WEEKDAY).format(date);
    final formattedDate = DateFormat('dd').format(date);

    final dayOfWeekTextStyle = context.textTheme.labelSmall?.copyWith(
      color: onTap == null ? Colors.black26 : Colors.black87,
      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
    );

    final dateTextStyle = context.textTheme.titleMedium?.copyWith(
      color: onTap == null ? Colors.black26 : Colors.black87,
      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
    );

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        border: isSelected ? Border.all() : null,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(dayOfWeek.toLowerCase(), style: dayOfWeekTextStyle),
              Text(formattedDate, style: dateTextStyle),
              const SizedBox(height: 8),
              _drawCircleIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawCircleIndicator() {
    final container = Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getColor(),
      ),
    );

    if (isDrinkFreeDay == null) {
      return DottedBorder(
        color: onTap == null ? Colors.black26 : Colors.black87,
        borderType: BorderType.Circle,
        dashPattern: const <double>[2, 3],
        padding: EdgeInsets.zero,
        child: container,
      );
    } else {
      return container;
    }
  }

  Color _getColor() {
    if (isDrinkFreeDay == null) {
      return Colors.transparent;
    } else if (isDrinkFreeDay == true) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }
}
