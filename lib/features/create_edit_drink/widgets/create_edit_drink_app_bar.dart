import 'package:flutter/material.dart';

class CreateEditDrinkAppBar extends StatelessWidget {
  final GestureTapCallback onBack;

  const CreateEditDrinkAppBar({required this.onBack, super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: onBack,
      ),
      elevation: 0,
    );
  }
}
