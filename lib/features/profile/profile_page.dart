import 'package:auto_route/auto_route.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../router.gr.dart';
import '../common/build_context_extensions.dart';
import 'profile_cubit.dart';
import 'widgets/profile_form.dart';
import 'widgets/profile_picture.dart';

@RoutePage()
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
          padding: const EdgeInsets.only(left: 16, top: 24, right: 16, bottom: 16),
          child: BlocBuilder<ProfileCubit, BaseProfileCubitState>(
            builder: (context, state) {
              if (state is ProfileCubitStateLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return _buildBody(state as ProfileCubitState, context);
            },
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      leading: const BackButton(),
      title: Text(context.l18n.profile_title),
      actions: [
        TextButton(
          onPressed: () => showDialog(
            context: context,
            builder: (context) => _buildSignOutDialog(context),
          ),
          child: Text(context.l18n.profile_signOut),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBody(ProfileCubitState state, BuildContext context) {
    return Column(
      children: [
        ProfilePicture(gender: state.user.gender),
        const SizedBox(height: 8),
        Text(state.user.name, style: context.textTheme.titleLarge),
        const SizedBox(height: 12),
        const Divider(),
        const SizedBox(height: 12),
        ProfileForm(
          value: state.profileFormValue,
          onValueChanged: (value) => context.read<ProfileCubit>().updateProfile(value),
        ),
        const Spacer(),
        const SizedBox(height: 16),
        Text.rich(
          TextSpan(
            text: context.l18n.profile_howIsTheBacEstimated,
            recognizer: TapGestureRecognizer()..onTap = () => context.router.push(const FAQRoute()),
          ),
          style: context.textTheme.labelSmall?.copyWith(color: Colors.blue),
        ),
      ],
    );
  }

  Widget _buildSignOutDialog(BuildContext context) {
    return AlertDialog(
      title: Text(context.l18n.profile_signOutDialog_title),
      content: Text(context.l18n.profile_signOutDialog_content),
      actions: [
        TextButton(
          onPressed: () => context.router.pop(),
          child: Text(context.l18n.profile_signOutDialog_cancel),
        ),
        TextButton(
          onPressed: () {
            context.read<ProfileCubit>().signOut();
            context.router.replaceAll([const OnboardingRoute()]);
          },
          child: Text(context.l18n.profile_signOutDialog_confirm),
        ),
      ],
    );
  }
}
