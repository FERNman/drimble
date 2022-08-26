import 'package:flutter/material.dart';

class RemoveDrinkDialog extends StatelessWidget {
  final GestureTapCallback onCancel;
  final GestureTapCallback onRemove;

  const RemoveDrinkDialog({required this.onCancel, required this.onRemove, super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Remove drink'),
      content: const Text('Are you sure you want to remove this drink?'),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: onRemove,
          child: const Text('Yes'),
        ),
      ],
    );
  }
}
