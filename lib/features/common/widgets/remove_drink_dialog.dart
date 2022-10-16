import 'package:flutter/material.dart';

import '../build_context_extensions.dart';

class RemoveDrinkDialog extends StatelessWidget {
  final GestureTapCallback onCancel;
  final GestureTapCallback onRemove;

  const RemoveDrinkDialog({required this.onCancel, required this.onRemove, super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l18n.remove_drink_title),
      content: Text(context.l18n.remove_drink_description),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: Text(context.l18n.remove_drink_cancel),
        ),
        TextButton(
          onPressed: onRemove,
          child: Text(context.l18n.remove_drink_yes),
        ),
      ],
    );
  }
}
