import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../router.gr.dart';
import '../common/build_context_extensions.dart';
import 'sign_in_cubit.dart';
import 'widgets/sign_in_with_google_button.dart';

@RoutePage()
class SignInPage extends StatelessWidget implements AutoRouteWrapper {
  const SignInPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) => BlocProvider(
        create: (context) => SignInCubit(context.read()),
        child: this,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),
                    Text(
                      context.l10n.sign_in_welcomeToDrimble,
                      style: context.textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 24),
                    const Center(child: Image(image: AssetImage('assets/images/onboarding_welcome.png'))),
                    const Spacer(),
                    _buildSignInButton(context),
                    const SizedBox(height: 12),
                    _buildSkipSignInButton(context),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkipSignInButton(BuildContext context) {
    return Center(
      child: TextButton(
        child: Text(context.l10n.sign_in_continueWithoutSigningIn),
        onPressed: () async {
          await context
              .read<SignInCubit>()
              .signInAnonymously()
              .then((value) => _redirectAfterSignIn(value, context))
              .catchError((error) => _handleSignInError(error, context));
        },
      ),
    );
  }

  Widget _buildSignInButton(BuildContext context) {
    if (kDebugMode) {
      return const SizedBox();
    }

    // if (Platform.isIOS) {
    //   return SignInWithAppleButton(
    //     onPressed: () async {
    //       final cubit = context.read<SignInCubit>();
    //       final appleAuth = await SignInWithApple.getAppleIDCredential(
    //         scopes: [AppleIDAuthorizationScopes.email],
    //       );

    //       final credential = AppleAuthProvider.credential(appleAuth.authorizationCode);
    //       cubit
    //           .signInWithCredential(credential)
    //           .then((value) => _redirectAfterSignIn(value, context))
    //           .catchError((error) => _handleSignInError(error, context));
    //     },
    //   );
    // } else {
    if (Platform.isAndroid) {
      return SignInWithGoogleButton(
        onPressed: () async {
          await GoogleSignIn(
            scopes: ['email'],
          )
              .signIn()
              .then((googleUser) {
                if (googleUser != null) {
                  return googleUser.authentication;
                }

                throw Error();
              })
              .then((googleAuth) {
                final credential = GoogleAuthProvider.credential(
                  accessToken: googleAuth.accessToken,
                  idToken: googleAuth.idToken,
                );

                return context.read<SignInCubit>().signInWithCredential(credential);
              })
              .then((value) => _redirectAfterSignIn(value, context))
              .catchError((error) => _handleSignInError(error, context));
        },
      );
    } else {
      return const SizedBox();
    }
  }

  void _redirectAfterSignIn(UserCredential value, BuildContext context) {
    if (value.additionalUserInfo?.isNewUser == true) {
      context.router.replaceAll([const OnboardingRoute()]);
    } else {
      // If the user is not new but has not completed the onboarding, they will be redirected in the DiaryGuard
      // so we don't have to check again here. The above statement is only to avoid unnecessary redirects.
      context.router.push(const DiaryRoute());
    }
  }

  void _handleSignInError(dynamic error, BuildContext context) {
    if (error is FirebaseAuthException) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message ?? context.l10n.sign_in_error)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.sign_in_error)),
      );
    }
  }
}
