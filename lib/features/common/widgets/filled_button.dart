import 'package:flutter/material.dart';

class FilledButton extends StatelessWidget {
  final GestureTapCallback onPressed;
  final Widget child;

  const FilledButton({required this.onPressed, required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: theme.colorScheme.onPrimary,
        backgroundColor: theme.colorScheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
      ),
      onPressed: onPressed,
      child: child,
    );
  }
}
