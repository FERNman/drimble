import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../router.gr.dart';
import '../common/build_context_extensions.dart';
import 'onboarding_cubit.dart';
import 'widgets/onboarding_app_bar.dart';

@RoutePage()
class OnboardingEnterNamePage extends StatelessWidget {
  const OnboardingEnterNamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: OnboardingAppBar(
        stepNumber: 1,
        title: context.l10n.onboarding_firstNameTitle,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 24),
              _enterFirstNameTextField(context),
              const Spacer(),
              Center(
                child: OutlinedButton(
                  onPressed: () => context.router.push(const OnboardingSelectGenderRoute()),
                  child: Text(context.l10n.common_continue),
                ),
              )
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
        hintText: context.l10n.onboarding_firstNameHint,
      ),
      textCapitalization: TextCapitalization.words,
      onChanged: (value) {
        final cubit = context.read<OnboardingCubit>();
        cubit.setName(value);
      },
    );
  }
}
