import 'package:flutter/material.dart';

import '../../common/build_context_extensions.dart';

class DiaryAppBar extends StatelessWidget implements PreferredSizeWidget {
  final GestureTapCallback onTapCalendar;
  final GestureTapCallback onTapProfile;

  const DiaryAppBar({
    required this.onTapCalendar,
    required this.onTapProfile,
    super.key,
  });

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
            IconButton(onPressed: onTapCalendar, icon: const Icon(Icons.today_outlined)),
            IconButton(onPressed: onTapProfile, icon: const Icon(Icons.account_circle_outlined)),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
