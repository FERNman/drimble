import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../router.dart';
import '../common/build_context_extensions.dart';
import 'onboarding_cubit.dart';
import 'widgets/gender_selection.dart';
import 'widgets/onboarding_app_bar.dart';

class OnboardingSelectGenderPage extends StatelessWidget {
  const OnboardingSelectGenderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: OnboardingAppBar(
        stepNumber: 1,
        title: context.l18n.onboarding_genderSelectionTitle,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(children: [
            Text(context.l18n.onboarding_genderSelectionDescription, style: context.textTheme.bodyMedium),
            const SizedBox(height: 24),
            BlocBuilder<OnboardingCubit, OnboardingCubitState>(
              builder: (context, state) => GenderSelection(
                selection: state.gender,
                onSelectionChange: (gender) {
                  final cubit = context.read<OnboardingCubit>();
                  cubit.setGender(gender);
                },
              ),
            ),
            const Spacer(),
            Center(
              child: OutlinedButton(
                onPressed: () => context.router.push(const OnboardingSelectBirthyearRoute()),
                child: Text(context.l18n.common_continue),
              ),
            )
          ]),
        ),
      ),
    );
  }
}
