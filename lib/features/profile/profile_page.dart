import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../router.dart';
import 'profile_cubit.dart';

class ProfilePage extends StatelessWidget implements AutoRouteWrapper {
  const ProfilePage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) => BlocProvider(
        create: (context) => ProfileCubit(context.read()),
        child: this,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.router.pop(),
        ),
        title: const Text('Profile'),
      ),
      body: Column(
        children: [
          TextButton(
            onPressed: () {
              context.read<ProfileCubit>().signOut();
              context.router.replaceAll([const OnboardingRoute()]);
            },
            child: const Text('Log out'),
          ),
        ],
      ),
    );
  }
}
