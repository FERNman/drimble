import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/user/gender.dart';
import '../../router.dart';
import '../common/build_context_extensions.dart';
import 'profile_cubit.dart';
import 'widgets/profile_form.dart';

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
        title: Text(context.l18n.profile_title),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 16, top: 24, right: 16),
          child: BlocBuilder<ProfileCubit, ProfileCubitState>(builder: (context, state) {
            if (state.user == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final profileImagePath =
                state.user!.gender == Gender.male ? 'assets/images/profile_male.png' : 'assets/images/profile_male.png';

            return Column(
              children: [
                Center(
                  child: Container(
                    width: 142,
                    height: 142,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey),
                      image: DecorationImage(
                        fit: BoxFit.fill,
                        image: AssetImage(profileImagePath),
                      ),
                    ),
                  ),
                ),
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
}
