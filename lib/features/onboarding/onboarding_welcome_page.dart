import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../router.dart';
import '../common/build_context_extensions.dart';
import 'onboarding_cubit.dart';

class OnboardingWelcomePage extends StatelessWidget {
  const OnboardingWelcomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text(
                context.l18n.onboarding_welcomeToDrinkaware,
                style: context.textTheme.headlineLarge?.copyWith(color: Colors.black87),
              ),
              const SizedBox(height: 24),
              const Center(child: Image(image: AssetImage('assets/images/onboarding_welcome.png'))),
              const Spacer(),
              Text(context.l18n.onboarding_howCanICallYou, style: context.textTheme.bodyLarge),
              const SizedBox(height: 4),
              _enterFirstNameTextField(context),
              const SizedBox(height: 24),
              BlocBuilder<OnboardingCubit, OnboardingCubitState>(builder: (context, state) {
                return Center(child: _getStartedButton(context, enabled: state.firstName.isNotEmpty));
              })
            ],
          ),
        ),
      ),
    );
  }

  Widget _enterFirstNameTextField(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        filled: true,
        fillColor: context.colorScheme.surfaceVariant,
        enabledBorder: const UnderlineInputBorder(),
        focusedBorder: const UnderlineInputBorder(),
        hintText: context.l18n.onboarding_enterFirstName,
      ),
      onChanged: (value) {
        final cubit = context.read<OnboardingCubit>();
        cubit.setFirstName(value);
      },
    );
  }

  Widget _getStartedButton(BuildContext context, {required bool enabled}) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: context.colorScheme.primary,
        foregroundColor: context.colorScheme.onPrimary,
        disabledBackgroundColor: context.theme.disabledColor,
        padding: const EdgeInsets.symmetric(horizontal: 48.0),
      ),
      onPressed: enabled ? () => context.router.push(const OnboardingSelectGenderRoute()) : null,
      child: const Text('Get started'),
    );
  }
}
