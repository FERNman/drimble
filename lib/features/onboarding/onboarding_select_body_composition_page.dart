import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/user/body_composition.dart';
import '../../router.dart';
import '../common/build_context_extensions.dart';
import '../common/l18n/body_composition_translations.dart';
import 'onboarding_cubit.dart';
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
              builder: (context, state) => DropdownButtonFormField(
                decoration: InputDecoration(
                  label: Text(context.l18n.onboarding_bodyCompositionSelectionLabel),
                ),
                items: BodyComposition.values
                    .map((e) => DropdownMenuItem(value: e, child: Text(e.translate(context))))
                    .toList(),
                onChanged: (value) {
                  if (value is BodyComposition) {
                    context.read<OnboardingCubit>().setBodyComposition(value);
                  }
                },
              ),
            ),
            const Spacer(),
            Center(
              child: OutlinedButton(
                onPressed: () {
                  context.read<OnboardingCubit>().save();
                  context.router.replaceAll([const DiaryRoute()]);
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
