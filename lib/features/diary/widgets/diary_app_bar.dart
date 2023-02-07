import 'package:flutter/material.dart';

import '../../common/build_context_extensions.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final GestureTapCallback onTapProfile;

  const HomeAppBar({required this.onTapProfile, super.key});

  @override
  Widget build(BuildContext context) {
    final titleStyle = context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.75);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        child: Row(
          children: [
            Text('drimble', style: titleStyle),
            const Spacer(),
            IconButton(onPressed: onTapProfile, icon: const Icon(Icons.account_circle_outlined)),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
