import 'package:flutter/material.dart';

class ExtendedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget leading;
  final Widget title;

  const ExtendedAppBar({required this.leading, required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    final titleTextStyle = Theme.of(context).textTheme.titleLarge;

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          leading,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: DefaultTextStyle(
              style: titleTextStyle!,
              child: title,
            ),
          )
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(112);
}
