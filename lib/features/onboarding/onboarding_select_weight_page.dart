import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numberpicker/numberpicker.dart';

import '../../router.gr.dart';
import '../common/build_context_extensions.dart';
import 'onboarding_cubit.dart';
import 'widgets/onboarding_app_bar.dart';

@RoutePage()
class OnboardingSelectWeightPage extends StatelessWidget {
  const OnboardingSelectWeightPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: OnboardingAppBar(
        stepNumber: 4,
        title: context.l18n.onboarding_weightSelectionTitle,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(context.l18n.onboarding_weightSelectionDescription),
              const SizedBox(height: 24),
              BlocBuilder<OnboardingCubit, OnboardingCubitState>(
                builder: (context, state) => NumberPicker(
                  value: state.weight,
                  minValue: 50,
                  maxValue: 180,
                  step: 1,
                  haptics: true,
                  axis: Axis.horizontal,
                  textMapper: (numberText) => '${numberText}kg',
                  onChanged: (value) {
                    context.read<OnboardingCubit>().setWeight(value);
                  },
                ),
              ),
              const Spacer(),
              Center(
                child: OutlinedButton(
                  onPressed: () => context.router.push(const OnboardingSelectBodyCompositionRoute()),
                  child: Text(context.l18n.common_continue),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
