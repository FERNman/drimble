import 'dart:io';

import 'package:flutter/material.dart';

import '../../common/build_context_extensions.dart';

class HomeBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const HomeBottomNavigationBar({
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
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BottomNavigationBarIcon(
                icon: const Icon(Icons.water_drop_outlined),
                label: context.l18n.home_appBarDiary,
                onTap: () => onTap(0),
                isSelected: currentIndex == 0,
              ),
              _BottomNavigationBarIcon(
                icon: const Icon(Icons.bubble_chart_outlined),
                label: context.l18n.home_appBarAnalytics,
                onTap: () => onTap(1),
                isSelected: currentIndex == 1,
              ),
              const SizedBox(width: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavigationBarIcon extends StatelessWidget {
  final String label;
  final Icon icon;
  final GestureTapCallback onTap;
  final bool isSelected;

  const _BottomNavigationBarIcon({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(left: 16, top: 20, right: 16, bottom: Platform.isAndroid ? 12 : 0),
        child: DefaultTextStyle(
          style: context.textTheme.labelLarge!.copyWith(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: 8),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}
