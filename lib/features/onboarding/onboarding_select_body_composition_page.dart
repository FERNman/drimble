import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/user/body_composition.dart';
import '../../infra/l18n/body_composition_translations.dart';
import '../../router.gr.dart';
import '../common/build_context_extensions.dart';
import 'onboarding_cubit.dart';
import 'widgets/onboarding_app_bar.dart';

@RoutePage()
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(context.l18n.onboarding_bodyCompositionSelectionDescription),
              const SizedBox(height: 24),
              BlocBuilder<OnboardingCubit, OnboardingCubitState>(
                builder: (context, state) => _bodyCompositionSelection(context, state),
              ),
              const Spacer(),
              Center(child: _finishButton(context))
            ],
          ),
        ),
      ),
    );
  }

  SizedBox _bodyCompositionSelection(BuildContext context, OnboardingCubitState state) {
    return SizedBox(
      width: 300,
      child: ButtonTheme(
        alignedDropdown: true,
        child: DropdownButtonFormField(
          decoration: InputDecoration(label: Text(context.l18n.onboarding_bodyCompositionSelectionLabel)),
          items:
              BodyComposition.values.map((e) => DropdownMenuItem(value: e, child: Text(e.translate(context)))).toList(),
          value: state.bodyComposition,
          onChanged: (value) {
            if (value is BodyComposition) {
              context.read<OnboardingCubit>().setBodyComposition(value);
            }
          },
        ),
      ),
    );
  }

  Widget _finishButton(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        context.read<OnboardingCubit>().save();
        context.router.replaceAll([const DiaryRoute()]);
      },
      child: Text(context.l18n.onboarding_finish),
    );
  }
}
