import 'package:flutter/material.dart';

class ExtendedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget leading;
  final List<Widget> actions;
  final Widget title;

  final double spacing;

  const ExtendedAppBar.large({
    required this.leading,
    this.actions = const [],
    required this.title,
    super.key,
  }) : spacing = 32.0;

  const ExtendedAppBar.medium({
    required this.leading,
    required this.title,
    this.actions = const [],
    super.key,
  }) : spacing = 16.0;

  @override
  Widget build(BuildContext context) {
    final titleTextStyle = Theme.of(context).textTheme.titleLarge;

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [leading, const Spacer(), ...actions, const SizedBox(width: 16)]),
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 16, right: 16),
            child: DefaultTextStyle(
              style: titleTextStyle!,
              child: title,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(92.0 + spacing); // TODO: Remove hard-coded height
}
