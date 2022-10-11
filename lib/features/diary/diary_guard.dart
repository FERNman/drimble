import 'package:auto_route/auto_route.dart';

import '../../data/user_repository.dart';
import '../../router.dart';

class DiaryGuard extends AutoRouteGuard {
  final UserRepository _userRepository;

  DiaryGuard(this._userRepository);

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    if (await _userRepository.isSignedIn()) {
      resolver.next();
    } else {
      router.replaceAll([const OnboardingRoute()]);
    }
  }
}
