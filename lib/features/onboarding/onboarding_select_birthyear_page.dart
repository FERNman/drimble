import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numberpicker/numberpicker.dart';

import '../../router.dart';
import '../common/build_context_extensions.dart';
import 'onboarding_cubit.dart';
import 'widgets/onboarding_app_bar.dart';

class OnboardingSelectBirthyearPage extends StatelessWidget {
  const OnboardingSelectBirthyearPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: OnboardingAppBar(
        stepNumber: 2,
        title: context.l18n.onboarding_birthyearSelectionTitle,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Text(context.l18n.onboarding_birthyearSelectionDescription),
              const SizedBox(height: 24),
              BlocBuilder<OnboardingCubit, OnboardingCubitState>(
                builder: (context, state) => Center(
                  child: NumberPicker(
                    value: state.birthyear,
                    minValue: 1900,
                    maxValue: DateTime.now().year,
                    step: 1,
                    haptics: true,
                    axis: Axis.vertical,
                    onChanged: (value) {
                      context.read<OnboardingCubit>().setBirthyear(value);
                    },
                  ),
                ),
              ),
              const Spacer(),
              Center(
                child: OutlinedButton(
                  onPressed: () => context.router.push(const OnboardingSelectHeightRoute()),
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
