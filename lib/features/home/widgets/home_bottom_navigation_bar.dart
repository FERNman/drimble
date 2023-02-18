import 'package:flutter/material.dart';

import '../../common/build_context_extensions.dart';

class HomeNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const HomeNavigationBar({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 24,
      shadowColor: Colors.black,
      color: Colors.white,
      child: SafeArea(
        minimum: const EdgeInsets.only(bottom: 4),
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BottomNavigationBarElement(
                icon: Icons.water_drop_outlined,
                label: context.l18n.home_appBarDiary,
                onTap: () => onTap(0),
                isSelected: currentIndex == 0,
              ),
              const SizedBox(width: 48),
              _BottomNavigationBarElement(
                icon: Icons.bubble_chart_outlined,
                label: context.l18n.home_appBarAnalytics,
                onTap: () => onTap(1),
                isSelected: currentIndex == 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavigationBarElement extends StatelessWidget {
  final String label;
  final IconData icon;
  final GestureTapCallback onTap;
  final bool isSelected;

  const _BottomNavigationBarElement({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 128,
      child: TextButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: DefaultTextStyle(
          style: context.textTheme.labelLarge!.copyWith(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
          child: Text(label),
        ),
      ),
    );
  }
}
