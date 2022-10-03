import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'onboarding_cubit.dart';

class OnboardingCubitProviderPage extends StatelessWidget {
  const OnboardingCubitProviderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OnboardingCubit(context.read()),
      child: const AutoRouter(),
    );
  }
}
