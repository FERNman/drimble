import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../common/widgets/extended_app_bar.dart';

class OnboardingAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int stepNumber;
  final String title;

  const OnboardingAppBar({required this.stepNumber, required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return ExtendedAppBar.large(
      leading: IconButton(
        onPressed: () => context.router.pop(),
        icon: const Icon(Icons.arrow_back_ios_new),
      ),
      actions: [Text('$stepNumber/5')],
      title: Text(title),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(92 + 32); // TODO: Remove hard-coded height
}
