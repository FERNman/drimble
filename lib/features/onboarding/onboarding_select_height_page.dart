import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numberpicker/numberpicker.dart';

import '../../router.gr.dart';
import '../common/build_context_extensions.dart';
import 'onboarding_cubit.dart';
import 'widgets/onboarding_app_bar.dart';

@RoutePage()
class OnboardingSelectHeightPage extends StatelessWidget {
  const OnboardingSelectHeightPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: OnboardingAppBar(
        stepNumber: 4,
        title: context.l10n.onboarding_heightSelectionTitle,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(context.l10n.onboarding_heightSelectionDescription),
              const SizedBox(height: 24),
              BlocBuilder<OnboardingCubit, OnboardingCubitState>(
                builder: (context, state) => NumberPicker(
                  value: state.height,
                  minValue: 100,
                  maxValue: 220,
                  step: 1,
                  haptics: true,
                  axis: Axis.horizontal,
                  textMapper: (numberText) => '${numberText}cm',
                  onChanged: (value) {
                    context.read<OnboardingCubit>().setHeight(value);
                  },
                ),
              ),
              const Spacer(),
              Center(
                child: OutlinedButton(
                  onPressed: () => context.router.push(const OnboardingSelectWeightRoute()),
                  child: Text(context.l10n.common_continue),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
