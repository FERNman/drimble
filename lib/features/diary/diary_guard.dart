import 'package:auto_route/auto_route.dart';

import '../../data/user_repository.dart';
import '../../router.gr.dart';

class DiaryGuard extends AutoRouteGuard {
  final UserRepository _userRepository;

  DiaryGuard(this._userRepository);

  @override
  Future<void> onNavigation(NavigationResolver resolver, StackRouter router) async {
    if (!_userRepository.isSignedIn()) {
      router.replaceAll([const SignInRoute()]);
    } else if (!(await _userRepository.didFinishOnboarding())) {
      router.replaceAll([const OnboardingRoute()]);
    } else {
      resolver.next();
    }
  }
}
