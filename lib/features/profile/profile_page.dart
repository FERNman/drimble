import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../router.dart';
import '../common/build_context_extensions.dart';
import 'profile_cubit.dart';
import 'widgets/profile_form.dart';
import 'widgets/profile_picture.dart';

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
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 16, top: 24, right: 16),
          child: BlocBuilder<ProfileCubit, ProfileCubitState>(builder: (context, state) {
            if (state.user == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                ProfilePicture(gender: state.user!.gender),
                const SizedBox(height: 8),
                Text(state.user!.name, style: context.textTheme.titleLarge),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                state.profileFormValue != null
                    ? ProfileForm(
                        value: state.profileFormValue!,
                        onValueChanged: (value) => context.read<ProfileCubit>().updateProfile(value),
                      )
                    : const SizedBox(),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    context.read<ProfileCubit>().signOut();
                    context.router.replaceAll([const OnboardingRoute()]);
                  },
                  child: Text(context.l18n.profile_signOut),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () => context.router.pop(),
      ),
      title: Text(context.l18n.profile_title),
    );
  }
}
