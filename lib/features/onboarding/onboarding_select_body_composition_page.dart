import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../router.dart';
import '../common/build_context_extensions.dart';
import 'onboarding_cubit.dart';
import 'widgets/body_composition_selection.dart';
import 'widgets/onboarding_app_bar.dart';

class OnboardingSelectBodyCompositionPage extends StatelessWidget {
  const OnboardingSelectBodyCompositionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: OnboardingAppBar(
        stepNumber: 5,
        title: context.l18n.onboarding_bodyCompositionSelectionTitle,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(context.l18n.onboarding_bodyCompositionSelectionDescription),
            ),
            const SizedBox(height: 24),
            BlocBuilder<OnboardingCubit, OnboardingCubitState>(
              builder: (context, state) => BodyCompositionSelection(
                selection: state.bodyComposition,
                onSelectionChange: (selection) {
                  context.read<OnboardingCubit>().setBodyComposition(selection);
                },
              ),
            ),
            const Spacer(),
            Center(
              child: OutlinedButton(
                onPressed: () {
                  context.read<OnboardingCubit>().save();
                  context.router.replaceAll([const HomeRoute()]);
                },
                child: Text(context.l18n.onboarding_finish),
              ),
            )
          ],
        ),
      ),
    );
  }
}
