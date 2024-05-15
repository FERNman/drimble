import 'package:flutter/material.dart';

import '../../common/build_context_extensions.dart';

class SignInWithGoogleButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SignInWithGoogleButton({required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        backgroundColor: const Color(0xff4285f4), // Official Google color
        foregroundColor: Colors.white,
      ),
      child: Text(context.l10n.sign_in_signInWithGoogle),
    );
  }
}
